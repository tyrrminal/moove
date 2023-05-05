<template>
  <b-container fluid>
    <b-row>
      <b-col cols="2" class="bg-info min-vh-100">
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

import OverallSummary from "@/components/activity/summary/Overall";
import SummaryPeriod from "@/components/activity/summary/Period";

export default {
  name: "ActivitySummary",
  components: {
    OverallSummary,
    SummaryPeriod,
  },
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
      return this.date == this.present
    }
  },
  methods: {
    periodStartDate: function (period) {
      if (!period) return null;
      if (period == 'week') return this.date;
      return DateTime.fromISO(this.date).startOf(period).toISODate();
    },
    loadPeriod: function (period = null) {
      let params = new URLSearchParams();
      let psd = this.periodStartDate(period);
      if (period) {
        params.append("start", psd);
        params.append("period", period);
      }
      let p = this.$http.get(["activities", "summary"].join("/"), { params })
        .then((resp) => {
          if (period) {
            this.$set(this.cache, psd + period, resp.data)
          } else {
            this.$set(this.cache, 'overall', resp.data)
          }
        })
      this.promises.push(p);
    },
    loadMore: function () {
      this.sections.forEach(s => {
        let key = this.periodStartDate(s) + s;
        if (!this.cache[key]) {
          this.loadPeriod(s)
        }
      });
    },
    changeDate: function (by) {
      let newDate = DateTime.fromISO(this.date).plus(by)
      if (newDate <= DateTime.now())
        this.date = newDate.toISODate();

      this.loadMore();
    },
  },
  watch: {
    date: {
      handler: function (newVal) {
        let d = DateTime.fromISO(newVal);
        if (d.toISODate() > this.present) this.date = this.present;
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

<style>

</style>