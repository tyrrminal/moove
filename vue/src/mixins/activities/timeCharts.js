import { DateTime } from "luxon";

export default {
  computed: {
    sortedData: function () {
      let d = [...this.data];
      d.sort((a, b) => a.startTime > b.startTime);
      return d;
    },
    isMultiYear: function () {
      return DateTime.fromISO(this.sortedData[0].startTime).year != DateTime.fromISO(this.sortedData.slice(-1)[0].startTime).year
    },
    timeScaleUnit: function () {
      return this.isMultiYear ? 'year' : 'month'
    },
    timeScaleFormat: function () {
      return {
        'year': 'yyyy',
        'month': "MMM yyyy"
      }
    },
    timeScaleRange: function () {
      return {
        min: DateTime.fromISO(this.sortedData[0].startTime).minus({ days: 5 }).startOf(this.isMultiYear ? 'year' : 'month').toISODate(),
        max: DateTime.fromISO(this.sortedData.toReversed()[0].startTime).plus({ days: 6, months: 1 }).startOf('month').minus({ days: 1 }).toISODate(),
      }
    }
  },
  methods: {
    addYearGaps: function (arr) {
      let y = null;
      let gd = [];
      arr.forEach(d => {
        if (y != null) {
          while (y++ < d.x.year) {
            gd.push({ y: NaN, x: DateTime.fromISO(`${y}-01-01`) })
          }
        }
        gd.push(d)
        y = d.x.year + 1
      });
      return gd;
    }
  }
}