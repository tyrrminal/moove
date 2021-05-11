<template>
  <b-card title="Activity" class="activity">
    <b-list-group flush>
      <b-list-group-item
        ><label>Actual distance</label>:
        {{ activity.distance | formatDistance }}</b-list-group-item
      >
      <b-list-group-item
        ><label><template v-if="hasStoppedTime">Moving </template>Time</label>:
        {{ activity.result.net_time }}</b-list-group-item
      >
      <b-list-group-item v-if="activity.result.gross_time && hasStoppedTime"
        ><label>Total Time</label>:
        {{ activity.result.gross_time }}</b-list-group-item
      >
      <b-list-group-item v-if="activity.activity_type.description === 'Run'"
        ><label>Pace</label>: {{ activity.result.pace }}</b-list-group-item
      >
      <b-list-group-item v-else
        ><label>Speed</label>:
        {{ activity.result.speed | formatDistance }}</b-list-group-item
      >
      <b-list-group-item v-if="activity.temperature"
        ><label>Temperature</label>:
        {{ activity.temperature }}&deg;F</b-list-group-item
      >
    </b-list-group>
  </b-card>
</template>

<script>
import EventFilters from "@/mixins/EventFilters.js";

export default {
  mixins: [EventFilters],
  props: {
    activity: Object,
  },
  computed: {
    hasStoppedTime: function () {
      return this.activity.result.gross_time != this.activity.result.net_time;
    },
  },
};
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
