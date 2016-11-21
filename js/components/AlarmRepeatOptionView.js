// @flow
'use strict'

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
  ListView,
  TouchableHighlight,
} from 'react-native';
import CustomNavigationBar from './CustomNavigationBar';

const style = StyleSheet.create({
  mainView: {
    flex: 1,
  },

  listView: {
    flex: 1,
  },

  cell: {
    height: 44,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  cellText: {
    marginLeft: 15,
    color: 'white',
  },

  cellPicked: {
    color: 'rgba(253,148,38,1)',
    marginRight: 15,
  },
});

class AlarmRepeatOptionView extends React.Component {

  data = [
    {text: 'Every Sunday',picked: false,},
    {text: 'Every Monday',picked: false,},
    {text: 'Every Tuesday',picked: false,},
    {text: 'Every Wednesday',picked: false,},
    {text: 'Every Thursday',picked: false,},
    {text: 'Every Friday',picked: false,},
    {text: 'Every Saturday',picked: true,},
  ];

  ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
  state = {
    dataSource: this.ds.cloneWithRows(this.data),
  };

  _renderRow(rowData, sectionID, rowID, highlightRow) {
    return (
      <TouchableHighlight
        onPress={()=>{
          console.log('Hi there');
          this.data[rowID].picked = !this.data[rowID].picked;
          this.setState({dataSource: this.ds.cloneWithRows(this.data)});
        }}
        >

        <View
          key={`${sectionID}-${rowID}`}
          style={style.cell}
          >
          <Text style={style.cellText}>{rowData.text}</Text>
          {rowData.picked ? <Text style={style.cellPicked}>✓</Text> : null}
        </View>
      </TouchableHighlight>
    );
  }

  _renderSeparator(sectionID: number, rowID: number, adjacentRowHighlighted: bool) {
    return ( <View key={`${sectionID}-${rowID}`} style={{ height: 0.5, backgroundColor: '#CCCCCC', }} /> );
  }

  render() {
    return (
      <View style={style.mainView}>
        <CustomNavigationBar
          title={this.props.title}
          leftTitle={this.props.leftTitle}
          rightTitle={this.props.rightTitle}
          onLeftButtonClick={() => this.props.onLeftButtonClick()}
        />

        <ListView
          style={style.listView}
          dataSource={this.state.dataSource}
          renderRow={(rowData, sectionID, rowID, highlightRow)=>this._renderRow(rowData, sectionID, rowID, highlightRow)}
          renderSeparator={this._renderSeparator}
          renderHeader={()=> <View style={{height: 20}}/>}
        />
      </View>
    );
  }
}

module.exports = AlarmRepeatOptionView
