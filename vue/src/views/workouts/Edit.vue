<template>
  <b-container fluid>
    <b-row>
      <b-col cols="2" class="min-vh-100 bg-dark pt-3">
        <b-button variant="primary" @click="save" block><b-icon icon="save" class="mr-2" />Save</b-button>
        <b-button variant="secondary" @click="cancel" block>Cancel</b-button>
      </b-col>
      <b-col>
        <h2>{{ title }}</h2>
        <b-form>
          <b-form-row>
            <b-col>
              <b-form-group label="Name">
                <b-input v-model="edit.name" />
              </b-form-group>
            </b-col>
          </b-form-row>
          <b-form-row>
            <b-col>
              <b-form-group label="Date">
                <b-datepicker v-model="edit.date" today-button />
              </b-form-group>
            </b-col>
            <b-col v-if="workout" cols="2">
              <b-form-group label="Activities">
                <b-checkbox v-model="edit.adjustActivityDates" :disabled="edit.date == workout.date">Adjust Date
                </b-checkbox>
              </b-form-group>
            </b-col>
          </b-form-row>
          <b-row v-if="error != null">
            <b-col>
              <b-alert variant="warning" :show="true">{{ error }}</b-alert>
            </b-col>
          </b-row>
        </b-form>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import { DateTime } from "luxon";
const cloneDeep = require("clone-deep");

export default ({
  data: function () {
    return {
      error: null,
      edit: {
        name: "Workout",
        date: DateTime.now().toISODate()
      }
    }
  },
  props: {
    workout: {
      type: Object,
      default: null
    }
  },
  mounted: function () {
    if (this.workout) {
      this.edit = cloneDeep(this.workout);
      delete (this.edit.activities);
      delete (this.edit.user);
      delete (this.edit.id);
    }
  },
  computed: {
    title: function () {
      if (this.workout == null) return 'Create New Workout'
      else return 'Edit Workout'
    }
  },
  methods: {
    cancel: function () {
      if (this.workout) this.$router.push({ name: 'workout', params: { id: this.workout.id } })
      else this.$router.push({ name: 'workouts' })
    },
    save: function () {
      let p;
      if (this.workout)
        p = this.$http.patch(["workouts", this.workout.id].join("/"), this.edit)
      else
        p = this.$http.post("workouts", this.edit)

      p.then(resp => this.$router.push({ name: 'workout', params: { id: resp.data.id } }))
        .catch(err => this.error = err.response.data.errors[0].message)
    }
  }
})
</script>
