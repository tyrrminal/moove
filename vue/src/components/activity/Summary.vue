<template>
  <b-card no-body>
    <b-card-header v-if="period"
      ><b-button size="sm" variant="none" class="mr-1" @click="prevPeriod"
        ><b-icon icon="chevron-left" /></b-button
      >{{ sectionLabel
      }}<b-button size="sm" variant="none" class="ml-1" @click="nextPeriod"
        ><b-icon icon="chevron-right" /></b-button
    ></b-card-header>
    <b-card-header v-else>Overall</b-card-header>
    <b-card-body v-if="loaded">
      <b-progress
        v-if="summaryData.period.daysTotal"
        class="mb-2"
        :max="summaryData.period.daysTotal"
        :title="progressTooltip"
      >
        <b-progress-bar :value="summaryData.period.daysElapsed">
          {{ progressText }}
        </b-progress-bar>
      </b-progress>
      <span v-else
        >{{ summaryData.period.daysElapsed | number("0,0") }} days ~
        {{ summaryData.period.years | number("0,0.00") }} years</span
      >
      <b-list-group flush>
        <b-list-group-item v-for="a in activities" :key="a.activityTypeID || 0">
          <h5 v-if="a.activityTypeID">
            {{ activityType(a.activityTypeID).description }}
          </h5>
          <h5 v-else>All Activities</h5>
          <b-progress
            v-if="a.nominal"
            height="1.5rem"
            :max="a.nominal.distance"
            :title="nominalProgressText(a)"
          >
            <b-progress-bar
              :value="a.distance"
              :variant="nominalProgressVariant(a.distance, a.nominal.distance)"
            >
              {{ a.distance | number("0,0.00") }}
              {{ unit(a.unitID).abbreviation }}
            </b-progress-bar>
          </b-progress>
          <span v-else>
            {{ a.distance | number("0,0.00") }}
            {{ unit(a.unitID).abbreviation }}
          </span>
          <template v-if="a.eventDistance">
            <h5>Events</h5>
            {{ a.eventDistance | number("0,0.00") }}
            {{ unit(a.unitID).abbreviation }}
          </template>
        </b-list-group-item>
      </b-list-group>
    </b-card-body>
    <b-card-body v-else><b-spinner /></b-card-body>
  </b-card>
</template>

<script>
const { DateTime } = require("luxon");
import { mapGetters } from "vuex";

export default {
  props: {
    period: {
      type: String,
      required: false,
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
    ...mapGetters("meta", {
      activityType: "getActivityType",
      unit: "getUnitOfMeasure",
    }),
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
    },
    progressTooltip: function () {
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
    nominalProgressVariant: function (d, n) {
      if (d >= n) return "success";
      if (d >= 0.8 * n) return "warning";
      return "danger";
    },
    nominalProgressText: function (a) {
      return [
        this.$options.filters.number(a.nominal.distance, "0,0"),
        this.unit(a.unitID).abbreviation,
        ["(", ")"].join(
          this.$options.filters.percent(a.distance / a.nominal.distance)
        ),
      ].join(" ");
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