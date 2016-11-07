import { ADD_WORLDCLOCK, } from '../actions/actions'

const initialState = {
    worldclocks: [],
};

export default function worldclocks(state = initialState, action) {
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