// @flow

'use strict'

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
  ListView,
  NavigatorIOS,
  TextInput,
  Navigator,
  TouchableHighlight,
} from 'react-native';

type Props = {
  navigator: Navigator,
};

type DataFormat = {
  city: string,
  country: string,
  time_diff: number,
}
class CityListView extends React.Component {
  state: {
    dataSource: ListView.DataSource
  };

  constructData() {
    var data = require('../Resources/cities.json');
    var newData = data.map(elem => {
      var time = elem['time_zone'].substring(1, elem['time_zone'].indexOf(')'));
      var hour = Number(time.substring(4,6));
      var min = Number(time.substring(7,9))/60;
      var signStr = time.substring(3,4);
      var sign = 1;
      if (signStr === '-') {
        sign = -1;
      }
      return { 'city': elem['city'], 'country': elem['country'], 'time_diff': (min+hour)*sign};
    });

    var blob = {};
    var sectionIds = [];

    newData.map((element) => {
      var section = element.city.charAt(0);
      if (sectionIds.indexOf(section) === -1) {
        sectionIds.push(section);
        blob[section] = [];
      }
      blob[section].push(element);
    });
    return {blob, sectionIds};
  }

  constructor(props: Props) {
    super(props);
    var ds = new ListView.DataSource({
      rowHasChanged: (row1, row2) => row1 !== row2,
      sectionHeaderHasChanged: (s1, s2) => s1 !== s2,
    });
    var {blob, sectionIds} = this.constructData();
    this.state = {
      dataSource: ds.cloneWithRowsAndSections(blob, sectionIds),
    };
  }

  _renderRow(rowData: DataFormat, sectionID: number, rowID: number, highlightRow: (sectionID: number, rowID: number) => void) {
    return (
      <View style={styles.row}>
        <Text style={styles.rowText}>{rowData.city + ', ' + rowData.country}</Text>
      </View>
    );
  }

  _renderSeperator(sectionID: number, rowID: number, adjacentRowHighlighted: bool) {
    return (
      <View style={styles.rowSeperator}></View>
    );
  }

  _renderSectionHeader(sectionData: string, sectionID: number) {
    return (
      <View style={styles.rowSection}>
        <Text style={styles.rowSectionText}>{sectionID}</Text>
      </View>
    );
  }

  _searchBarTextChanged(text: string) {
    console.log(text);
  }

  render() {
    return (
      <View style={styles.mainView}>
        <CustomNavigationBar styles={styles.customNavigationBar} onChangeText={this._searchBarTextChanged} navigator={this.props.navigator}/>
        <ListView
          style={styles.listView}
          dataSource={this.state.dataSource}
          renderRow={this._renderRow}
          renderSeparator={this._renderSeperator}
          renderSectionHeader={this._renderSectionHeader}
        />
      </View>

    );
  }
}

class CustomNavigationBar extends React.Component {
  render() {
    return (
      <View style={stylesForNavigationBar.mainView}>
        <Text style={stylesForNavigationBar.topView}>Choose a City.</Text>
        <View style={stylesForNavigationBar.bottomView}>
          <TextInput style={stylesForNavigationBar.leftView} onChangeText={this.props.onChangeText} placeHolder="hello" placeholderTextColor="red"></TextInput>
          <TouchableHighlight onPress={()=>this.props.navigator.pop()}>
            <Text style={stylesForNavigationBar.rightView}>Cancel</Text>
          </TouchableHighlight>
        </View>
      </View>
  );
  }
}

const stylesForNavigationBar = StyleSheet.create({
  mainView: {
    marginTop: 20,
    flexDirection: 'column',
    // backgroundColor: 'white',
    height: 50,
  },

  topView: {
    height: 20,
    color: 'white',
    textAlign: 'center',
  },

  bottomView: {
    height: 30,
    flexDirection: 'row',
  },

  leftView: {
    flex: 8,
    backgroundColor: 'gray',
    height: 20,
    margin: 5,
    borderRadius: 5,
  },

  rightView: {
    flex: 2,
    color: 'rgba(253,148,38,1)',
    fontSize: 15,
    margin: 5,
  },
});

const styles = StyleSheet.create({
  mainView: {
    flex: 1,
  },

  listView: {
    backgroundColor: 'black',
    flex:1,
    marginLeft: 5,
    marginRight: 5,
  },

  row: {
    justifyContent: 'center',
    height: 44,
  },

  rowSeperator: {
    height:0.5,
    backgroundColor: 'rgba(255,255,255,0.5)',
  },

  rowText: {
    color: 'white',
    marginLeft: 10,
  },

  rowSection: {
    height: 20,
    backgroundColor: 'gray',
  },

  rowSectionText: {
    color: 'white',
    marginLeft: 10,
  },
});

module.exports = CityListView;
