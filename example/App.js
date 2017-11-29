import React, { Component } from 'react';
import {
  Button,
  StyleSheet,
  Text,
  View
} from 'react-native';
import { Worker } from 'react-native-workers';

export default class App extends Component<{}> {
  state = { messages: [] }

  worker = null;

  componentDidMount() {
    this.worker = new Worker('worker.thread', 'worker.thread', 8081);
    this.worker.onmessage = this.handleMessage;
  }

  componentWillUnmount() {
    this.worker.terminate();
    this.worker = null;
  }

  handleMessage = message => {
    // console.tron.log(`APP: got message ${message}`);

    this.setState(state => {
      return { messages: [...state.messages, message] };
    });
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native Threads!
        </Text>

        <Button title="Send Message To Worker Thread" onPress={() => {
          this.worker.postMessage('Hello')
        }} />

        <View>
          <Text>Messages:</Text>
          {this.state.messages.map((message, i) => <Text key={i}>{message}</Text>)}
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  }
});
