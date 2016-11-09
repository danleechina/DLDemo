// @flow

'use strict';

import { connect } from 'react-redux';
import React from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  TabBarIOS,
} from 'react-native';

import AlarmView from '../components/AlarmView';
import BedtimeView from '../components/BedtimeView';
import StopwatchView from '../components/StopwatchView';
import TimerView from '../components/TimerView';
import WorldClockView from '../components/WorldClockView';
import { addWorldClock } from '../actions/actions'

class App extends React.Component {
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
    const { dispatch, worldClocks, } = this.props;
    return (
        <TabBarIOS
            selectedTab={this.state.selectedTab}
            style={styles.container}
            unselectedTintColor="white"
            tintColor="rgba(253,148,38,1)"
            barTintColor="black">
            <TabBarIOS.Item
            title="World Clock"
            icon={require('../../img/logo.png')}
            selected={this.state.selectedTab === 'World Clock'}
            onPress={() => {
                this.setState({
                selectedTab: 'World Clock'
                });
            }}>
            <WorldClockView  addWorldClock={(data) => dispatch(addWorldClock(data))} worldClockData={worldClocks.map(element => {
                  return element.data;
                })}/>
            </TabBarIOS.Item>
            <TabBarIOS.Item
            title="Alarm"
            icon={require('../../img/logo.png')}
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
            icon={require('../../img/logo.png')}
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
            icon={require('../../img/logo.png')}
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
            icon={require('../../img/logo.png')}
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
    worldClocks: state.worldclocks,
  }
}

export default connect(select)(App);
