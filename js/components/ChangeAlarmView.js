// @flow
'use strict'

import React from 'react';
import {
  Text,
  View,
  StyleSheet,
  StatusBar,
  Navigator,
  DatePickerIOS,
  ListView,
  TouchableHighlight,
  Switch,
} from 'react-native';
import CustomNavigationBar from './CustomNavigationBar';
import {routes} from './RoutesForAlarmView';

const styles = StyleSheet.create({
  mainView: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: 'yellow',
  },

  text: {
    color: 'blue',
    backgroundColor: 'pink',
  },

  rowSeperator: {
    height:0.5,
    backgroundColor: 'rgba(255,255,255,0.5)',
  },
});

class ChangeAlarmView extends React.Component {
  static defaultProps = {
    date: new Date(),
    timeZoneOffsetInHours: (-1) * (new Date()).getTimezoneOffset() / 60,
  };

  ds = new ListView.DataSource({
    rowHasChanged: (row1, row2) => row1 !== row2,
    sectionHeaderHasChanged: (s1, s2) => s1 !== s2,
  });

  data = [
    {
      titleText: 'Repeat',
      detailText: '',
      rightInfoText: 'Weekdays',
      rightViewStyle: 'arrow',
    },
    {
      titleText: 'Label',
      detailText: '',
      rightInfoText: 'No money',
      rightViewStyle: 'arrow',
    },
    {
      titleText: 'Sound',
      detailText: '',
      rightInfoText: 'Strum',
      rightViewStyle: 'arrow',
    },
    {
      titleText: 'Snooze',
      detailText: '',
      rightInfoText: '',
      rightViewStyle: 'switch',
    },
    {
      titleText: '',
      detailText: '',
      rightInfoText: '',
      rightViewStyle: '',
    },
    {
      titleText: 'Delete Alarm',
      detailText: '',
      rightInfoText: '',
      rightViewStyle: '',
      styleForRow: 'centerTitle',
    },
  ];

  state = {
    date: this.props.date,
    timeZoneOffsetInHours: this.props.timeZoneOffsetInHours,
    dataSource: this.ds.cloneWithRows(this.data),
  };

  onDateChange = (date) => {
    this.setState({date: date});
  };

  _renderRow(rowData: DataFormat, sectionID: number, rowID: number, highlightRow: (sectionID: number, rowID: number) => void) {
    return (
      <TouchableHighlight onPress={()=>{
        highlightRow(sectionID, rowID);
        if (rowID == 0) {
          // Repeats View
          let route = routes[3];
          route.repeats = [false, false, false, true, false, false, false, ];
          this.props.navigator.push(route);
        } else if (rowID == 1) {
          // Set Name View
          let route = routes[4];
          route.defaultName = 'I Love You';
          this.props.navigator.push(route);
        } else if (rowID == 2) {

        } else if (rowID == 3) {

        } else if (rowID == 5) {

        }
      }}>
        <View>
          <ListViewCell
            key={`${sectionID}-${rowID}`}
            titleText={rowData.titleText}
            rightInfoText={rowData.rightInfoText}
            rightViewStyle={rowData.rightViewStyle}
            styleForRow={rowData.styleForRow ? rowData.styleForRow : ''}
          />
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
    return null;
  }

  render() {
    return (
      <View sytle={styles.mainView}>
        <CustomNavigationBar
          title={this.props.title}
          leftTitle={this.props.leftTitle}
          rightTitle={this.props.rightTitle}
          onLeftButtonClick={()=>this.props.onLeftButtonClick()}
          onRightButtonClick={()=> this.props.onRightButtonClick()}
        />

        <DatePickerIOS
          style={{backgroundColor: 'gray',}}
          date={this.state.date}
          mode="time"
          timeZoneOffsetInMinutes={this.state.timeZoneOffsetInHours * 60}
          onDateChange={this.onDateChange}
          minuteInterval={10}
        />

        <ListView
          style={{height: 240}}
          dataSource={this.state.dataSource}
          renderRow={(rowData: DataFormat, sectionID: number, rowID: number, highlightRow: (sectionID: number, rowID: number) => void)=>this._renderRow(rowData, sectionID, rowID, highlightRow)}
          renderSeparator={this._renderSeperator}
          renderSectionHeader={this._renderSectionHeader}
        />
      </View>
    );
  }
}

const stylesForCell = StyleSheet.create({
  cellForCenterTitle: {
    height: 45,
    justifyContent: 'center',
  },

  centerTitle: {
    color: 'red',
    textAlign: 'center',
    fontSize: 17,
  },

  cell: {
    height: 44,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },

  titleLable: {
    fontSize: 16,
    color: 'white',
    marginLeft: 5,
  },

  detailLabel: {
    fontSize: 12,
    color: 'gray',
  },

  rightView: {
    marginRight: 5,
    flexDirection: 'row',
  },

  rightInfoLabel: {
    fontSize: 15,
    color: 'gray',
  },

});

class ListViewCell extends React.Component {
  static defaultProps = {
    titleText: '',
    detailText: '',
    rightInfoText: '',
    rightViewStyle: 'switch',
    styleForRow: 'centerTitle',
  };

  arrow = <Text style={{fontSize: 16, color: 'gray'}}>></Text>;
  switchView = <Switch value={true}></Switch>;

  render() {
    if (this.props.styleForRow === 'centerTitle') {
      return (
        <View style={stylesForCell.cellForCenterTitle}>
          <Text style={stylesForCell.centerTitle}> {this.props.titleText} </Text>
        </View>
      );
    }
    return (
      <View style={stylesForCell.cell}>
        <Text style={stylesForCell.titleLable}>
          {this.props.titleText}
        </Text>
        <View style={stylesForCell.rightView}>
          <Text style={stylesForCell.rightInfoLabel}> {this.props.rightInfoText} </Text>
          { this.props.rightViewStyle === 'arrow' ? this.arrow :
            this.props.rightViewStyle === 'switch' ? this.switchView : null}
        </View>
      </View>
    );
  }
}

module.exports = ChangeAlarmView;
