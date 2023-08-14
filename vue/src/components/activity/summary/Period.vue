<template>
  <b-card no-body>
    <b-card-header>{{ sectionLabel }}</b-card-header>
    <template v-if="loaded">
      <b-progress v-if="periodIsIncomplete" class="squared-progress" :max="days" :title="progressTooltip">
        <b-progress-bar :value="daysElapsed">
          {{ progressTooltip }}
        </b-progress-bar>
      </b-progress>
      <b-card-body class="pt-1" v-if="activities[0].counts">
        <b-list-group flush>
          <SummaryElement v-for="a in activities" :key="(a.activityTypes || [])[0]?.activityTypeID" :activity="a"
            :context="{ period: period, start: date }" />
        </b-list-group>
      </b-card-body>
      <b-card-body v-else>
        <h4 class="text-center">{{ activities[0].label }}</h4>
      </b-card-body>
    </template>
    <b-card-body v-else><b-spinner /></b-card-body>
  </b-card>
</template>

<script>
import datePeriod from "@/mixins/datePeriod.js";
import { DateTime } from 'luxon';

import SummaryElement from "@/components/activity/summary/Element";

export default {
  name: "SummaryPeriod",
  components: {
    SummaryElement
  },
  mixins: [datePeriod],
  props: {
    period: {
      type: String,
      required: true,
    },
    date: {
      type: String,
      required: true,
    },
    summaryData: {
      type: Object,
      required: false
    }
  },
  computed: {
    startDate: function () {
      return DateTime.fromISO(this.periodData[0].startDate)
    },
    endDate: function () {
      return this.periodEnd(this.period)
    },
    days: function () {
      return DateTime.fromISO(this.endDate).diff(this.startDate, ['days']).days + 1
    },
    daysElapsed: function () {
      const now = DateTime.now().startOf('day');
      if (this.endDate < now) return this.days
      if (this.startDate > now) return 0;
      return DateTime.fromISO(this.activities[0].endDate).diff(this.startDate, ['days']).days + 1
    },
    loaded: function () {
      return this.periodData != null
    },
    periodData: function () {
      return this.summaryData[this.cacheKey()]
    },
    activities: function () {
      switch (this.periodData.length) {
        case 0: null; // No data
        case 2: return [this.periodData[1]]; // Single activity type
        case 1: // No activities
        default: return this.periodData
      }
    },
    periodIsIncomplete: function () {
      return this.daysElapsed < this.days
    },
    sectionLabel: function () {
      let l;
      switch (this.period) {
        case "week":
          l = DateTime.fromISO(this.date).plus({ days: 1 }).toFormat("'W'WW kkkk");
          break;
        case "month":
          l = DateTime.fromISO(this.date).toFormat("LLL");
          break;
        case "year":
          l = DateTime.fromISO(this.date).get(this.period);
          break;
      }
      if (this.loaded && this.daysElapsed) l += ` (${this.progressText})`;
      return l;
    },
    progressTooltip: function () {
      return this.$options.filters.percent(
        this.daysElapsed / this.days
      );
    },
    progressText: function () {
      if (!this.loaded) return "";
      if (this.daysElapsed >= this.days)
        return `${this.days} days`;
      return `Day ${this.daysElapsed} of ${this.days}`
    },
  },
};
</script>

<style scoped>
.squared-progress {
  border-radius: 0 !important;
}
</style>
