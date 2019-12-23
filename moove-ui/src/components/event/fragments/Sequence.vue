<template>
  <b-nav small pills align="center">
    <b-nav-item
      disabled
      v-b-tooltip.hover
      title="Sequences are a once-per-year progression of the same Event Group"
    >Sequence:</b-nav-item>
    <b-nav-item :to="{ name: 'sequence', params: { sequence_id: id, user: 1 } }">All</b-nav-item>
    <b-nav-item
      v-for="e in completedEvents"
      :key="e.event.id"
      :to="{ name: 'event', params: { id: e.event.id, user: e.registration.user.username } }"
      :active="current == e.event.id"
    >{{ e.event | event_year }}</b-nav-item>
  </b-nav>
</template>

<script>
import "@/filters/event_filters.js";

export default {
  props: {
    id: Number,
    events: Array,
    current: Number
  },
  computed: {
    completedEvents: function() {
      return this.events
        .filter(e => e.hasOwnProperty("activity"))
        .sort((a, b) => a.event.scheduled_start > b.event.scheduled_start);
    }
  }
};
</script>

<style>
</style>
