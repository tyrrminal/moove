import { DateTime } from "luxon";

const MIN_PER_HOUR = 60;
const SEC_PER_MIN = 60;

export function convertUnitValue(uv, sUnit, tUnit = null) {
  if (tUnit != null && tUnit.id == uv.unitOfMeasureID) return uv;
  let n = uv;
  if (sUnit == null) return null;
  if (sUnit.normalUnitID != null) {
    if (sUnit.inverted) n = 1 / n;
    n *= sUnit.normalizationFactor;
  }
  if (tUnit == null || tUnit.normalUnitID == null) return n;
  if (tUnit.inverted) return tUnit.normalizationFactor / n;
  return n / tUnit.normalizationFactor;
}

export function hmsToHours(t) {
  let [h, m, s] = t.split(":").map((i) => Number(i));
  return h + (m + s / SEC_PER_MIN) / MIN_PER_HOUR;
}

export function minutesToHms(min) {
  return DateTime.now()
    .startOf("day")
    .plus({ minutes: Math.round(SEC_PER_MIN * min) / SEC_PER_MIN })
    .toFormat("HH:mm:ss");
}

export function activityRate(a) {
  if (a && a.speed) return a.speed;
  if (a && a.pace)
    return {
      unitOfMeasureID: a.pace.unitOfMeasureID,
      value: hmsToHours(a.pace.value) * MIN_PER_HOUR,
    };
  return null;
}
