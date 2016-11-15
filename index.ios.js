// @flow

'use strict';

import React from 'react';
import { AppRegistry, AsyncStorage } from 'react-native';
import App from './js/containers/App';
import { Provider } from 'react-redux';
import { createStore } from 'redux';
import worldclocks from './js/reducers/worldclock';
import { addWorldClock } from './js/actions/actions';

let STORAGE_KEY_WORLD_CLOCK = '@clock:key:world_clock';
let store = createStore(worldclocks);


class Clock extends React.Component {
  constructor() {
    super();
    this.finishLoadData = false;
  }
  componentWillUnMount() {
    this.unsubscribe();
  }

  componentWillMount() {
    this.unsubscribe = store.subscribe(
      this._writeData
    );
  }

  componentDidMount() {
    this._loadInitialState().done();
  }

  _writeData = async () => {
    if (!this.finishLoadData) {
      return;
    }
    try {
      await AsyncStorage.setItem(STORAGE_KEY_WORLD_CLOCK, JSON.stringify(store.getState().worldclocks));
    } catch (error) {
      console.log(error.message);
    }
  };

  _loadInitialState = async () => {
    try {
        await AsyncStorage.getItem(STORAGE_KEY_WORLD_CLOCK, (err, result) => {
        let value = JSON.parse(result);
        if (value !== null) {
          for (const data of value) {
            store.dispatch(addWorldClock(data.data));
          }
        }
        this.finishLoadData = true;
      });
    } catch (error) {
      console.log(error.message);
    }
  };

  render() {
    return (
      <Provider store={store}>
        <App/>
      </Provider>
    );
  }
}
// Module name
AppRegistry.registerComponent('Clock', () => Clock);
