import {NativeModules, NativeEventEmitter} from 'react-native';

const NativeManager = NativeModules.RNWorkerManager;
const NativeEvents = new NativeEventEmitter(NativeManager);

let nextKey = 0;

export default class Worker {
  async constructor(root, resource) {
    this.key = nextKey++;
    await WorkerManager.startWorker(this.key, root, resource);
    this.subscription = NativeEvents.addListener(
      `message:${this.key}`,
      message => this.onmessage && this.onmessage(message),
    );
  }

  postMessage(message) {
    WorkerManager.postMessage(this.key, message);
  }

  terminate() {
    NativeEvents.removeListener(this.subscription);
    WorkerManager.stopWorker(this.key);
  }
}
