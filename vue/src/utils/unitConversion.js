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
