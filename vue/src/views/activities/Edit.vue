<template>
  <b-container fluid>
    <b-row>
      <b-col cols="2" class="min-vh-100 bg-dark pt-3">
        <b-button variant="primary" :disabled="!validated" @click="save" block><b-icon icon="save"
            class="mr-2" />Save</b-button>
        <b-button variant="secondary" class="mr-2" @click="$router.back()" block>Cancel</b-button>
      </b-col>
      <b-col v-if="workout">
        <h4 class="float-right">{{ workout.date | luxon(dtSettings) }}</h4>
        <h2>{{ headerLabel }} <b-link :to="{ name: 'workout', params: { id: workout.id } }">{{
          workout.name
        }}</b-link>
        </h2>
        <b-form-row>
          <b-col cols="6">
            <b-form-group label="Activity Type" label-class="font-weight-bold">
              <v-select :options="getActivityTypes" label="description" :disabled="activityTypeID != null"
                :clearable="false" :reduce="type => type.id" v-model="edit.activityTypeID"></v-select>
            </b-form-group>
          </b-col>
          <b-col offset="3">
            <b-form-group label="Who Can See">
              <b-select :options="getVisibilityTypes" value-field="id" text-field="description"
                v-model="edit.visibilityTypeID" />
            </b-form-group>
          </b-col>
        </b-form-row>
        <b-form-row>
          <b-col cols="4">
            <b-form-group label="Activity Start">
              <TextDateTimePicker v-model="edit.startTime" size="sm" button-variant="secondary" />
            </b-form-group>
          </b-col>
          <b-col offset="5">
            <b-form-group v-if="activityType != null && activityType.hasMap && activity != null && activity.hasMap"
              label="Who Can See Map">
              <b-select :options="getVisibilityTypes" value-field="id" text-field="description"
                v-model="edit.mapVisibilityTypeID" />
            </b-form-group>
          </b-col>
        </b-form-row>
        <b-jumbotron class="py-2" v-if="activityType != null">
          <template #lead>
            <p class="lead">Activity Details</p>
          </template>
          <b-form-row>
            <b-col v-if="activityType.hasDistance" cols="3">
              <b-form-group label="Distance">
                <b-input-group>
                  <b-input number v-model="edit.distance.value" />
                  <template #append>
                    <b-select :options="uomForType('Distance')" value-field="id" text-field="abbreviation"
                      v-model="edit.distance.unitOfMeasureID" />
                  </template>
                </b-input-group>
              </b-form-group>
            </b-col>
            <b-col v-if="activityType.hasDuration" cols="2">
              <b-form-group :label="activityType.hasDistance ? 'Total/Gross Time' : 'Time'">
                <b-timepicker v-model="edit.duration" :hour12="false" :show-seconds="true" :hide-header="true"
                  label-no-time-selected="--:--:--" reset-button />
              </b-form-group>
            </b-col>
            <b-col v-if="activityType.hasDuration && activityType.hasDistance" cols="2">
              <b-form-group label="Moving/Net Time">
                <b-timepicker v-model="edit.netTime" :hour12="false" :show-seconds="true" :hide-header="true"
                  label-no-time-selected="--:--:--" reset-button />
              </b-form-group>
            </b-col>
            <b-col cols="3" v-if="activityType.hasPace">
              <b-form-group label="Pace">
                <b-input-group>
                  <b-timepicker v-model="edit.pace.value" :hour12="false" :show-seconds="true" :hide-header="true"
                    label-no-time-selected="--:--:--" reset-button />
                  <template #append>
                    <b-select :options="uomForType('Rate').filter(u => u.inverted)" value-field="id"
                      text-field="abbreviation" v-model="edit.pace.unitOfMeasureID" />
                  </template>
                </b-input-group>
              </b-form-group>
            </b-col>
            <b-col cols="3" v-if="activityType.hasSpeed">
              <b-form-group label="Speed">
                <b-input-group>
                  <b-input v-model="edit.speed.value" number />
                  <template #append>
                    <b-select :options="uomForType('Rate').filter(u => !u.inverted)" value-field="id"
                      text-field="abbreviation" v-model="edit.speed.unitOfMeasureID" />
                  </template>
                </b-input-group>
              </b-form-group>
            </b-col>
            <b-col v-if="activityType.hasDistance && activityType.hasDuration" offset="1" cols="1">
              <b-dropdown class="mt-4" variant="primary" size="sm">
                <template #button-content>
                  <b-icon icon="calculator" class="mr-1" />
                </template>
                <b-dropdown-item @click="recalculatePace" v-if="activityType.hasPace" :disabled="!canRecalculatePace">
                  Calculate Pace</b-dropdown-item>
                <b-dropdown-item @click="recalculateSpeed" v-if="activityType.hasSpeed" :disabled="!canRecalculateSpeed">
                  Calculate Speed</b-dropdown-item>
                <b-dropdown-item @click="recalculateDistance" :disabled="!canRecalculateDistance">
                  Calculate Distance</b-dropdown-item>
                <b-dropdown-item @click="recalculateTime" :disabled="!canRecalculateTime">
                  Calculate Time</b-dropdown-item>
              </b-dropdown>
            </b-col>
            <b-col cols="2" v-if="activityType.hasRepeats">
              <b-form-group label="Reps">
                <b-input number v-model="edit.repetitions" />
              </b-form-group>
            </b-col>
            <b-col cols="2">
              <b-form-group label="Weight" :description="activityType.hasDistance ? 'Carry (lbs)' : 'Lift (lbs)'">
                <b-input number v-model="edit.weight" />
              </b-form-group>
            </b-col>
          </b-form-row>
          <b-form-row>
            <b-col cols="2">
              <b-form-group label="Heart Rate" description="Beats/minute (bpm)">
                <b-input number v-model="edit.heartRate" />
              </b-form-group>
            </b-col>
            <b-col cols="2">
              <b-form-group label="Temperature" description="Ambient (ºF)">
                <b-input number v-model="edit.temperature" />
              </b-form-group>
            </b-col>
          </b-form-row>
        </b-jumbotron>
        <b-form-row>
          <b-col cols="6">
            <b-form-group label="Notes">
              <b-textarea v-model="edit.note" />
            </b-form-group>
          </b-col>
          <b-col class="text-right">
            <b-alert class="text-left" :show="error != null" variant="warning">{{ error }}</b-alert>
          </b-col>
        </b-form-row>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import { mapGetters } from "vuex";
