<template>
  <b-card title="Activity" class="activity">
    <b-list-group flush>
      <b-list-group-item
        ><label>Actual distance</label>:
        {{ activity.distance | formatDistance }}</b-list-group-item
      >
      <b-list-group-item
        ><label><template v-if="hasStoppedTime">Moving </template>Time</label>:
        {{ activity.result.netTime }}</b-list-group-item
      >
      <b-list-group-item v-if="activity.result.duration && hasStoppedTime"
        ><label>Total Time</label>:
        {{ activity.result.duration }}</b-list-group-item
      >
      <b-list-group-item v-if="activity.activityType.description === 'Run'"
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
import EventFilters from "@/mixins/events/Filters.js";

export default {
  mixins: [EventFilters],
  props: {
    activity: Object,
  },
  computed: {
    hasStoppedTime: function () {
      return this.activity.result.duration != this.activity.result.netTime;
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
