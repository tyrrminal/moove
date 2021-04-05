import Vue from 'vue';

var numeral = require('numeral');
function isNumber(str) {
  if (typeof str != "string") return false // we only process strings!
  // could also coerce to string: str = ""+str
  return !isNaN(str) && !isNaN(parseFloat(str))
}

// Currency (d: decimal)
Vue.filter('format_dollars', d => '$' + numeral(d).format('0,0.00'));

// Distance (d: { quantity: {value: decimal, units: { abbreviation: string, unit: string } }, normalizedQuantity: {value: decimal, units: { abbreviation: string, unit: string } } })
Vue.filter("format_distance", d => (isNumber(d.quantity.value) ? numeral(d.quantity.value).format('0,0.00') : d.quantity.value.replace(/^[0:]*/, '')) + ' ' + d.quantity.units.abbreviation);
Vue.filter("format_distance_trim", d => numeral(d.quantity.value).format('0,0.00').replace(/[.]?0+$/, '') + ' ' + d.quantity.units.abbreviation);
Vue.filter("format_normalized_distance", d => numeral(d.normalizedQuantity.value).format('0,0.00') + " " + d.normalizedQuantity.units.abbreviation);

// Percents
Vue.filter("format_pct", v => v ? Number(100 - v).toFixed(1) + '%' : "");

// Dates
Vue.filter('event_year', e => { let m = require("moment"); return m(e.scheduled_start).format("YYYY"); })
