<template>
  <b-card title="Activity" class="activity">
    <b-list-group flush>
      <b-list-group-item><label>Actual distance</label>: {{ activity.distance | format_distance }}</b-list-group-item>
      <b-list-group-item><label>Moving Time</label>: {{ activity.result.net_time }}</b-list-group-item>
      <b-list-group-item v-if="activity.result.gross_time"><label>Total Time</label>: {{ activity.result.gross_time }}</b-list-group-item>
      <b-list-group-item v-if="activity.activity_type.description === 'Run'"><label>Pace</label>: {{ activity.result.pace }}</b-list-group-item>
      <b-list-group-item v-else><label>Speed</label>: {{ activity.result.speed | format_distance }}</b-list-group-item>
      <b-list-group-item v-if="activity.temperature"><label>Temperature</label>: {{ activity.temperature }}&deg;F</b-list-group-item>
    </b-list-group>
  </b-card>
</template>

<script>
import '@/filters/event_filters.js';

export default {
  props: {
    activity: Object
  }
}
</script>

<style scoped>
.activity .list-group-item {
  text-align: left;
}
.activity label {
  width: 8rem;
  text-align: right;
}
</style>
