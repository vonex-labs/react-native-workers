import {NativeModules, NativeEventEmitter} from 'react-native';

const NativeModule = NativeModules.WorkersInstanceManager;
const NativeEvents = new NativeEventEmitter(NativeModule);

const self = {
  postMessage(message) {
    NativeModule.postMessage(message);
  },
};

NativeEvents.addListener('message', ({message}) => {
  if (!self.onmessage) {
    return;
  }

  self.onmessage(message);
});

// Signal that the worker is ready to receive messages.
// This happens in `setImmediate` to guarantee a chance to set
// `self.onmessage` before the delivery of any queued messages.
setImmediate(NativeModule.workerStarted);

export default self;
