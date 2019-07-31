import {NativeModules, NativeEventEmitter} from 'react-native';

const NativeModule = NativeModules.WorkersManager;
const NativeEvents = new NativeEventEmitter(NativeModule);

let nextKey = 0;

export default class Worker {
  key = null;
  subscription = null;
  terminated = false;
  started = null;
  start = null;

  constructor(bundleRoot, bundleResource, bundlerPort = 0) {
    this.key = nextKey++;

    this.subscription = NativeEvents.addListener(
      'message',
      ({key, message}) => {
        if (!this.onmessage || this.key !== key) {
          return;
        }

        this.onmessage(message);
      },
    );

    this.started = new Promise(resolve => {
      this.start = async () => {
        await NativeModule.startWorker(
          this.key, bundleRoot, bundleResource, parseInt(bundlerPort, 10)
        );

        resolve();
      };
    });
  }

  async postMessage(message) {
    if (this.terminated) {
      return;
    }

    await this.started;
    NativeModule.postMessage(this.key, message);
  }

  async terminate() {
    if (this.terminated) {
      return;
    }

    await this.started;
    NativeEvents.removeListener(this.subscription);
    NativeModule.stopWorker(this.key);
  }
}
