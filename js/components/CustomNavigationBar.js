// @flow

'use strict'

import React from 'react';
import {
  Text,
  View,
  TouchableHighlight,
} from 'react-native';


class CustomNavigationBar extends React.Component {
  render() {
    return (
      <View style={{flexDirection: 'column', height: 44, marginTop: 20}}>
        <View style={{flex: 1, justifyContent: 'space-between', flexDirection: 'row'}}>
          <TouchableHighlight onPress={() => this.props.onLeftButtonClick()} >
            <Text style={{ color: 'rgba(253,148,38,1)', fontSize: 14, marginLeft: 10, marginTop: 15}}>{this.props.leftTitle}</Text>
          </TouchableHighlight>
          <Text style={{color: 'white',fontSize: 20,paddingTop: 12,}}>{this.props.title}</Text>
          <TouchableHighlight onPress={() => this.props.onRightButtonClick()}>
            <Text style={{ color: 'rgba(253,148,38,1)', fontSize: 14, marginRight: 10, marginTop: 15,}}>{this.props.rightTitle}</Text>
          </TouchableHighlight>
        </View>
        <View style={{height:0.5, backgroundColor:'rgba(255,255,255,0.5)'}}/>
      </View>
    );
  }
}

module.exports = CustomNavigationBar;
