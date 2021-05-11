<template>
  <b-card class="mb-2 text-center" :border-variant="border" :bg-variant="background" :text-variant="color">
    <b-card-title>{{ event.name }}<a v-if="event.url" :href="event.url" target="_blank">&nbsp;<font-awesome-icon icon="external-link-alt" /></a></b-card-title>
    <b-card-sub-title>{{ event.distance | format_distance_trim }} {{ event.event_type.description }}</b-card-sub-title>
    <h6 slot="footer">{{ event.scheduled_start | moment("M/D/YY h:mma") }}<template v-if="event.hasOwnProperty('address')"> &mdash; {{ event.address.city }}, {{ event.address.state }}</template></h6>
  </b-card>
</template>

<script>
import EventFilters from "@/mixins/EventFilters.js";

export default {
  mixins: [EventFilters],
  computed: {
    border:     function() { return this.isPublic ? "dark"  : "default"; },
    background: function() { return this.isPublic ? "light" : "dark";    },
    color:      function() { return this.isPublic ? "dark"  : "light";   },
  },
  props: {
    event: Object,
    isPublic: Boolean
  }
}
</script>

<style>

</style>
