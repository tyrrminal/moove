var numeral = require('numeral');

function isNumber(str) {
  if (typeof str != "string") return false // we only process strings!
  // could also coerce to string: str = ""+str
  return !isNaN(str) && !isNaN(parseFloat(str))
}

export default {
  filters: {
    stripDecimals: d => d.replace(/[.]0+$/, ''),

    formatDistance: d => (isNumber(d.quantity.value) ? numeral(d.quantity.value).format('0,0.00') : d.quantity.value.replace(/^[0:]*/, '')) + ' ' + d.quantity.units.abbreviation,
    formatDistanceTrim: d => numeral(d.quantity.value).format('0,0.00').replace(/[.]?0+$/, '') + ' ' + d.quantity.units.abbreviation,
    formatNormalizedDistance: d => numeral(d.normalizedQuantity.value).format('0,0.00') + " " + d.normalizedQuantity.units.abbreviation,

    decimate: v => v / 100,
    invDecimate: v => (100 - v) / 100,

    formatAddress: a => {
      let str = "";
      if (a.street1)
        str += a.street1 + " ";
      if (a.street2)
        str += a.street2 + " ";
      if (a.city)
        str += a.city + " ";
      if (a.state) {
        if (a.city) {
          str = str.trim();
          str += ", " + a.state;
        }
        else
          str += a.state;
        str += " ";
      }
      return str.trim();
    }
  }
};
