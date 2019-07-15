<template>
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
