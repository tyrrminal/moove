<template>
  <b-container class="mt-3">
    <div v-if="workout">
      <div class="float-right">
        <h4 class="d-inline-block">{{ workout.date | luxon(dtSettings) }}</h4>
        <b-dropdown variant="outline-secondary" size="sm" class="d-inline-block ml-2">
          <template #button-content>
            <b-icon icon="gear" />
          </template>
          <b-dropdown-item :to="{ name: 'edit-workout', params: { workout: workout } }">
            <b-icon icon="pencil" class="mr-1" />Edit
          </b-dropdown-item>
          <b-dropdown-item @click="deleteWorkout">
            <b-icon variant="danger" icon="trash" class="mr-1" />Delete
          </b-dropdown-item>
        </b-dropdown>
      </div>
      <h3>{{ workout.name }}</h3>
      <b-card no-body>
        <template #header>
          Activities
        </template>
        <b-card-body>
          <ActivityList v-if="workout.activities.length > 0" :items="workout.activities" :editor="true" />
          <b-link :to="{ name: 'create-activity', params: { workoutID: workout.id } }">
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
    deleteWorkout: function () {
      this.$bvModal.msgBoxConfirm("This workout will be permanently deleted", {
        okVariant: "danger",
        okTitle: "Delete"
      }).then(value => {
        if (value) {
          this.$http.delete(["workouts", this.id].join("/"), { headers: { Accept: "text/plain" } })
            .then(resp => this.$router.push({ name: "workouts" }))
        }
      })
    }
  },
  computed: {
  }
};
</script>

<style>
</style>