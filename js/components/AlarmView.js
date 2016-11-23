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
  Switch,
} from 'react-native';
import CustomNavigationBar from './CustomNavigationBar';
import ChangeAlarmView from './ChangeAlarmView';
import AlarmRepeatOptionView from './AlarmRepeatOptionView';
import AlarmSetNameView from './AlarmSetNameView';
import {routes} from './RoutesForAlarmView';

var styles = StyleSheet.create({
});

class AlarmView extends React.Component {
  render() {
    return (
      <View style={{flex: 1}}>
        <StatusBar backgroundColor='black' barStyle='light-content'/>
        <Navigator
          ref={'navigator'}
          style={{backgroundColor: 'black',}}
          initialRoute={routes[0]}
          initialRouteStack={routes}
          renderScene={(route: any, navigator: Navigator) => this._renderScene(route, navigator)}
          configureScene={(route, routeStack) => this._pushEffect(route, routeStack)}
        />
      </View>
    );
  }

  _pushEffect(route: any, routeStack: any) {
    if (route.index >= 3) {
      return Navigator.SceneConfigs.PushFromRight;
    }
    return Navigator.SceneConfigs.FloatFromBottom;
  }

  _renderScene(route: any, navigator: Navigator) {
      if (route.index == 0) {
        return (
          <IntervalListView
            navigator={navigator}
            alarmClockData={this.props.alarmClockData}
          />
        );
      } else if (route.index == 1) {
        return (
          <ChangeAlarmView
            navigator={navigator}
            addAlarmClock={(data)=>this.props.addAlarmClock(data)}
            title={route.title}
            leftTitle={route.leftTitle}
            rightTitle={route.rightTitle}
            onLeftButtonClick={() => this.goBack()}
            onRightButtonClick={() => this.save()}
            needDeleteButton={route.needDeleteButton}
          />
        );
      } else if (route.index == 2) {
        return (
          <ChangeAlarmView
            navigator={navigator}
            addAlarmClock={(data)=>this.props.addAlarmClock(data)}
          />
        );
      } else if (route.index == 3) {
        return (
          <AlarmRepeatOptionView
            navigator={navigator}
            title={route.title}
            leftTitle={route.leftTitle}
            rightTitle={route.rightTitle}
            onLeftButtonClick={() => this.goBack()}
            repeats={route.repeats}
          />
        )
      } else if (route.index == 4) {
        return (
          <AlarmSetNameView
            navigator={navigator}
            title={route.title}
            leftTitle={route.leftTitle}
            rightTitle={route.rightTitle}
            onLeftButtonClick={() => this.goBack()}
            defaultName={route.defaultName}
          />
        );
      }
  }

  goBack() {
    this.refs.navigator.pop();
  }

  save() {
    console.log('Save data');
  }
}


class IntervalListView extends React.Component {
  addButtonTapped() {
    this.props.navigator.push(routes[1]);
  }

  editButtonTapped() {

  }

  constructor(props) {
    super(props);
    this.ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    this.editMode = false;
    this.state = {
      dataSource: this.ds.cloneWithRows(this.props.alarmClockData),
      editMode: this.editMode,
    };
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.alarmClockData !== this.props.alarmClockData) {
      this.setState({ dataSource: this.ds.cloneWithRows(nextProps.alarmClockData), });
    }
  }

  render() {
    return (
      <View style={{flex: 1}}>
        <CustomNavigationBar
          title={routes[0].title}
          leftTitle={'Edit'}
          rightTitle={'+'}
          onLeftButtonClick={()=>this.editButtonTapped()}
          onRightButtonClick={()=>this.addButtonTapped()}
        />
        <ListView
          style={{backgroundColor: 'yellow',}}
          dataSource={this.state.dataSource}
          renderRow={(rowData, sectionID, rowID, highlightRow)=>this._renderRow(rowData, sectionID, rowID, highlightRow)}
          renderSeparator={this._renderSeparator}
          enableEmptySections={true}
        />
      </View>
    );
  }

  _renderRow(rowData, sectionID, rowID, highlightRow) {
    if (this.editMode) {
        return (
          <View key={`${sectionID}-${rowID}`}>
          </View>
        );
    } else {
      // rowData = {
      //   time: "7:00",
      //   amOrPm: "AM",
      //   name: "Wake UP",
      //   description: "every day",
      //   enable: true,
      //   repeat: [1,2,3,4,5,6,7],
      //   snooze: true,
      //   sound: 111,
      // }
      return (
        <View key={`${sectionID}-${rowID}`} style={stylesForRow.row}>
          <View style={stylesForRow.leftView}>
            <Text style={stylesForRow.leftTopText1}>
              {rowData.time}
              <Text style={stylesForRow.leftTopText1}>
                {rowData.amOrPm}
              </Text>
            </Text>
            <Text style={stylesForRow.leftBottomText}>
              {rowData.name + ', ' + rowData.description}
            </Text>
          </View>

          <View style={stylesForRow.rightView}>
            <Switch
              style={{alignSelf: 'center'}}
              value={rowData.enable}
              >
            </Switch>
          </View>
        </View>
      );
      // return (
      //   <View key={`${sectionID}-${rowID}`} style={stylesForRow.row}>
      //     <View style={stylesForRow.leftView}>
      //       <Text style={stylesForRow.leftTopText1}>
      //         7:00
      //         <Text style={stylesForRow.leftTopText2}>
      //           AM
      //         </Text>
      //       </Text>
      //       <Text style={stylesForRow.leftBottomText}>
      //         No money, every weekday
      //       </Text>
      //     </View>
      //
      //     <View style={stylesForRow.rightView}>
      //       <Switch
      //         style={{alignSelf: 'center'}}
      //         value={true}
      //         >
      //       </Switch>
      //     </View>
      //   </View>
      // );
    }
  }

  _renderSeparator(sectionID: number, rowID: number, adjacentRowHighlighted: bool) {
    return ( <View key={`${sectionID}-${rowID}`} style={{ height: 0.5, backgroundColor: '#CCCCCC', }} /> );
  }
}

var stylesForRow = StyleSheet.create({
  row: {
    height: 100,
    flexDirection: 'row',
    backgroundColor: 'black',
  },

  leftView: {
    marginLeft: 10,
    flex: 2.5,
    justifyContent: 'center',
  },

  rightView: {
    flex: 1,
    alignSelf: 'center',
    marginRight: 10,
  },

  leftTopText1: {
    fontSize: 44,
    color: 'white',
  },

  leftTopText2: {
    fontSize: 24,
    color: 'white',
  },

  leftBottomText: {
    fontSize: 15,
    color: 'gray',
  },
});

module.exports = AlarmView;
