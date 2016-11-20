// @flow
'use strict'

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
  StatusBar,
  Navigator,
  DatePickerIOS,
} from 'react-native';
import CustomNavigationBar from './CustomNavigationBar';

const styles = StyleSheet.create({
  mainView: {
    flex: 1,
    backgroundColor: 'pink',
  },

  text: {
    color: 'blue',
    backgroundColor: 'pink',
  },
});

class ChangeAlarmView extends React.Component {
  render() {
    console.log('ChangeAlarmView');
    return (
      <View sytle={styles.mainView}>
        <CustomNavigationBar
          title={this.props.title}
          leftTitle={this.props.leftTitle}
          rightTitle={this.props.rightTitle}
          onLeftButtonClick={()=>this.props.onLeftButtonClick()}
          onRightButtonClick={()=> this.props.onRightButtonClick()}
        />
        <Text style={styles.text}>Some thing happened</Text>
        {/* <DatePickerIOS></DatePickerIOS> */}
      </View>
    );
  }
}

module.exports = ChangeAlarmView;
