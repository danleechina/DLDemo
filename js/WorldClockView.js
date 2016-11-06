// @flow

'use strict'

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
  ListView,
  NavigatorIOS,
  Navigator,
  TouchableHighlight,
  StatusBar,
} from 'react-native';
import CityListView from './CityListView';

var data = [
  {
    city: 'San Francisco',
    country: 'USA',
    time_diff: -8,
  },
  {
    city: 'Beijing',
    country: 'China',
    time_diff: 8,
  },
  {
    city: 'London',
    country: 'UK',
    time_diff: 0,
  },
];

var routes = [
  {title: 'World Clock', index: 0, component: IntervalListView, hiddenNavigatorBar:false,},
  {title: 'Choose a City.', index: 1, component: CityListView, hiddenNavigatorBar:true,},
];

class WorldClockView extends React.Component {
  state: {
    data: Array,
  }
  render() {
    return (
      <View style={{flex: 1}}>
        <StatusBar backgroundColor='black' barStyle='light-content'/>
        <Navigator
          style={{backgroundColor: 'black',}}
          initialRoute={routes[0]}
          initialRouteStack={routes}
          renderScene={this._renderScene}
          configureScene={(route, routeStack) => Navigator.SceneConfigs.FloatFromBottom}
        />
      </View>
    );
  }

  _renderScene(route: any, navigator: Navigator) {
      if (route.index === 0) {
        return (<IntervalListView navigator={navigator}/>);
      } else if (route.index === 1) {
        return (<CityListView navigator={navigator}/>);
      }
  }
}

class CustomNavigationBar extends React.Component {
  render() {
    return (
      <View style={{flexDirection: 'column',height: 64,paddingTop: 20}}>
        <View style={{flex: 1, justifyContent: 'space-between', flexDirection: 'row'}}>
          <TouchableHighlight onPress={() => {}} >
            <Text style={{ color: 'rgba(253,148,38,1)', fontSize: 20, marginLeft: 10, marginTop: 12}}>Edit</Text>
          </TouchableHighlight>
          <Text style={{color: 'white',fontSize: 30,fontWeight: 'bold',paddingTop: 7,}}>{this.props.route.title}</Text>
          <TouchableHighlight onPress={() => this.props.navigator.push(routes[1])}>
            <Text style={{ color: 'rgba(253,148,38,1)', fontSize: 30, marginRight: 10, marginTop: 7,}}>+</Text>
          </TouchableHighlight>
        </View>
        <View style={{height:0.5, backgroundColor:'rgba(255,255,255,0.5)'}}/>
      </View>
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
      dataSource: ds.cloneWithRows(data),
    };
  }

  render() {
    return (
      <View style={{flex: 1}}>
        <CustomNavigationBar navigator={this.props.navigator} route={routes[0]}/>
        <ListView
          style={{flex: 1,backgroundColor: 'yellow', }}
          dataSource={this.state.dataSource}
          renderRow={this._renderRow}
          renderSeparator={this._renderSeparator}
        />
      </View>
    );
  }

  _renderRow(rowData: Object, sectionID: number, rowID: number, highlightRow: (sectionID: number, rowID: number) => void) {
    return (
      <View style={styles.row}
        key={`${sectionID}-${rowID}`}>
        <View style={ styles.leftView}>
            <View style={{ flexDirection:'column', flex:1,}}>
              <View style={{flex: 1}}></View>
              <Text style={{flex:3, padding: 0}, styles.leftTopText} numberOfLines={1} adjustsFontSizeToFit={true} >{rowData.city}</Text>
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
