// @flow

'use strict'

import React from 'react';
import {Text,View,StyleSheet,ListView,NavigatorIOS,Navigator,TouchableHighlight,StatusBar,} from 'react-native';
import CityListView from './CityListView';
import CustomNavigationBar from './CustomNavigationBar';

var routes = [
  {title: 'World Clock', index: 0, component: IntervalListView, hiddenNavigatorBar:false,},
  {title: 'Choose a City.', index: 1, component: CityListView, hiddenNavigatorBar:true,},
];

class WorldClockView extends React.Component {
  state: {
    data: array,
  }

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
        return (
          <IntervalListView
            navigator={navigator}
            worldClockData={this.props.worldClockData}
          />
        );
      } else if (route.index === 1) {
        return (
          <CityListView
            navigator={navigator}
            addWorldClock={(data)=>this.props.addWorldClock(data)}
          />
        );
      }
  }
}

class IntervalListView extends React.Component {
  ds: ListView.DataSource
  state: Object
  calculatedData: Object
  props: Object
  interval: any
  editMode: bool

  constructor(props) {
    super(props);
    this.ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
    this.locationTime = 8;
    this.editMode = false;
    this.updateDataWithTime();
    this.state = {
      dataSource: this.ds.cloneWithRows(this.calculatedData),
      editMode: this.editMode,
    };
  }

  calculateTimeString(element) {
    var time = new Date();
    var mins = time.getUTCMinutes() + (element.time_diff - Math.floor(element.time_diff)) * 60;
    var hours = time.getUTCHours() + Math.floor(element.time_diff);
    if (mins >= 60) {
      mins -= 60;
      hours += 1;
    }
    var hoursIn24Format = hours
    var amOrPm = "AM";
    if (hours < 0) {
      hours += 24;
    }
    if (hours > 12) {
      hours -= 12;
      amOrPm = "PM";
    }
    let shours = hours < 10 ? "0" + hours : "" + hours
    let smins = mins < 10 ? "0" + mins : mins;
    let time_diff = element.time_diff - this.locationTime;
    let stime_diff = time_diff < 0 ? time_diff : "+" + time_diff;
    let info = "Today, " + stime_diff + "HRS";
    if (hoursIn24Format + time_diff < 0) {
      info = "Yesterday, " + stime_diff + "HRS";
    } else if (hoursIn24Format + time_diff >= 24) {
      info = "Tomorrow, " + stime_diff + "HRS";
    }
    return [shours + ":" + smins, amOrPm, info];
  }

  updateDataWithTime(rowData = this.props.worldClockData) {
      this.calculatedData = rowData.map((elem) => {
        var [timeString, amOrPm, info] = this.calculateTimeString(elem);
        return {  'city': elem['city'],
                  'country': elem['country'],
                  'timeString': timeString,
                  'amOrPm': amOrPm,
                  'info': info,
                };
      });
  }

  changeModeOfEdit() {
    this.editMode = !this.editMode;
    this.setState({
      editMode: this.editMode,
    })
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.worldClockData !== this.props.worldClockData) {
      this.updateDataWithTime(nextProps.worldClockData);
      this.setState({ dataSource: this.ds.cloneWithRows(this.calculatedData), });
    }
  }

  componentDidMount() {
    this.interval = setInterval(
      () => {
        this.updateDataWithTime();
        this.setState({ dataSource: this.ds.cloneWithRows(this.calculatedData), });
      },
      1000
    );
  }

  componentWillUnmount() {
    clearInterval(this.interval);
  }

  render() {
    return (
      <View style={{flex: 1}}>
        <CustomNavigationBar
          title={routes[0].title}
          leftTitle={'Edit'}
          rightTitle={'+'}
          onLeftButtonClick={()=>this.changeModeOfEdit()}
          onRightButtonClick={()=> this.props.navigator.push(routes[1])}
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
          <View style={styles.row}
            key={`${sectionID}-${rowID}`}>
            <View style={ styles.leftView}>
                  <Text style={styles.leftTopText} numberOfLines={1} minimumFontScale={2} adjustsFontSizeToFit={true}>{rowData.city}</Text>
                  <Text style={styles.leftBottomText} numberOfLines={1} minimumFontScale={2} adjustsFontSizeToFit={true}>{rowData.info}</Text>
            </View>

            <View style={styles.rightView}>
              <Text style={styles.rightTimeText} numberOfLines={1} adjustsFontSizeToFit={true}>
                {rowData.timeString}
                <Text style={styles.rightAPMText} numberOfLines={1} adjustsFontSizeToFit={true}>{rowData.amOrPm}</Text>
              </Text>
            </View>
          </View>
        );
    } else {
      return (
        <View style={styles.row}
          key={`${sectionID}-${rowID}`}>
          <View style={ styles.leftView}>
                <Text style={styles.leftTopText} numberOfLines={1} minimumFontScale={2} adjustsFontSizeToFit={true}>{rowData.city}</Text>
                <Text style={styles.leftBottomText} numberOfLines={1} minimumFontScale={2} adjustsFontSizeToFit={true}>{rowData.info}</Text>
          </View>

          <View style={styles.rightView}>
            <Text style={styles.rightTimeText} numberOfLines={1} adjustsFontSizeToFit={true}>
              {rowData.timeString}
              <Text style={styles.rightAPMText} numberOfLines={1} adjustsFontSizeToFit={true}>{rowData.amOrPm}</Text>
            </Text>
          </View>
        </View>
      );
    }
  }

  _renderSeparator(sectionID: number, rowID: number, adjacentRowHighlighted: bool) {
    return ( <View key={`${sectionID}-${rowID}`} style={{ height: 0.5, backgroundColor: '#CCCCCC', }} /> );
  }
}

var styles = StyleSheet.create({
  row: {
    height: 100,
    flexDirection: 'row',
    backgroundColor: 'black',
    justifyContent: 'center',
  },

  leftView: {
    flex: 1,
    flexDirection: 'column',
    justifyContent: 'center',
  },

  rightView: {
    flex: 1,
    flexDirection: 'row',
  },

  leftTopText: {
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
    fontSize: 44,
    flex: 1,
    textAlign: 'center',
    color: 'white',
  },

  rightAPMText: {
    fontSize: 24,
    flex: 1,
    color: 'white',
  }
});

module.exports = WorldClockView;
