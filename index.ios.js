// @flow

'use strict';

import React from 'react';
import { AppRegistry, AsyncStorage } from 'react-native';
import App from './js/containers/App';
import { Provider } from 'react-redux';
import { createStore } from 'redux';
import clockApp from './js/reducers/worldclock';
import { addWorldClock, addAlarmClock, } from './js/actions/actions';

let STORAGE_KEY_WORLD_CLOCK = '@clock:key:world_clock515';
let STORAGE_KEY_ALARM_CLOCK = '@clock:key:alarm_clock515';

class Clock extends React.Component {
  constructor() {
    super();
    this.finishLoadData = false;
    this.store = createStore(clockApp);
  }
  componentWillUnmount() {
    this.unsubscribe();
  }

  componentWillMount() {
    this._loadInitialState().done();
    this.unsubscribe = this.store.subscribe(
      this._writeData
    );
  }

  _writeData = async () => {
    if (!this.finishLoadData) {
      return;
    }
    try {
      console.log("Write data");
      console.log(JSON.stringify(this.store.getState().worldclocks));
      await AsyncStorage.setItem(STORAGE_KEY_WORLD_CLOCK, JSON.stringify(this.store.getState().worldclocks.worldclocks));
      await AsyncStorage.setItem(STORAGE_KEY_ALARM_CLOCK, JSON.stringify(this.store.getState().alarmclocks.alarmclocks));

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
          let value = JSON.parse(result);
          if (value !== null) {
            for (const data of value) {
              this.store.dispatch(addWorldClock(data.data));
            }
          }
        });
        await AsyncStorage.getItem(STORAGE_KEY_ALARM_CLOCK, (err, result) => {
          let value = JSON.parse(result);
          if (value !== null) {
            for (const data of value) {
              this.store.dispatch(addAlarmClock(data.data));
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
