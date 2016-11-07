// @flow

'use strict'

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
  ListView,
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

var ds = new ListView.DataSource({
  rowHasChanged: (row1, row2) => row1 !== row2,
  sectionHeaderHasChanged: (s1, s2) => s1 !== s2,
});

var data = require('../../Resources/cities.json');
var rawData = data.map(elem => {
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
var hasSection = true;
var hasData = true;

class CityListView extends React.Component {
  state: {
    dataSource: ListView.DataSource,
  };

  constructData(text: string) {
    var blob = {};
    var sectionIds = [];
    if (text != null) {
      blob = [];
      text = text.toLowerCase();
      rawData.map(element => {
        if (element.country.toLowerCase().indexOf(text) == 0) {
          blob.push(element);
        }
      });
      rawData.map(element => {
        if (element.city.toLowerCase().indexOf(text) == 0) {
          blob.push(element);
        }
      });
    } else {
      rawData.map((element) => {
        var section = element.city.charAt(0).toUpperCase();
        if (sectionIds.indexOf(section) === -1) {
          sectionIds.push(section);
          blob[section] = [];
        }
        blob[section].push(element);
      });
    }
    return {blob, sectionIds};
  }

  constructor(props: Props) {
    super(props);
    var {blob, sectionIds} = this.constructData();
    this.state = {
      dataSource: ds.cloneWithRowsAndSections(blob, sectionIds),
    };
  }

  _renderRow(rowData: DataFormat, sectionID: number, rowID: number, highlightRow: (sectionID: number, rowID: number) => void) {
    return (
      <TouchableHighlight onPress={()=>{
        this.props.navigator.pop();
        highlightRow(sectionID, rowID);
      }}>
        <View style={styles.row} key={`${sectionID}-${rowID}`}>
          <Text style={styles.rowText}>{rowData.city + ', ' + rowData.country}</Text>
        </View>
      </TouchableHighlight>
    );
  }

  _renderSeperator(sectionID: number, rowID: number, adjacentRowHighlighted: bool) {
    return (
      <View style={styles.rowSeperator} key={`${sectionID}-${rowID}`}></View>
    );
  }

  _renderSectionHeader(sectionData: string, sectionID: number) {
    if (hasSection) {
      return (
        <View style={styles.rowSection} key={`${sectionID}`}>
          <Text style={styles.rowSectionText}>{sectionID}</Text>
        </View>
      );
    }
    return null;
  }

  _searchBarTextChanged(text: string) {
    var {blob, sectionIds} = this.constructData(text);
    if (text != null) {
      hasData = blob.length == 0 ? false : true;
      this.setState({
        dataSource: ds.cloneWithRows(blob),
      });
      hasSection = false;
    } else {
      this.setState({
        dataSource: ds.cloneWithRowsAndSections(blob, sectionIds),
      });
      hasSection = true;
  }

  }

  render() {
    if (!hasData) {
      return (
        <View style={styles.mainView}>
          <CustomNavigationBar style={styles.customNavigationBar} onChangeText={(text) => this._searchBarTextChanged(text)} navigator={this.props.navigator}/>
          <Text style={styles.noResultsFound}>No Results found</Text>
        </View>
      );
    } else {
      return (
        <View style={styles.mainView}>
          <CustomNavigationBar style={styles.customNavigationBar} onChangeText={(text) => this._searchBarTextChanged(text)} navigator={this.props.navigator}/>
          <ListView
            ref='listView'
            style={styles.listView}
            dataSource={this.state.dataSource}
            renderRow={(rowData: DataFormat, sectionID: number, rowID: number, highlightRow: (sectionID: number, rowID: number) => void)=>this._renderRow(rowData, sectionID, rowID, highlightRow)}
            renderSeparator={this._renderSeperator}
            renderSectionHeader={this._renderSectionHeader}
          />
        </View>
      );
    }
  }
}

class CustomNavigationBar extends React.Component {
  render() {
    return (
      <View style={stylesForNavigationBar.mainView}>
        <Text style={stylesForNavigationBar.topView}>Choose a City.</Text>
        <View style={stylesForNavigationBar.bottomView}>
          <TextInput style={stylesForNavigationBar.leftView} onChangeText={this.props.onChangeText} placeHolder="hello" placeholderTextColor="red"></TextInput>
          <TouchableHighlight style={stylesForNavigationBar.rightView} onPress={()=>this.props.navigator.pop()}>
            <Text style={stylesForNavigationBar.rightTextView}>Cancel</Text>
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
    paddingLeft: 5,
    borderRadius: 5,
    color: 'white',
  },

  rightView: {
    flex: 2,
    margin: 5,
  },

  rightTextView: {
    color: 'rgba(253,148,38,1)',
    fontSize: 15,
    textAlign: 'center',
  }
});

const styles = StyleSheet.create({
  mainView: {
    flex: 1,
  },

  customNavigationBar: {
    height: 64,
  },

  listView: {
    backgroundColor: 'black',
    flex:1,
    marginLeft: 5,
    marginRight: 5,
  },

  noResultsFound: {
    marginTop: 120,
    backgroundColor: 'black',
    fontSize: 30,
    alignSelf: 'center',
    color: 'white',
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
