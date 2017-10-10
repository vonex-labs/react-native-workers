import {NativeModules, NativeEventEmitter} from 'react-native';

const NativeModule = NativeModules.WorkersInstanceManager;
const NativeEvents = new NativeEventEmitter(NativeModule);

const self = {
  postMessage(message = null) {
    try {
      message = JSON.stringify(message);
      NativeModule.postMessage(message);
    } catch (error) {
      console.warn('Unable to stringify message', message, error);
    }
  },
};

NativeEvents.addListener('message', ({message}) => {
  if (!self.onmessage) {
    return;
  }

  try {
    message = JSON.parse(message);
    self.onmessage(message);
  } catch (error) {
    console.warn('Unable to parse message', message, error);
  }
});

// Signal that the worker is ready to receive messages.
// This happens in `setImmediate` to guarantee a chance to set
// `self.onmessage` before the delivery of any queued messages.
setImmediate(NativeModule.workerStarted);

export default self;
