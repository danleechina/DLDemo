// @flow
'use strict'

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
} from 'react-native';
import CustomNavigationBar from './CustomNavigationBar';


var styles = StyleSheet.create({
  description: {
    fontSize: 20,
    textAlign: 'center',
    color: '#FFFFFF'
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#765432',
  }
});

class AlarmView extends React.Component {
  render () {
    return (
      <View style={styles.container}>

          <CustomNavigationBar
            route={routes[0]}
            leftTitle={'Edit'}
            rightTitle={'+'}
            onLeftButtonClick={()=>this.changeModeOfEdit()}
            onRightButtonClick={()=> this.props.navigator.push(routes[1])}
          />
        <Text style={styles.description}>
          This is 闹钟
        </Text>
      </View>
    );
  }
}
module.exports = AlarmView;
