// @flow
'use strict'

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
} from 'react-native';


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
        <Text style={styles.description}>
          This is 闹钟
        </Text>
      </View>
    );
  }
}
module.exports = AlarmView;
