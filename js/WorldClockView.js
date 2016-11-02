// @flow

'use strict'

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
  ListView,
  NavigatorIOS,
} from 'react-native';

class WorldClockView extends React.Component {

  render() {
    return (
      <NavigatorIOS
        style={styles.mainView}
        initialRoute={{
        component: IntervalListView,
        title: 'World Clock',
        }}
        barTintColor='white'
      >
      </NavigatorIOS>
    );
  }
}

type Props = {};
class IntervalListView extends React.Component {
  props: Props;
  state: {
    dataSource: ListView.DataSource
  };

  constructor(props: Props) {
    super(props);
    const ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    this.state = {
      dataSource: ds.cloneWithRows(['row 1', 'hie2']),
    };
  }

  render() {
    return (
        <ListView
          style={styles.mainView}
          dataSource={this.state.dataSource}
          renderRow={this._renderRow}
          renderSeparator={this._renderSeparator}
        >

        </ListView>
    );
  }

  _renderRow(rowData: string, sectionID: number, rowID: number, highlightRow: (sectionID: number, rowID: number) => void) {
    return (
      <View style={styles.row}>
        <View style={styles.leftView}>
            <Text style={styles.leftTopText} numberOfLines={1} adjustsFontSizeToFit={true}>San Francisco</Text>
            <Text style={styles.leftBottomText} numberOfLines={1} adjustsFontSizeToFit={true}>Yesterday, +44HRS</Text>
        </View>

        <View style={styles.rightView}>
          <Text style={styles.rightTimeText}>
            14:34
            <Text style={styles.rightAPMText}>PM</Text>
          </Text>
        </View>
      </View>
    );
  }

  _renderSeparator(sectionID: number, rowID: number, adjacentRowHighlighted: bool) {
    return (
      <View
        key={`${sectionID}-${rowID}`}
        style={{
          height: adjacentRowHighlighted ? 4 : 1,
          backgroundColor: adjacentRowHighlighted ? '#3B5998' : '#CCCCCC',
        }}
      />
    );
  }
}

var styles = StyleSheet.create({
  mainView: {
    flex: 1,
    backgroundColor: 'black'
  },

  row: {
    flex: 1,
    height: 100,
    flexDirection: 'row',
    backgroundColor: 'black'
  },

  leftView: {
    flex: 1,
    alignSelf: 'center',
    flexDirection: 'column',
  },

  rightView: {
    flex: 1.4,
    alignSelf: 'center',
    flexDirection: 'row',
  },

  leftTopText: {
    fontSize: 30,
    color: 'white',
    marginLeft: 10,
  },

  leftBottomText: {
    fontSize: 20,
    color: 'gray',
    marginLeft: 10,
  },

  rightTimeText: {
    fontSize: 60,
    color: 'white',
  },

  rightAPMText: {
    fontSize: 40,
    color: 'white',
  }
});

module.exports = WorldClockView;
