import { self } from 'react-native-workers/self';
import './config';

let count = 0;

self.onmessage = message => {
  console.log('worker received: ', message)
  count++;

  self.postMessage(`Message #${count} from worker thread!`);
}
