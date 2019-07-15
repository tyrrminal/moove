<template>
  <b-card :sub-title="this.$options.filters.format_distance(event.distance) + ' ' + event.event_type.description" class="mb-2" bg-variant="dark" text-variant="white">
    <b-card-title>{{ event.name }} <a v-if="event.url" :href="event.url" target="_blank"><font-awesome-icon icon="external-link-alt" /></a></b-card-title>
    <h6 slot="footer">{{ event.scheduled_start | moment("M/D/YY h:mma") }}<template v-if="event.hasOwnProperty('address')"> &mdash; {{ event.address.city }}, {{ event.address.state }}</template></h6>
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
