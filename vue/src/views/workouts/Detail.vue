<template>
  <b-container class="mt-3">
    <div v-if="workout">
      <h4 class="float-right">{{ workout.date | luxon(dtSettings) }}</h4>
      <h3>{{ workout.name }}</h3>

      <b-card no-body>
        <template #header>
          Activities
        </template>
        <b-card-body>
          <ActivityList v-if="workout.activities.length > 0" :items="workout.activities" />
          <b-link :to="{ name: 'edit-activity' }">
            <b-icon icon="plus" class="mr-1" />Add an Activity
          </b-link>
        </b-card-body>
      </b-card>
    </div>
  </b-container>
</template>

<script>
import ActivityList from "@/components/activity/List";

export default {
  name: "WorkoutDetail",
  components: {
    ActivityList
  },
  data: function () {
    return {
      id: this.$attrs.id,
      workout: null,
      dtSettings: { input: { zone: 'local' } }
    };
  },
  mounted() {
    this.getData();
  },
  methods: {
    getData: function () {
      this.$http.get(["workouts", this.id].join("/")).then(resp => this.workout = resp.data);
    },
  },
  computed: {
  }
};
</script>

<style>
</style>