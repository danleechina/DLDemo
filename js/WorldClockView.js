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

class WorldClockView extends React.Component {
  state: {
    hideNavigationBar: bool,
  }
  constructor() {
    super();
    this._renderScene.bind(this);
    this.state = {
      hideNavigationBar: false,
    }
  }

  render() {
    var NavigationBarRouteMapper = {
      LeftButton: (route, navigator, index, navState) => {
        if (route.index === 0) {
          return (
            <TouchableHighlight onPress={() => {}}>
              <Text style={{ color: 'rgba(253,148,38,1)', fontSize: 20, marginLeft: 10, marginTop: 12}}>Edit</Text>
            </TouchableHighlight>
          );
        }
      },
      RightButton: (route, navigator, index, navState) => {
        if (route.index === 0) {
          return (
            <TouchableHighlight onPress={() => navigator.push(routes[1])}>
              <Text style={{ color: 'rgba(253,148,38,1)', fontSize: 30, marginRight: 10, marginTop: 7,}}>+</Text>
            </TouchableHighlight>
          );
        }
        else if (route.index === 1) {
          // return (
          //   <TouchableHighlight onPress={() => navigator.pop()}>
          //     <Text style={{ color: 'rgba(253,148,38,1)', fontSize: 15, padding: 10,}}>Cancel</Text>
          //   </TouchableHighlight>
          // );
          return null;
        }

      },
      Title: (route, navigator, index, navState) => {
        if (route.index === 0) {
          return (
            <Text style={{ color: 'white', fontSize: 22, marginRight: 10, marginTop: 11, fontWeight: 'bold'}}>{route.title}</Text>
          );
        }
        else if (route.index === 1) {
          // return (
          //   <Text style={{color: 'white', fontSize: 10, marginTop: 0,}}>{route.title}</Text>
          // );
          return null;
        }
      },
    };

    const routes = [
      {title: 'World Clock', index: 0},
      {title: 'Choose a City.', index: 1},
    ];

    // if (this.state.hideNavigationBar) {
    //   return (
    //     <View style={{flex: 1}}>
    //       <StatusBar backgroundColor='black' barStyle='light-content'/>
    //       <Navigator
    //         style={styles.mainView}
    //         initialRoute={routes[0]}
    //         initialRouteStack={routes}
    //         renderScene={(route, navigator) => {
    //             if (route.index === 0) {
    //               return (<IntervalListView/>);
    //             } else if (route.index === 1) {
    //               return (<CityListView/>);
    //             }
    //           }
    //         }
    //         configureScene={(route, routeStack) => Navigator.SceneConfigs.FloatFromBottom}
    //       />
    //     </View>
    //   );
    // }
    // else {
      return (
        <View style={{flex: 1}}>
          <StatusBar backgroundColor='black' barStyle='light-content'/>
          <Navigator
            ref="nav"
            style={styles.mainView}
            initialRoute={routes[0]}
            initialRouteStack={routes}
            renderScene={this._renderScene}
            configureScene={(route, routeStack) => Navigator.SceneConfigs.FloatFromBottom}
            navigationBar={ this.state.hideNavigationBar ? null :
              <Navigator.NavigationBar routeMapper={NavigationBarRouteMapper}/>
            }
          />
        </View>
      );
    // }
  }

  _renderScene(route: any, navigator: Navigator) {
      if (route.index === 0) {
        return (<IntervalListView/>);
      } else if (route.index === 1) {
        return (<CityListView navigator={this.refs.nav}/>);
      }
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
          style={styles.listView}
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
              <Text style={{flex:3, padding: 0}, styles.leftTopText} numberOfLines={1} adjustsFontSizeToFit={true} >San Francisco </Text>
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
    backgroundColor: 'black',
  },

  listView: {
    flex: 1,
    backgroundColor: 'black',
    marginTop: 44,
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
