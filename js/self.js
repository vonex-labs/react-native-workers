import {NativeModules, NativeEventEmitter} from 'react-native';

const NativeWorker = NativeModules.RNWorker;
const NativeEvents = new NativeEventEmitter(NativeWorker);

const self = {
  postMessage: NativeManager.postMessage,
};

NativeEvents.addListener('message', message => {
  self.onmessage && self.onmessage(message);
});

export default self;
