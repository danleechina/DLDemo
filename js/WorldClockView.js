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
          rightButtonSystemIcon: 'add',
          leftButtonSystemIcon: 'edit',
        }}
        barTintColor='rgba(0, 0, 0, 0.5)'
        titleTextColor='#ffffff'
        tintColor="rgba(253,148,38,1)"
        shadowHidden={false}
        translucent={true}
      />
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
        />
    );
  }

  _renderRow(rowData: string, sectionID: number, rowID: number, highlightRow: (sectionID: number, rowID: number) => void) {
    return (
      <View style={styles.row}
        key={`${sectionID}-${rowID}`}>
        <View style={ styles.leftView}>
            <View style={{ flexDirection:'column', flex:1,}}>
              <View style={{flex: 1}}></View>
              <Text style={{flex:3}, styles.leftTopText} numberOfLines={1} adjustsFontSizeToFit={true} >San Francisco </Text>
            </View>
            <View style={{ flexDirection:'column', flex:1,}}>
              <Text style={{flex:2}, styles.leftBottomText} numberOfLines={1}  adjustsFontSizeToFit={true}>Yesterday, +44HRS</Text>
              <View style={{flex: 1}}></View>
            </View>
        </View>

        <View style={styles.rightView}>
          <Text style={styles.rightTimeText} numberOfLines={1} adjustsFontSizeToFit={true}>
            14:34
            <Text style={styles.rightAPMText} numberOfLines={1} adjustsFontSizeToFit={true}>PM</Text>
          </Text>
        </View>
      </View>
    );
  }

  _renderSeparator(sectionID: number, rowID: number, adjacentRowHighlighted: bool) {
    return ( <View key={`${sectionID}-${rowID}`} style={{ height: 0.5, backgroundColor: '#CCCCCC', }} /> );
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
    backgroundColor: 'black',
    justifyContent: 'center',
  },

  leftView: {
    flex: 1,
    flexDirection: 'column',
  },

  rightView: {
    flex: 1.4,
    flexDirection: 'row',
  },

  leftTopText: {
    fontWeight: 'bold',
    fontSize: 17,
    color: 'white',
    marginLeft: 10,
  },

  leftBottomText: {
    fontSize: 15,
    color: 'gray',
    marginLeft: 10,
  },

  rightTimeText: {
    fontSize: 50,
    flex: 1,
    textAlign: 'center',
    color: 'white',
  },

  rightAPMText: {
    fontSize: 30,
    flex: 1,
    color: 'white',
  }
});

module.exports = WorldClockView;
