import { convertUnitValue } from "../src/utils/unitConversion";

const MI_UNIT = {
  "abbreviation": "mi",
  "id": 1,
  "inverted": false,
  "name": "mile",
  "normalUnitID": null,
  "normalizationFactor": 1,
  "type": "Distance"
};

const KM_UNIT = {
  "abbreviation": "km",
  "id": 2,
  "inverted": false,
  "name": "kilometer",
  "normalUnitID": 1,
  "normalizationFactor": 0.621371,
  "type": "Distance"
};

const YD_UNIT = {
  "abbreviation": "yd",
  "id": 5,
  "inverted": false,
  "name": "yard",
  "normalUnitID": 1,
  "normalizationFactor": 0.000568182,
  "type": "Distance"
};

const MPH_UNIT = {
  "abbreviation": "mph",
  "id": 3,
  "inverted": false,
  "name": "miles per hour",
  "normalUnitID": null,
  "normalizationFactor": 1,
  "type": "Rate"
};

const KPH_UNIT = {
  "abbreviation": "kph",
  "id": 4,
  "inverted": false,
  "name": "kilometers per hour",
  "normalUnitID": 3,
  "normalizationFactor": 0.621371,
  "type": "Rate"
};

const MINPMI_UNIT = {
  "abbreviation": "/mi",
  "id": 6,
  "inverted": true,
  "name": "minutes per mile",
  "normalUnitID": 3,
  "normalizationFactor": 60,
  "type": "Rate"
};

const FIVE_KM_IN_MILES = 3.106855;
const FIVE_KM_IN_YARDS = 5468.06;

test("Convert distance to normal unit", () => {
  expect(convertUnitValue(5, KM_UNIT)).toBe(FIVE_KM_IN_MILES);
});

test("Convert normal distance to other unit", () => {
  expect(convertUnitValue(FIVE_KM_IN_MILES, MI_UNIT, KM_UNIT)).toBe(5);
});

test("Convert non-normal unit distance to non-normal unit", () => {
  expect(convertUnitValue(5, KM_UNIT, YD_UNIT)).toBeCloseTo(FIVE_KM_IN_YARDS);
});

test("Convert speed to normal unit", () => {
  expect(convertUnitValue(5, KPH_UNIT)).toBe(FIVE_KM_IN_MILES)
});

test("Convert speed (mph) to exact pace (min/mile)", () => {
  expect(convertUnitValue(6, MPH_UNIT, MINPMI_UNIT)).toBe(10);
});

test("Convert speed (mph) to close pace (min/mile)", () => {
  expect(convertUnitValue(8.4, MPH_UNIT, MINPMI_UNIT)).toBeCloseTo(7.14);
});

import { hmsToHours, minutesToHms } from "../src/utils/unitConversion";

test("Time to Hours value passes", () => {
  expect(hmsToHours("1:04:05")).toBeCloseTo(1.068, 3);
})

test("Minutes to time value passes", () => {
  expect(minutesToHms(9.5)).toBe("00:09:30");
})

test("Time to Hours to Minutes to time", () => {
  expect(minutesToHms(hmsToHours("01:04:05") * 60)).toBe("01:04:05");
})
