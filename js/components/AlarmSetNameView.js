// @flow
'use strict'

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
  TextInput,
} from 'react-native';
import CustomNavigationBar from './CustomNavigationBar';

class AlarmSetNameView extends React.Component {
  state = {
    text: 'This is your label',
  };

  render() {
    return (
      <View style={{flex: 1}}>
        <CustomNavigationBar
          title={this.props.title}
          leftTitle={this.props.leftTitle}
          rightTitle={this.props.rightTitle}
          onLeftButtonClick={() => this.props.onLeftButtonClick()}/>
        <View style={{flex: 1}}>
          <TextInput
            style={{height: 40, borderColor: 'gray', borderWidth: 1, color: 'white', marginTop: 200}}
            onChangeText={(text) => this.setState({text})}
            value={this.state.text}/>
        </View>
      </View>
    );
  }
}

module.exports = AlarmSetNameView;
