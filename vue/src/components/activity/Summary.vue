<template>
  <b-row class="summary rounded-lg mt-3 border border-primary mx-3" :style="{ backgroundColor: bgColor }">

    <b-col cols="1" class="text-center text-uppercase font-weight-bold list-summary-title px-0 mx-0 py-2">{{ title
    }}</b-col>

    <b-col>
      <div v-if="data.distance.total.value > 0">
        <label class="mr-2">Distance /</label>
        <span><label>Total:</label>{{ formattedDistance(data.distance.total) }} ({{ data.counts.total | number('0,0')
        }})</span>
        <span><label>Average:</label>{{ formattedDistance(data.distance.avg) }}</span>
        <span><label>Min:</label>{{ formattedDistance(data.distance.min) }}</span>
        <span><label>Max:</label>{{ formattedDistance(data.distance.max) }}</span>
      </div>

      <div v-if="data.time?.net.total || data.time?.duration.total">
        <label class="mr-2">Time /</label>
        <span><label>Total:</label>{{ formattedTime(data.time.net.total) }} <span v-if="timeDiff">({{
          formattedTime(timeDiff, true) }})</span></span>
        <span><label>Average:</label>{{ formattedTime(data.time.net.avg) }} <span v-if="timeAvgDiff">({{
          formattedTime(timeAvgDiff, true) }})</span></span>
        <span><label>Min:</label>{{ formattedTime(data.time.net.min) }} <span v-if="timeMinDiff">({{
          formattedTime(timeMinDiff, true) }})</span></span>
        <span><label>Max:</label>{{ formattedTime(data.time.net.max) }} <span v-if="timeMaxDiff">({{
          formattedTime(timeMaxDiff, true) }})</span></span>
      </div>

      <div v-if="!hidePace">
        <label class="mr-2">Pace /</label>
        <span><label>Average:</label>{{ data.pace.avg.value }} {{
          getUnitOfMeasure(data.pace.avg.unitOfMeasureID).abbreviation }}</span>
        <span><label>Min:</label>{{ data.pace.min.value }} {{
          getUnitOfMeasure(data.pace.min.unitOfMeasureID).abbreviation }}</span>
        <span><label>Max:</label>{{ data.pace.max.value }} {{
          getUnitOfMeasure(data.pace.max.unitOfMeasureID).abbreviation }}</span>
      </div>

      <div v-if="!hideSpeed">
        <label class="mr-2">Speed /</label>
        <span><label>Average:</label>{{ formattedDistance(data.speed.avg) }}</span>
        <span><label>Min:</label>{{ formattedDistance(data.speed.min) }}</span>
        <span><label>Max:</label>{{ formattedDistance(data.speed.max) }}</span>
      </div>
    </b-col>

  </b-row>
</template>

<script>
import { unitValue } from "@/utils/unitValue.js";
import { Duration } from "luxon";
import { mapGetters } from "vuex";

export default {
  props: {
    data: {
      type: Object,
      required: true,
    },
    title: {
      type: String,
      default: "",
    },
    bgColor: {
      type: String,
      default: "#FFF",
    },
  },
  methods: {
    formattedDistance: function (d) {
      return unitValue(d, null, 2).description
    },
    formattedTime: function (t, includeSign = false) {
      let d = Duration.fromISO(t);
      let n = Duration.fromObject({ seconds: 0 });
      d.shiftTo('days', 'hours', 'minutes', 'seconds');
      let isNeg = d < n;
      if (isNeg) d = d.negate();
      let str = d.days >= 1 ? d.toFormat("d'd' h:mm:ss") : d.toFormat('h:mm:ss');
      if (includeSign) str = `${isNeg ? '-' : '+'}${str}`
      return str;
    }
  },
  computed: {
    ...mapGetters('meta', ["getUnitOfMeasure", "getActivityType"]),
    hideSpeed: function () {
      return !this.data.activityTypes.map(t => this.getActivityType(t.id)).some(u => u.hasSpeed)
    },
    hidePace: function () {
      return !this.data.activityTypes.map(t => this.getActivityType(t.id)).some(u => u.hasPace)
    },
    timeDiff: function () {
      let a = Duration.fromISO(this.data.time.duration.total);
      let b = Duration.fromISO(this.data.time.net.total);
      if (a.equals(b)) return null
      return a.minus(b).normalize().shiftToAll();
    },
    timeAvgDiff: function () {
      let a = Duration.fromISO(this.data.time.duration.avg);
      let b = Duration.fromISO(this.data.time.net.avg);
      if (a.equals(b)) return null
      return a.minus(b).normalize().shiftToAll();
    },
    timeMinDiff: function () {
      let a = Duration.fromISO(this.data.time.duration.min);
      let b = Duration.fromISO(this.data.time.net.min);
      if (a.equals(b)) return null
      return a.minus(b).normalize().shiftToAll();
    },
    timeMaxDiff: function () {
      let a = Duration.fromISO(this.data.time.duration.max);
      let b = Duration.fromISO(this.data.time.net.max);
      if (a.equals(b)) return null
      return a.minus(b).normalize().shiftToAll();
    },
  }
}
</script>

<style scoped>
div.list-summary-title {
  writing-mode: vertical-rl;
  text-orientation: sideways;
  transform: rotate(180deg);
  max-width: 1.5rem;
}

div.summary {
  font-weight: bold;
}

div.summary label {
  font-weight: normal;
  margin-right: 1rem;
}

div.summary>div>div>span {
  margin-right: 2rem;
}
</style>
