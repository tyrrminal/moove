const MIN_PER_HOUR = 60;
const SEC_PER_MIN = 60;

export function convertUnitValue(uv, sUnit, tUnit = null) {
  if (tUnit != null && tUnit.id == uv.unitOfMeasureID) return uv;
  let n = uv;
  if (sUnit.normalUnitID != null) {
    if (sUnit.inverted) n = 1 / n;
    n *= sUnit.normalizationFactor;
  }
  if (tUnit == null || tUnit.normalUnitID == null) return n;
  if (tUnit.inverted)
    return tUnit.normalizationFactor / n;
  return n / tUnit.normalizationFactor;
};

export function hmsToHours(t) {
  let [h, m, s] = t.split(":").map(i => Number(i));
  return h + (m + s / SEC_PER_MIN) / MIN_PER_HOUR;
};

export function minutesToHms(min) {
  let h = Math.floor(min / 60);
  let m = Math.floor((min - h * 60));
  let s = Math.round((min - h * 60 - m) * 60);
  return [h, m, s].map(x => String(x).padStart(2, '0')).join(':');
};

export function paceToSpeed(p) {
  let multipliers = [0, 1, 60, 60, 24];
  let bits = p.split(':').reverse();
  let m = 1;
  return (multipliers[2] * multipliers[3]) / bits.reduce((a, c) => { return a + multipliers[m++] * c }, 0)
};

export function activitySpeed(a) {
  if (a) {
    if (a.speed) return a.speed.value;
    if (a.pace) return paceToSpeed(a.pace.value);
  }
  return null;
}
