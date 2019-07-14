<template>
  <b-card :title="event.name" :sub-title="this.$options.filters.format_distance(event.distance) + ' ' + event.event_type.description" class="mb-2" bg-variant="dark" text-variant="white">
    <h6 slot="footer">{{ event.scheduled_start | moment("M/D/YY h:mma") }} &mdash; {{ event.address.city }}, {{ event.address.state }}</h6>
  </b-card>
</template>

<script>
import '@/filters/event_filters.js';

export default {
  props: {
    event: Object
  }
}
</script>

<style>

</style>
