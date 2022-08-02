<template>
  <b-jumbotron class="event-details py-2" border-variant="secondary">
    <h4>
      <b-link :to="{ name: 'activity', params: { id: activity.id } }">{{
          getActivityType(activity.activityTypeID).description
      }}
      </b-link>
    </h4>
    <b-form-group label="Start Time">
      {{
          activity.startTime
          | luxon({ input: { zone: "local" }, output: "f" })
      }}
    </b-form-group>
    <b-form-group label="Distance" v-if="activity.distance">
      {{ fillUnits(activity.distance) | formatDistance }}
    </b-form-group>
    <b-form-group label="Total Time" v-if="activity.duration">
      {{ activity.duration }}
    </b-form-group>
    <b-form-group label="Net Time" v-if="activity.netTime && activity.duration != activity.netTime">
      {{ activity.netTime }}
    </b-form-group>
    <b-form-group label="Average Pace" v-if="activity.pace">
      {{ fillUnits(activity.pace) | formatDistance }}
    </b-form-group>
    <b-form-group label="Avg. Speed" v-if="activity.speed">
      {{ fillUnits(activity.speed) | formatDistance }}
    </b-form-group>
    <b-form-group label="Temperature" v-if="activity.temperature">
      {{ activity.temperature }}° F
    </b-form-group>
    <b-form-group label="Heart Rate" v-if="activity.heartRate">
      {{ activity.heartRate }} bpm
    </b-form-group>
    <b-form-group label="Weight" v-if="activity.weight">
      {{ activity.weight }} lbs
    </b-form-group>
  </b-jumbotron>
</template>

<script>
import EventFilters from "@/mixins/events/Filters.js";
import UnitConversion from "@/mixins/UnitConversion.js";
import { mapGetters } from 'vuex';

export default {
  mixins: [EventFilters, UnitConversion],
  props: {
    activity: {
      type: Object,
      required: true
    },
  },
  computed: {
    ...mapGetters("meta", ["getActivityType"]),
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
