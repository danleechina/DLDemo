// @flow

'use strict';

import React from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  TabBarIOS,
} from 'react-native';

import AlarmView from './js/AlarmView';
import BedtimeView from './js/BedtimeView';
import StopwatchView from './js/StopwatchView';
import TimerView from './js/TimerView';
import WorldClockView from './js/WorldClockView';

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
          <WorldClockView/>
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
