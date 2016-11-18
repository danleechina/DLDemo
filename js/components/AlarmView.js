// @flow
'use strict'

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
  StatusBar,
  ListView,
  Navigator,
} from 'react-native';
import CustomNavigationBar from './CustomNavigationBar';
import ChangeAlarmView from './ChangeAlarmView';

var styles = StyleSheet.create({
});

var routes = [
  {title: 'Alarm', index: 0, component: IntervalListView, hiddenNavigatorBar:false,},
  {title: 'Add Alarm', index: 1, component: ChangeAlarmView, hiddenNavigatorBar:true,},
  {title: 'Edit Alarm', index: 2, component: ChangeAlarmView, hiddenNavigatorBar:true,},
];

class AlarmView extends React.Component {
  render() {
    return (
      <View style={{flex: 1}}>
        <StatusBar backgroundColor='black' barStyle='light-content'/>
        <Navigator
          style={{backgroundColor: 'black',}}
          initialRoute={routes[0]}
          initialRouteStack={routes}
          renderScene={(route: any, navigator: Navigator) => this._renderScene(route, navigator)}
          configureScene={(route, routeStack) => Navigator.SceneConfigs.FloatFromBottom}
        />
      </View>
    );
  }

  _renderScene(route: any, navigator: Navigator) {
      if (route.index === 0) {
        return (<IntervalListView navigator={navigator}/>);
      } else if (route.index === 1) {
        return (<ChangeAlarmView navigator={navigator} />);
      } else if (route.index === 2) {
        return (<ChangeAlarmView navigator={navigator}/>);
      }
  }
}


class IntervalListView extends React.Component {
  addButtonTapped() {

  }

  editButtonTapped() {

  }

  render() {
    return (
      <View>
        <CustomNavigationBar
          title={routes[0].title}
          leftTitle={'Edit'}
          rightTitle={'+'}
          onLeftButtonClick={()=>this.editButtonTapped()}
          onRightButtonClick={()=>this.addButtonTapped()}
        />
        <ListView>

        </ListView>
      </View>
    );
  }
}
module.exports = AlarmView;
