<template>
  <div>
    <h4>Upcoming</h4>
    <Grid :events="upcomingEvents">
      <template #no-data><span v-show="loaded">No upcoming events</span></template>
    </Grid>

    <h4>Completed</h4>
    <Grid v-for="y in eventYears" :key="'grid' + y" :label="y" :events="eventsByYear[y]" />

    <template v-if="incompleteEvents.length">
      <h4>DNS/DNF</h4>
      <Grid :events="incompleteEvents" date-format="DATE_MED" v-bind="gridOptions" />
    </template>
  </div>
</template>

<script>
import { DateTime } from "luxon";

import Grid from "@/components/event/Grid";

export default {
  components: {
    Grid
  },
  props: {
    events: {
      type: Array,
      required: true
    },
    loaded: {
      type: Boolean,
      default: true
    },
    gridOptions: {
      type: Object,
      default: () => { }
    }
  },
  computed: {
    pastEvents: function () {
      return this.events.filter(e => DateTime.fromISO(e.eventActivity.scheduledStart) < DateTime.now())
    },
    completedEvents: function () {
      return this.pastEvents.filter(e => e.activity != null)
    },
    eventsByYear: function () {
      let years = {};
      this.completedEvents.forEach(e => {
        let y = DateTime.fromISO(e.eventActivity.scheduledStart).year
        if (!years[y]) years[y] = [];
        years[y].push(e);
      })
      return years;
    },
    eventYears: function () {
      return Object.keys(this.eventsByYear).sort((a, b) => b - a)
    },
    upcomingEvents: function () {
      let e = this.events.filter(e => DateTime.fromISO(e.eventActivity.scheduledStart) > DateTime.now())
      e.reverse();
      return e;
    },
    incompleteEvents: function () {
      return this.pastEvents.filter(e => e.activity == null)
    },
  }
}
</script>

<style scoped></style>
