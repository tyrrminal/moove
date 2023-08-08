<template>
  <div class="summary pt-2 pr-4 rounded-lg mt-3 pb-2 border border-primary" :style="{ backgroundColor: bgColor }">
    <div v-if="title" class="float-left pl-3 text-uppercase font-weight-bold"
      :style="{ writingMode: 'vertical-rl', textOrientation: 'sideways', transform: 'rotate(180deg)' }">{{
        title }}</div>
    <div v-else class="float-left" :style="{ height: '4rem', width: '2rem' }">&nbsp;</div>

    <div v-if="data.distance.total.value > 0">
      <label class="mr-2">Distance /</label>
      <span><label>Total:</label>{{ formattedDistance(data.distance.total) }} ({{ data.counts.total | number('0,0')
      }})</span>
      <span><label>Average:</label>{{ formattedDistance(data.distance.avg) }}</span>
      <span><label>Min:</label>{{ formattedDistance(data.distance.min) }}</span>
      <span><label>Max:</label>{{ formattedDistance(data.distance.max) }}</span>
    </div>

    <div>
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

  </div>
</template>

<script>
import { unitValue } from "@/utils/unitValue.js";
import { Duration } from "luxon";

export default {
  props: {
    data: {
      type: Object,
      required: true
    },
    title: {
      type: String,
      default: ""
    },
    bgColor: {
      type: String,
      default: "#FFF"
    }
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
div.summary label {
  font-weight: bold;
  margin-right: 1rem;
}

div.summary>div>span {
  margin-right: 2rem;
}
</style>