const cloneDeep = require("clone-deep");
import { DateTime } from "luxon";

import { convertUnitValue, hmsToHours, minutesToHms } from "@/utils/unitConversion.js";
import TextDateTimePicker from "@/components/TextDateTimePicker";

export default {
  components: {
    TextDateTimePicker
  },
  data: function () {
    return {
      error: null,
      edit: {
        workoutID: this._workoutID,
        activityTypeID: this._activityTypeID,
        group: this._group,
        visibilityTypeID: 3,
        startTime: DateTime.now().toISO(),
        pace: {
          value: null,
          unitOfMeasureID: 6
        },
        speed: {
          value: null,
          unitOfMeasureID: 3
        },
        distance: {
          value: null,
          unitOfMeasureID: 1
        },
        duration: null,
        netTime: null,
        repetitions: null,
        heartRate: null,
        temperature: null,
        weight: null,
        mapVisibilityTypeID: 3,
        note: ''
      },
      workout: null,
      dtSettings: { input: { zone: 'local' }, output: { format: "date_med" } },
      context: {
        workoutID: null,
        activityTypeID: null,
        group: null
      }
    }
  },
  props: {
    activity: {
      type: Object,
      default: null
    },
    workoutID: {
      type: Number,
      default: null
    },
    activityTypeID: {
      type: Number,
      default: null,
    },
    group: {
      type: Number,
      default: null
    }
  },
  mounted: function () {
    if (this.activity != null) {
      this.edit = cloneDeep(this.activity);
    }
    this.$http.get(["workouts", this._workoutID].join("/")).then(resp => {
      this.workout = resp.data;
      let d = DateTime.fromISO(this.workout.date);
      if (this.edit.startTime == null)
        this.edit.startTime = DateTime.fromISO(this.edit.startTime).set({ year: d.year, month: d.month, day: d.day }).toISO();
    });
  },
  methods: {
    uomForType: function (t) {
      return this.$store.getters["meta/getUnitsOfMeasure"].filter(uom => uom.type.toLowerCase() == t.toLowerCase())
    },
    save: function () {
      let activity = cloneDeep(this.edit);
      activity.workoutID = this.workout.id;
      if (!this.activityType.hasDistance) delete (activity.distance);
      if (!this.activityType.hasRepeats) delete (activity.repetitions);
      if (!this.activityType.hasDuration || !this.activityType.hasDistance) { delete (activity.netTime); }
      if (!this.activityType.hasDuration) { delete (activity.duration); }
      if (!this.activityType.hasSpeed) delete (activity.speed);
      if (!this.activityType.hasPace) delete (activity.pace);
      if (!this.activityType.hasMap) delete (activity.mapVisibilityTypeID);
      ["temperature", "weight", "heartRate"].forEach(l => { if (activity[l] === "") delete (activity[l]) });
      let p;
      if (this.activity != null)
        p = this.$http.patch(["activities", this.activity.id].join("/"), activity);
      else
        p = this.$http.post("activities", activity);
      p.then(resp => {
        this.$router.push({ name: 'activity', params: { id: resp.data.id } })
      })
        .catch(err => this.error = err.response.data.errors[0].message)
    },
    recalculateDistance: function () {
      let r = this.normalizedRate;
      let t = this.normalizedTime;
      let d = convertUnitValue(r * t, this.uomForType('Distance').find(u => u.normalUnitID == null), this.getUnitOfMeasure(this.edit.distance.unitOfMeasureID));
      this.edit.distance.value = Number(d.toPrecision(3));
    },
    recalculateTime: function () {
      let r = this.normalizedRate;
      let d = this.normalizedDistance;
      let t = d / r;
      this.edit.netTime = minutesToHms(60 * t);
    },
    recalculatePace: function () {
      let t = this.normalizedTime;
      let d = this.normalizedDistance;
      let r = convertUnitValue(d / t, this.uomForType('Rate').find(u => u.normalUnitID == null), this.getUnitOfMeasure(this.edit.pace.unitOfMeasureID)); // Convert rate from MPH to target units (minutes/xxx)
      this.edit.pace.value = minutesToHms(r);
    },
    recalculateSpeed: function () {
      let t = this.normalizedTime;
      let d = this.normalizedDistance;
      let r = convertUnitValue(d / t, this.uomForType('Rate').find(u => u.normalUnitID == null), this.getUnitOfMeasure(this.edit.speed.unitOfMeasureID)); // Convert rate from MPH to target units
      this.edit.speed.value = Number(r.toPrecision(4));
    }
  },
  computed: {
    ...mapGetters('meta', ['getActivityTypes', 'getVisibilityTypes', 'getUnitOfMeasure']),
    _workoutID: function () {
      return this.workoutID ?? this.edit.workoutID
    },
    _activityTypeID: function () {
      return this.activityTypeID ?? this.edit.activityTypeID
    },
    _group: function () {
      return this.group ?? this.edit.group
    },
    normalizedDistance: function () {
      return convertUnitValue(this.edit.distance.value, this.getUnitOfMeasure(this.edit.distance.unitOfMeasureID)); // Normalize distance to miles
    },
    normalizedTime: function () {
      return hmsToHours(this.edit.netTime ?? this.edit.duration);
    },
    normalizedRate: function () {
      if (this.activityType.hasSpeed)
        return convertUnitValue(this.edit.speed.value, this.getUnitOfMeasure(this.edit.speed.unitOfMeasureID)); // Normalize speed to MPH
      else if (this.activityType.hasPace)
        return convertUnitValue(hmsToHours(this.edit.pace.value) * 60, this.getUnitOfMeasure(this.edit.pace.unitOfMeasureID)); // Normalize pace to MPH
      return null;
    },
    hasTime: function () {
      return (this.edit.duration != null && this.edit.duration != "") || (this.edit.netTime != null && this.edit.netTime != "")
    },
    hasPace: function () {
      return this.activityType.hasPace && this.edit.pace.value != null && this.edit.pace.value != ""
    },
    hasSpeed: function () {
      return this.activityType.hasSpeed && this.edit.speed != null && this.edit.speed != ""
    },
    hasDistance: function () {
      return this.edit.distance.value != null && this.edit.distance.value != ""
    },
    canRecalculatePace: function () {
      return this.hasDistance && this.hasTime
    },
    canRecalculateSpeed: function () {
      return this.hasDistance && this.hasTime
    },
    canRecalculateDistance: function () {
      return (this.hasPace || this.hasSpeed) && this.hasTime
    },
    canRecalculateTime: function () {
      return (this.hasPace || this.hasSpeed) && this.hasDistance
    },
    validated: function () {
      if (!this.edit.activityTypeID) return false;
      if (!this.edit.startTime) return false;
      return true;
    },
    activityType: function () {
      return this.$store.getters["meta/getActivityType"](this.edit.activityTypeID);
    },
    headerLabel: function () {
      if (this.group != null)
        return 'Add Set to'
      else if (this.activity != null)
        return 'Edit Activity on';
      else
        return 'Add Activity to'
    },
  },
}
</script>

<style></style>
