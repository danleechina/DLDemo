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

class Clock extends React.Component {
  render() {
    return (
      <Provider store={store}>
        <App/>
      </Provider>
    );
  }
}
var data = [
  {
    city: 'San Francisco',
    country: 'USA',
    time_diff: -8,
  },
  {
    city: 'Beijing',
    country: 'China',
    time_diff: 8,
  },
  {
    city: 'London',
    country: 'UK',
    time_diff: 0,
  },
];
// Module name
AppRegistry.registerComponent('Clock', () => Clock);

console.log(store.getState());
let unsubscribe = store.subscribe(() =>
  console.log(store.getState().worldclocks)
)

// 发起一系列 action
store.dispatch(addWorldClock({
    city: 'San Francisco',
    country: 'USA',
    time_diff: -8,
  }))
store.dispatch(addWorldClock({
    city: 'Beijing',
    country: 'China',
    time_diff: 8,
  }))
store.dispatch(addWorldClock({
    city: 'London',
    country: 'UK',
    time_diff: 0,
  }))

// 停止监听 state 更新
unsubscribe();
