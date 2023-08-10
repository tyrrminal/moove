import { hmsToHours, minutesToHms } from "@/utils/unitConversion.js";
import { DateTime } from "luxon";

export default {
  data: function () {
    return {
      speedChartBackgroundColor: '#bde8ff',
      speedChartBorderColor: '#88c6ff'
    }
  },
  computed: {
    velocityType: function () {
      if (!this.$store.getters["meta/isLoaded"]) return 'Speed';
      return this.data.some(a => this.getActivityType(a.activityTypeID).hasSpeed) ? 'Speed' : 'Pace'
    },
    dataYears: function () {
      let dates = this.data.map(e => DateTime.fromISO(e.startTime).startOf('year'));
      dates.sort((a, b) => a.toISO().localeCompare(b.toISO()));
      let i = dates[0];
      let years = [];
      while (i <= dates[dates.length - 1]) {
        years.push(i.toISO());
        i = i.plus({ years: 1 })
      }
      return years;
    }
  },
  methods: {
    formatSpeedTicks: function (value) {
      if (this.velocityType.toLocaleLowerCase() == 'pace')
        return minutesToHms(value).replace(/^00:/, '')
      else if (this.velocityType.toLocaleLowerCase() == 'speed')
        return `${value} mph`
    },
    formatSpeedTooltips: function (context) {
      if (this.velocityType.toLocaleLowerCase() == 'speed') return `Speed: ${context.parsed.y.toFixed(2)} mph`;
      if (this.velocityType.toLocaleLowerCase() == 'pace') return `Pace: ${context.raw.v.replace(/^00:0?/, '')} /mi`;
      return null;
    },
    getNumericVelocity: function (v) {
      if (v == null) return null
      if (this.velocityType.toLocaleLowerCase() == 'speed') return v;
      return hmsToHours(v) * 60;
    },
    getActivityType: function (id) {
      return this.$store.getters["meta/getActivityType"](id);
    },
  }
}
