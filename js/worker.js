import {NativeModules, NativeEventEmitter} from 'react-native';

const NativeManager = NativeModules.RNWorkerManager;
const NativeEvents = new NativeEventEmitter(NativeManager);

let nextKey = 0;

export default class Worker {
  constructor(root, resource) {
    this.key = nextKey++;
    this.subscription = NativeEvents.addListener(
      'message',
      ({key, message}) => {
        if (this.onmessage && this.key === key) {
          this.onmessage(message);
        }
      },
    );

    NativeManager.startWorker(this.key, root, resource);
  }

  postMessage(message) {
    NativeManager.postMessage(this.key, message);
  }

  terminate() {
    NativeEvents.removeListener(this.subscription);
    NativeManager.stopWorker(this.key);
  }
}
