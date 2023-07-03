import { hmsToHours, minutesToHms } from "@/utils/unitConversion.js";

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
      let start = Math.min(...this.data.map(a => a.year));
      let end = Math.max(...this.data.map(a => a.year));
      return Array.from(new Array(end - start + 1), (x, i) => i + start);
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
      if (this.velocityType.toLocaleLowerCase() == 'speed') return v;
      return hmsToHours(v) * 60;
    },
    getActivityType: function (id) {
      return this.$store.getters["meta/getActivityType"](id);
    },
  }
}
