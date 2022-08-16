<template>
  <b-container class="my-2">
    <h2 v-if="workout">
      <h4 class="float-right">{{ workout.date | luxon(dtSettings) }}</h4>
      <b-link :to="{ name: 'workout', params: { id: workout.id } }">{{ workout.name }}</b-link>
    </h2>
    <ActivityCard v-if="activity" :activity="activity" no-link-to-activity class="mt-3" />
  </b-container>
</template>

<script>
import ActivityCard from "@/components/activity/cards/Result";
import UnitConversion from "@/mixins/UnitConversion.js";

export default {
  components: {
    ActivityCard
  },
  mixins: [UnitConversion],
  data: function () {
    return {
      id: this.$attrs.id,
      activity: null,
      workout: null,

      dtSettings: { input: { zone: 'local' } }
    };
  },
  mounted() {
    this.getData();
  },
  methods: {
    getData: function () {
      this.$http.get(["activities", this.id].join("/")).then(resp => {
        this.activity = resp.data;
        this.$http.get(["workouts", this.activity.workoutID].join("/")).then(resp => this.workout = resp.data)
      });
    },
  },
};
</script>

<style>
</style>