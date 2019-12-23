import Vue from 'vue';

var numeral = require('numeral');

// Currency (d: decimal)
Vue.filter('format_dollars', d => '$' + numeral(d).format('0,0.00'));

// Distance (d: { quantity: {value: decimal, units: { abbreviation: string, unit: string } }, normalized_quantity: {value: decimal, units: { abbreviation: string, unit: string } } })
Vue.filter("format_distance", d => numeral(d.quantity.value).format('0,0.00') + ' ' + d.quantity.units.abbreviation);
Vue.filter("format_distance_trim", d => numeral(d.quantity.value).format('0,0.00').replace(/[.]?0+$/, '') + ' ' + d.quantity.units.abbreviation);
Vue.filter("format_normalized_distance", d => numeral(d.normalized_quantity.value).format('0,0.00') + " " + d.normalized_quantity.units.abbreviation);

// Percents
Vue.filter("format_pct", v => v? Number(100 - v).toFixed(1) + '%' : "");

// Dates
Vue.filter('event_year', e => { let m = require("moment"); return m(e.scheduled_start).format("YYYY"); })
