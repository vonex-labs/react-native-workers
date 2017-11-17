import { self } from 'react-native-workers';
import './config';

let count = 0;

self.onmessage = message => {
  count++;

  self.postMessage(`Message #${count} from worker thread!`);
}
