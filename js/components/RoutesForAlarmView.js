// @flow
'use strict'

export var routes = [
  {title: 'Alarm', index: 0,},
  {title: 'Add Alarm', leftTitle: 'Cancel', rightTitle: 'Save', index: 1, needDeleteButton: false,},
  {title: 'Edit Alarm', leftTitle: 'Cancel', rightTitle: 'Save', index: 2, needDeleteButton: true, },
  {title: 'Repeat', leftTitle: '<Back', rightTitle: '', index: 3, repeats: [false, false, false, false, false, false, false, ],},
  {title: 'Label', leftTitle: '<Back', rightTitle: '', index: 4, defaultName: 'Label'},
];
