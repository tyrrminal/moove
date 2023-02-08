<template>
  <b-card no-body>
    <b-card-header>{{ sectionLabel }}</b-card-header>
    <b-card-body v-if="loaded">
      <b-progress class="mb-2" :max="periodData.period.daysTotal" :title="progressTooltip">
        <b-progress-bar :value="periodData.period.daysElapsed">
          {{ progressText }}
        </b-progress-bar>
      </b-progress>
      <b-list-group flush>
        <SummaryElement v-for="a in activities" :key="a.activityTypeID || 0" :activity="a" />
      </b-list-group>
    </b-card-body>
    <b-card-body v-else><b-spinner /></b-card-body>
  </b-card>
</template>

<script>
import { DateTime } from 'luxon';

import SummaryElement from "@/components/activity/summary/Element";

export default {
  name: "SummaryPeriod",
  components: {
    SummaryElement
  },
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
    loaded: function () {
      return this.periodData != null
    },
    periodData: function () {
      return this.summaryData[this.date + this.period]
    },
    activities: function () {
      return this.periodData.activities.filter((a) => a.distance > 0);
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
      return l;
    },
    progressTooltip: function () {
      return this.$options.filters.percent(
        this.periodData.period.daysElapsed / this.periodData.period.daysTotal
      );
    },
    progressText: function () {
      if (
        this.periodData.period.daysElapsed == this.periodData.period.daysTotal
      )
        return `${this.periodData.period.daysTotal} days`;
      return [
        this.periodData.period.daysElapsed,
        this.periodData.period.daysTotal,
      ].join("/");
    },
  },
};
</script>

<style>

</style>