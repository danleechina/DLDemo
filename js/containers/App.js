// @flow

'use strict';

import { connect } from 'react-redux';
import React from 'react';
import { StyleSheet, Text, TabBarIOS, } from 'react-native';

import AlarmView from '../components/AlarmView';
import BedtimeView from '../components/BedtimeView';
import StopwatchView from '../components/StopwatchView';
import TimerView from '../components/TimerView';
import WorldClockView from '../components/WorldClockView';
import { addWorldClock, addAlarmClock } from '../actions/actions'

class App extends React.Component {
  state: {
    selectedTab: string
  }

  constructor(props) {
    super(props);
    this.state = {
      selectedTab: "Alarm Clock"
    };
  }

  render() {
    const { dispatch, worldClocks, alarmClocks, } = this.props;
    return (
        <TabBarIOS
            selectedTab={this.state.selectedTab}
            style={styles.container}
            unselectedTintColor="white"
            tintColor="rgba(253,148,38,1)"
            barTintColor="black">
            <TabBarIOS.Item
            title="World Clock"
            icon={require('../../img/Globe.png')}
            selectedIcon={require('../../img/Globe_Filled.png')}
            selected={this.state.selectedTab === 'World Clock'}
            onPress={() => {
                this.setState({
                selectedTab: 'World Clock'
                });
            }}>
            <WorldClockView
              addWorldClock={(data) => {
                let idx = worldClocks.findIndex(raw => {
                  let obj = raw.data;
                  return obj.city.toUpperCase() === data.city.toUpperCase() && obj.country.toUpperCase() === data.country.toUpperCase() && obj.time_diff === data.time_diff;
                });
                if (idx === -1) {
                  dispatch(addWorldClock(data));
                }
              }}
              worldClockData={worldClocks.map(element => {
                  return element.data;
                })}
              />
            </TabBarIOS.Item>

            <TabBarIOS.Item
            title="Alarm Clock"
            icon={require('../../img/Alarm.png')}
            selectedIcon={require('../../img/Alarm_Filled.png')}
            selected={this.state.selectedTab === 'Alarm Clock'}
            onPress={() => {
                this.setState({
                selectedTab: 'Alarm Clock'
                });
            }}>
            <AlarmView
              addAlarmClock={(data) => {
                dispatch(addAlarmClock(data));
              }}
              alarmClockData={alarmClocks.map(element => {
                return element.data;
              })}
            />
            </TabBarIOS.Item>

            <TabBarIOS.Item
            title="Bedtime"
            icon={require('../../img/Clock.png')}
            selectedIcon={require('../../img/Clock_Filled.png')}
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
            icon={require('../../img/Watch.png')}
            selectedIcon={require('../../img/Watch_Filled.png')}
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
            icon={require('../../img/Timer.png')}
            selectedIcon={require('../../img/Timer_Filled.png')}
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

function select(state) {
  return {
    worldClocks: state.worldclocks.worldclocks,
    alarmClocks: state.alarmclocks.alarmclocks,
  }
}

export default connect(select)(App);
