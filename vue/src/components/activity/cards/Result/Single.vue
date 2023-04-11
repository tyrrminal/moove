<template>
  <div>
    <b-dropdown v-if="editable" class="float-right" variant="outline-secondary">
      <template #button-content>
        <b-icon icon="gear" />
      </template>
      <b-dropdown-item :to="{ name: 'edit-activity', params: { activity: editableActivity } }">
        <b-icon icon="pencil" class="mr-1" />Edit
      </b-dropdown-item>
      <b-dropdown-item @click="deleteActivity">
        <b-icon icon="trash" class="mr-1" variant="danger" />Delete
      </b-dropdown-item>
    </b-dropdown>
    <b-form-group label="Start Time">
      {{ result.startTime | luxon({ input: { zone: "local" }, output: "f" }) }}
    </b-form-group>
    <b-form-group label="Distance" v-if="result.distance">
      {{ fillUnits(result.distance) | formatDistance }}
    </b-form-group>
    <b-form-group label="Total Time" v-if="result.duration">
      {{ result.duration }}
    </b-form-group>
    <b-form-group label="Net Time" v-if="result.netTime && result.duration != result.netTime">
      {{ result.netTime }}
    </b-form-group>
    <b-form-group label="Average Pace" v-if="result.pace && activityType.hasPace">
      <span id="form-group-pace" class="pr-2">{{ fillUnits(result.pace) | formatDistance }}</span>
    </b-form-group>
    <b-form-group label="Avg. Speed" v-if="result.speed && activityType.hasSpeed">
      <span id="form-group-speed" class="pr-2">{{ fillUnits(result.speed) | formatDistance }}</span>
    </b-form-group>
    <b-form-group label="Temperature" v-if="result.temperature">
      {{ result.temperature }}° F
    </b-form-group>
    <b-form-group label="Heart Rate" v-if="result.heartRate">
      {{ result.heartRate }} bpm
    </b-form-group>
    <b-form-group label="Reps" v-if="result.repetitions != null">
      {{ result.repetitions }}
    </b-form-group>
    <b-form-group label="Weight" v-if="result.weight">
      {{ result.weight }} lbs
    </b-form-group>

    <b-tooltip v-if="result.speed && !activityType.hasSpeed" target="form-group-pace" placement="right">
      {{ fillUnits(result.speed) | formatDistance }}
    </b-tooltip>
    <b-tooltip v-if="result.pace && !activityType.hasPace" target="form-group-speed" placement="right">
      {{ fillUnits(result.pace) | formatDistance }}
    </b-tooltip>
  </div>
</template>

<script>
import EventFilters from "@/mixins/events/Filters.js";
import UnitConversion from "@/mixins/UnitConversion.js";

export default {
  mixins: [EventFilters, UnitConversion],
  props: {
    activity: {
      type: Object,
      required: true,
    },
    editable: {
      type: Boolean,
      default: true,
    },
  },
  methods: {
    deleteActivity: function () {
      this.$bvModal
        .msgBoxConfirm("This activity will be permamently deleted.", {
          okButton: "Delete",
          okVariant: "danger",
        })
        .then((value) => {
          if (value) {
            this.$http
              .delete(["activities", this.activity.id].join("/"), {
                headers: { Accept: "text/plain" },
              })
              .then((resp) => this.$router.push({ name: "activities" }));
          }
        });
    },
  },
  computed: {
    activityType: function () {
      return this.$store.getters["meta/getActivityType"](this.activity.activityTypeID)
    },
    result: function () {
      return this.activity.sets ? this.activity.sets[0] : this.activity;
    },
    hasStoppedTime: function () {
      return this.result.duration != this.result.netTime;
    },
    editableActivity: function () {
      if (this.activity.sets)
        return { ...this.activity, ...this.activity.sets[0] };
      return this.activity;
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
