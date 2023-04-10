var numeral = require("numeral");

function isNumber(str) {
  if (typeof str == "number") return true;
  if (typeof str != "string") return false;
  // could also coerce to string: str = ""+str
  return !isNaN(str) && !isNaN(parseFloat(str));
}

export default {
  filters: {
    stripDecimals: (d) => d.replace(/[.]0+$/, ""),

    formatDistance: (d) => {
      if (d == null || d.units == null) return "";
      let v = isNumber(d.value)
        ? numeral(d.value).format("0,0.00")
        : d.value.toString().replace(/^[0:]*/, "");
      return v + " " + d.units.abbreviation;
    },
    formatDistanceTrim: (d) => {
      if (d == null || d.units == null) return "";
      return (
        numeral(d.value)
          .format("0,0.00")
          .replace(/[.]?0+$/, "") +
        " " +
        d.units.abbreviation
      );
    },

    formatAddress: (a, includeStreet = true) => {
      let str = "";
      if (a.street1 && includeStreet) str += a.street1 + " ";
      if (a.street2 && includeStreet) str += a.street2 + " ";
      if (a.city) str += a.city + " ";
      if (a.state) {
        if (a.city) {
          str = str.trim();
          str += ", " + a.state;
        } else str += a.state;
        str += " ";
      }
      return str.trim();
    },
  },
};
