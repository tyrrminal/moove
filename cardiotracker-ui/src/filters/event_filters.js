import Vue from 'vue';

var numeral = require('numeral');
numeral.register('locale', 'en-us', {
  delimiters: {
      thousands: ',',
      decimal: '.'
  },
  abbreviations: {
      thousand: 'k',
      million: 'm',
      billion: 'b',
      trillion: 't'
  },
  ordinal: function (number) {
      var b = number % 10;
      return (~~ (number % 100 / 10) === 1) ? 'th' :
          (b === 1) ? 'st' :
          (b === 2) ? 'nd' :
          (b === 3) ? 'rd' : 'th';
  },
  currency: {
      symbol: '$'
  }
});
numeral.locale('en-us');

// Currency (d: decimal)
Vue.filter('currency', d =>  numeral(d).format('$0,0.00') );

// Distance (d: { quantity: {value: decimal, units: { abbreviation: string, unit: string } }, normalized_quantity: {value: decimal, units: { abbreviation: string, unit: string } } })
Vue.filter("format_distance", d => numeral(d.quantity.value).format('0,0.00') + ' ' + d.quantity.units.abbreviation );
Vue.filter("format_distance_trim", d => numeral(d.quantity.value).format('0,0.00').replace(/[.]?0+$/,'') + ' ' + d.quantity.units.abbreviation );
Vue.filter("format_normalized_distance", d => numeral(d.normalized_quantity.value).format('0,0.00') + " " + d.normalized_quantity.units.abbreviation );
