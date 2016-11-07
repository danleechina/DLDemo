let nextWorldClockId = 0;

export const ADD_WORLDCLOCK = 'ADD_WORLDCLOCK';

export function addWorldClock(element) {
    return {
        type: 'ADD_WORLDCLOCK',
        id: nextWorldClockId ++,
        data: element,
    }
}