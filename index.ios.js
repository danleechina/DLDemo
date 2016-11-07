// @flow

'use strict';

import React from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  TabBarIOS,
} from 'react-native';

import AlarmView from './js/components/AlarmView';
import BedtimeView from './js/components/BedtimeView';
import StopwatchView from './js/components/StopwatchView';
import TimerView from './js/components/TimerView';
import WorldClockView from './js/components/WorldClockView';
import { Provider } from 'react-redux';
import { createStore } from 'redux';
import worldclocks from './js/reducers/worldclock';
import { addWorldClock } from './js/actions/actions';

let store = createStore(worldclocks); 

class Clock extends React.Component {
  state: {
    selectedTab: string
  }
  constructor(props) {
    super(props);
    this.state = {
      selectedTab: "World Clock"
    };
  }

  render() {
    return (
      <Provider store={store}>
        <TabBarIOS
          selectedTab={this.state.selectedTab}
          style={styles.container}
          unselectedTintColor="white"
          tintColor="rgba(253,148,38,1)"
          barTintColor="black">
          <TabBarIOS.Item
            title="World Clock"
            icon={require('./img/logo.png')}
            selected={this.state.selectedTab === 'World Clock'}
            onPress={() => {
              this.setState({
                selectedTab: 'World Clock'
              });
            }}>
            <WorldClockView  addWorldClock={data => dispatch(addWorldClock(data))}/>
          </TabBarIOS.Item>
          <TabBarIOS.Item
            title="Alarm"
            icon={require('./img/logo.png')}
            selected={this.state.selectedTab === 'Alarm'}
            onPress={() => {
              this.setState({
                selectedTab: 'Alarm'
              });
            }}>
            <AlarmView/>
          </TabBarIOS.Item>
          <TabBarIOS.Item
            title="Bedtime"
            icon={require('./img/logo.png')}
            selected={this.state.selectedTab === 'Bedtime'}
            onPress={() => {
              this.setState({
                selectedTab: 'Bedtime'
              });
            }}>
            <BedtimeView/>
          </TabBarIOS.Item>
          <TabBarIOS.Item
            title="Stopwatch"
            icon={require('./img/logo.png')}
            selected={this.state.selectedTab === 'Stopwatch'}
            onPress={() => {
              this.setState({
                selectedTab: 'Stopwatch'
              });
            }}>
            <StopwatchView/>
          </TabBarIOS.Item>
          <TabBarIOS.Item
            title="Timer"
            icon={require('./img/logo.png')}
            selected={this.state.selectedTab === 'Timer'}
            onPress={() => {
              this.setState({
                selectedTab: 'Timer'
              });
            }}>
            <TimerView/>
          </TabBarIOS.Item>
        </TabBarIOS>
      </Provider>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
  }
});

// Module name
AppRegistry.registerComponent('Clock', () => Clock);

console.log(store.getState());
let unsubscribe = store.subscribe(() =>
  console.log(store.getState())
)

// 发起一系列 action
store.dispatch(addWorldClock('Learn about actions'))
store.dispatch(addWorldClock('Learn about reducers'))
store.dispatch(addWorldClock('Learn about store'))

// 停止监听 state 更新
unsubscribe();
