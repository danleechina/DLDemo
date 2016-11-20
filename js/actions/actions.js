let nextWorldClockId = 0;
let nextAlramClockId = 0;

export const ADD_WORLDCLOCK = 'ADD_WORLDCLOCK';
export const ADD_ALARMCLOCK = 'ADD_ALARMCLOCK';

export function addWorldClock(element) {
  return {
      type: ADD_WORLDCLOCK,
      id: nextWorldClockId ++,
      data: element,
  }
}

export function addAlarmClock(element) {
  return {
    type: ADD_ALARMCLOCK,
    id: nextAlarmClockId ++,
    data: element,
  }
}
