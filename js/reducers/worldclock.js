import { ADD_WORLDCLOCK, ADD_ALARMCLOCK, } from '../actions/actions';
import { combineReducers } from 'redux';

const initialWorldClocksState = {
  worldclocks: [],
};

const initialAlarmClocksState = {
  alarmclocks: [],
}

function worldclocks(state = initialWorldClocksState, action) {
    switch (action.type) {
        case ADD_WORLDCLOCK:
        return Object.assign({}, state, {
            worldclocks: [
                ...state.worldclocks,
                {
                    id: action.id,
                    data: action.data,
                }
            ]
        })
        default:
        return state;
    }
}

function alarmclocks(state = initialAlarmClocksState, action) {
  switch (action.type) {
      case ADD_ALARMCLOCK:
      return Object.assign({}, state, {
          alarmclocks: [
              ...state.alarmclocks,
              {
                  id: action.id,
                  data: action.data,
              }
          ]
      })
      default:
      return state;
  }
}

const clockApp = combineReducers({
  worldclocks,
  alarmclocks,
});

export default clockApp;
