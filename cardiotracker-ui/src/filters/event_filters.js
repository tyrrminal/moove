import Vue from 'vue';

Vue.filter('currency', d =>  '$'+Number(d).toFixed(2) );
Vue.filter("format_distance", d => Number(d.quantity.value).toFixed(2).replace(/[.]0+$/,'') + " " + d.quantity.units.abbreviation );
Vue.filter("format_normalized_distance", d => Number(d.normalized_quantity.value).toFixed(2).replace(/[.]0+$/,'') + " " + d.normalized_quantity.units.abbreviation );
