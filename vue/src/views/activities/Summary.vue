<template>
  <b-container fluid>
    <b-row>
      <b-col cols="3" class="bg-info min-vh-100">
        <OverallSummary :summaryData="cache.overall" />
      </b-col>
      <b-col class="mt-3">
        <b-button-group size="sm" class="float-right">
          <b-button variant="outline-secondary" @click="changeDate({ weeks: -1 })"><b-icon
              icon="chevron-left" /></b-button>
          <b-datepicker button-variant="outline-secondary" button-only v-model="date" size="sm" right today-button
            :max="datepickerMax" />
          <b-button variant="outline-secondary" @click="changeDate({ weeks: 1 })" :disabled="atMaxDate"><b-icon
              icon="chevron-right" /></b-button>
        </b-button-group>
        <h4>Week of {{ date.toString() | luxon({ output: "date_med" }) }}</h4>
        <b-row>
          <b-col v-for="(s, i) in sections" :key="i" cols="4">
            <SummaryPeriod :period="s" :date="periodStartDate(s)" :summaryData="cache" />
          </b-col>
        </b-row>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import { DateTime } from 'luxon';

import datePeriod from "@/mixins/datePeriod.js";

import OverallSummary from "@/components/activity/summary/Overall";
import SummaryPeriod from "@/components/activity/summary/Period";

export default {
  name: "ActivitySummary",
  components: {
    OverallSummary,
    SummaryPeriod,
  },
  mixins: [datePeriod],
  data: function () {
    let startDate = DateTime.now().startOf('week').minus({ days: 1 }).toISODate();
    return {
      date: startDate,
      present: startDate,
      sections: ["year", "month", "week"],

      cache: {},
      promises: [],
    };
  },
  mounted: function () {
    this.changeDate({ days: 0 });
    Promise.allSettled(this.promises).then(() => { this.promises = []; this.loadPeriod() });
  },
  computed: {
    datepickerMax: function () {
      return DateTime.fromISO(this.present).plus({ weeks: 1 }).toISODate();
    },
    atMaxDate: function () {
      return this.date >= this.datepickerMax
    }
  },
  methods: {
    periodStartDate: function (period) {
      if (!period) return null;
      const basis = DateTime.fromISO(this.date);
      let psd;
      if (period == 'week') {
        psd = basis
          .startOf('week')
          .plus({ week: basis.weekdayShort === 'Sun' ? 1 : 0 })
          .minus({ day: 1 })
      } else
        psd = basis.startOf(period);
      return psd.toISODate()
    },
    periodEndDate: function (period) {
      let psd = DateTime.fromISO(this.periodStartDate(period));
      let nextPeriod = {};
      nextPeriod[`${period}s`] = 1;
      let ped = psd.plus(nextPeriod).minus({ days: 1 })
      return ped.toISODate();
    },
    loadPeriod: function (period = null) {
      let params = new URLSearchParams();
      let psd = this.periodStartDate(period);
      let ped = this.periodEndDate(period);
      params.append('partition', 'activityType.all');
      params.append('combine', true);
      params.append('withRollup', true);
      if (period) {
        params.append("start", psd);
        params.append("end", DateTime.fromISO(ped) > DateTime.now() ? 'current' : ped)
      }
      let p = this.$http.get("activities/summary", { params })
        .then((resp) => {
          let d = resp.data
          params.set('combine', false)
          params.append('event', true)
          this.$http.get("activities/summary", { params }).then(resp => {
            resp.data.forEach(ed => {
              d.find(x => x.label == ed.label).event = ed
            })
            this.addToCache(d, period)
          })
        })
      this.promises.push(p);
    },
    loadMore: function () {
      this.sections.forEach(s => {
        if (!this.cache[this.cacheKey(this.periodStartDate(s), s)]) {
          this.loadPeriod(s)
        }
      });
    },
    addToCache: function (data, period) {
      let psd = this.periodStartDate(period);
      let ped = this.periodEndDate(period);
      if (data.length == 0) data.push({
        startDate: psd,
        endDate: ped,
        label: "No Activities"
      })
      this.$set(this.cache, this.cacheKey(psd, period), data.sort((a, b) => {
        if (!a.activityTypes) return -1;
        if (!b.activityTypes) return 1;
        return a.activityTypes[0].id - b.activityTypes[0].id
      }))
    },
    changeDate: function (by) {
      let newDate = DateTime.fromISO(this.date).plus(by);
      if (newDate <= DateTime.fromISO(this.datepickerMax))
        this.date = newDate.toISODate();

      this.loadMore();
    },
  },
  watch: {
    date: {
      handler: function (newVal) {
        let d = DateTime.fromISO(newVal);
        if (d.toISODate() > this.datepickerMax) this.date = this.datepickerMax;
        else if (d.weekday != 7) {
          d = d.startOf('week').minus({ days: 1 })
          this.date = d.toISODate();
        }
        this.loadMore();
      }
    }
  }
};
</script>

<style></style>