<template>
  <b-card no-body>
    <b-card-header>{{ sectionLabel }}</b-card-header>
    <b-card-body v-if="loaded">
      <b-progress class="mb-2" :max="summaryData.period.daysTotal" :title="progressTooltip">
        <b-progress-bar :value="summaryData.period.daysElapsed">
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
    startDate: {
      type: Object,
      required: false,
    },
  },
  data: function () {
    return {
      summaryData: {},
      date: null,
      loaded: false,
    };
  },
  mounted: function () {
    if (this.period)
      this.date = (this.startDate || DateTime.local())
        .plus({ days: this.period == "week" ? 1 : 0 })
        .startOf(this.period)
        .minus({ days: this.period == "week" ? 1 : 0 });

    this.load();
  },
  computed: {
    activities: function () {
      return this.summaryData.activities.filter((a) => a.distance > 0);
    },
    sectionLabel: function () {
      let l;
      switch (this.period) {
        case "month":
          l = DateTime.fromISO(this.date).toFormat("LLL yyyy");
          break;
        case "week":
          l = DateTime.fromISO(this.date).toFormat("'W'WW yyyy");
          break;
        case "year":
          l = DateTime.fromISO(this.date).get(this.period);
          break;
        default:
          l = "Overall";
      }
      return l;
    }, progressTooltip: function () {
      return this.$options.filters.percent(
        this.summaryData.period.daysElapsed / this.summaryData.period.daysTotal
      );
    },
    progressText: function () {
      if (
        this.summaryData.period.daysElapsed == this.summaryData.period.daysTotal
      )
        return `${this.summaryData.period.daysTotal} days`;
      return [
        this.summaryData.period.daysElapsed,
        this.summaryData.period.daysTotal,
      ].join("/");
    },
  },
  methods: {
    load: function () {
      this.loaded = false;
      let params = new URLSearchParams();
      if (this.period != null) {
        params.append("start", this.date.toISODate());
        params.append("period", this.period);
      }
      this.$http
        .get(["activities", "summary"].join("/"), { params })
        .then((resp) => {
          this.summaryData = resp.data;
          this.loaded = true;
        });
    },
    prevPeriod: function () {
      let f = {};
      f[this.period + "s"] = 1;
      this.date = this.date.minus(f);
    },
    nextPeriod: function () {
      let f = {};
      f[this.period + "s"] = 1;
      this.date = this.date.plus(f);
    },

  },
  watch: {
    date: function () {
      this.load();
    },
  },
};
</script>

<style>

</style>