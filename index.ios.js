// @flow

'use strict';

import React from 'react';
import { AppRegistry } from 'react-native';
import App from './js/containers/App';
import { Provider } from 'react-redux';
import { createStore } from 'redux';
import worldclocks from './js/reducers/worldclock';
import { addWorldClock } from './js/actions/actions';

let store = createStore(worldclocks);
let unsubscribe = store.subscribe(() => {
  console.log(store.getState().worldclocks);
});

class Clock extends React.Component {


  componentWillMount() {

    // 发起一系列 action
    // store.dispatch(addWorldClock({
    //     city: 'Beijing',
    //     country: 'China',
    //     time_diff: 8,
    //   }));
  }

  componentWillUnMount() {
    unsubscribe();
  }

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
