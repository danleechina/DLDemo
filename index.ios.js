// @flow

'use strict';

import React from 'react';
import { AppRegistry, AsyncStorage } from 'react-native';
import App from './js/containers/App';
import { Provider } from 'react-redux';
import { createStore } from 'redux';
import worldclocks from './js/reducers/worldclock';
import { addWorldClock } from './js/actions/actions';

let STORAGE_KEY_WORLD_CLOCK = '@clock:key:world_clock53';
//let store = createStore(worldclocks);


class Clock extends React.Component {
  constructor() {
    super();
    this.finishLoadData = false;
    this.store = createStore(worldclocks);
  }
  componentWillUnmount() {
    console.log("index.ios.js unmount");
    this.unsubscribe();
  }

  componentWillMount() {
    console.log("index.ios.js mount");
    this.unsubscribe = this.store.subscribe(
      this._writeData
    );
  }

  componentDidMount() {
    console.log("index.ios.js mount" + this.finishLoadData);
    this._loadInitialState().done();
  }

  _writeData = async () => {
    if (!this.finishLoadData) {
      return;
    }
    try {
      console.log("Write data");
      console.log(JSON.stringify(this.store.getState().worldclocks));
      await AsyncStorage.setItem(STORAGE_KEY_WORLD_CLOCK, JSON.stringify(this.store.getState().worldclocks));
    } catch (error) {
      console.log(error.message);
    }
  };

  _loadInitialState = async () => {
    if (this.finishLoadData) {
      return
    }
    try {
        await AsyncStorage.getItem(STORAGE_KEY_WORLD_CLOCK, (err, result) => {
          console.log("read data");
          console.log(result);
          let value = JSON.parse(result);
          if (value !== null) {
            for (const data of value) {
              this.store.dispatch(addWorldClock(data.data));
            }
          }
      });
    } catch (error) {
      console.log(error.message);
    }
    this.finishLoadData = true;
  };

  render() {
    return (
      <Provider store={this.store}>
        <App/>
      </Provider>
    );
  }
}
// Module name
AppRegistry.registerComponent('Clock', () => Clock);
