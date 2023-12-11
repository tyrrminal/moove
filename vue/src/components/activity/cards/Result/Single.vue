<template>
  <div>
    <b-row>

      <b-col>
        <ComparisonField label="Start Time" :lvalue="activityData.startTime" :rvalue="eventResultData.startTime"
          :comparator="compareDates"
          :formatter="v => $options.filters.luxon(v, { input: { zone: 'local' }, output: 'f' })" />

        <ComparisonField label="Distance" :lvalue="activityData.distance" :rvalue="eventResultData.distance"
          :comparator="compareDistances"
          :formatter="v => $options.filters.formatDistance({ ...v, units: getUnitOfMeasureByID(v.unitOfMeasureID) })" />
      </b-col>

      <b-col cols="2">
        <ComparisonField label="Total Time" :lvalue="activityData.duration" :rvalue="eventResultData.duration" />

        <ComparisonField label="Net Time" :lvalue="activityData.netTime" :rvalue="eventResultData.netTime"
          v-if="(activityData.netTime && (activityData.duration != activityData.netTime)) || (eventResultData.netTime && eventResultData.duration != eventResultData.netTime && eventResultData.netTime != activityData.netTime)" />
      </b-col>

      <b-col cols="2" v-if="paceSpeedToggle !== null" @click="paceSpeedToggle = !paceSpeedToggle" class="cursor-pointer">
        <ComparisonField v-if="paceSpeedToggle === true" label="Average Pace" :lvalue="activityData.pace"
          :rvalue="eventResultData.pace" :comparator="compareDistances"
          :formatter="v => $options.filters.formatDistance(fillUnits(v))" />

        <ComparisonField v-if="paceSpeedToggle === false" label="Average Speed" :lvalue="activityData.speed"
          :rvalue="eventResultData.speed" :comparator="compareDistances"
          :formatter="v => $options.filters.formatDistance(fillUnits(v))" />
      </b-col>

      <b-col cols="2">
        <ComparisonField label="Temperature" :lvalue="activityData.temperature" :rvalue="eventResultData.temperature"
          :formatter="v => `${v}° F`" />

        <ComparisonField label="Heart Rate" :lvalue="activityData.heartRate" :rvalue="eventResultData.heartRate"
          :formatter="v => `${v} bpm`" />
      </b-col>

      <b-col cols="2">
        <ComparisonField label="Reps" :lvalue="activityData.repetitions" :rvalue="eventResultData.repetitions" />

        <ComparisonField v-if="activityData.weight > 0 || eventResultData > 0" label="Weight"
          :lvalue="activityData.weight" :rvalue="eventResultData.weight" :formatter="v => `${v} lbs`" />
      </b-col>

    </b-row>

    <slot name="pre-controls"></slot>
    <slot name="controls">
      <b-button :to="{ name: 'edit-activity', params: { activity: editableActivity } }" size="sm" block pill>
        <b-icon icon="pencil" class="mr-1" />Modify
      </b-button>
      <b-button @click="deleteActivity" size="sm" block pill variant="danger">
        <b-icon icon="trash" class="mr-1" />Delete
      </b-button>
    </slot>
    <slot name="post-controls"></slot>

  </div>
</template>

<script>
import ComparisonField from "@/components/activity/cards/Result/ComparisonField.vue";
import EventFilters from "@/mixins/events/Filters.js";
import UnitConversion from "@/mixins/UnitConversion.js";
import { convertUnitValue } from "@/utils/unitConversion.js";
import { DateTime } from "luxon";

export default {
  components: {
    ComparisonField
  },
  mixins: [EventFilters, UnitConversion],
  props: {
    activity: {
      type: Object,
      required: true,
    },
    eventResult: {
      type: Object,
      required: false
    },
  },
  data: function () {
    return {
      paceSpeedToggle: null
    }
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
    getActivityType: function (id) {
      return this.$store.getters["meta/getActivityType"](id)
    },
    getUnitOfMeasureByID: function (id) {
      return this.$store.getters["meta/getUnitOfMeasure"](id)
    },
    compareDates: function (d1, d2) {
      if (d1 == null || d2 == null) return 0;
      let dt1 = DateTime.fromISO(d1).set({ seconds: 0 });
      let dt2 = DateTime.fromISO(d2).set({ seconds: 0 });
      return dt1 - dt2
    },
    compareDistances: function (d1, d2) {
      if (d1 == null || d2 == null) return 0;
      let dd1 = convertUnitValue(d1.value, this.getActivityType(d1.unitOfMeasureID));
      let dd2 = convertUnitValue(d2.value, this.getActivityType(d2.unitOfMeasureID));
      if (typeof dd1 == "number" && typeof dd2 == "number")
        return dd1.toFixed(2) - dd2.toFixed(2)
      return dd1.localeCompare(dd2)
    },
    initToggle: function () {
      if (!this.activityData || !this.activityType) this.pace = null;
      if (this.activityData.pace && this.activityType.hasPace) this.paceSpeedToggle = true;
      if (this.activityData.speed && this.activityType.hasSpeed) this.paceSpeedToggle = false;
    }
  },
  computed: {
    activityType: function () {
      return this.getActivityType(this.activity.activityTypeID)
    },
    activityData: function () {
      if (!this.activity) return {};
      return this.activity.sets ? this.activity.sets[0] : this.activity;
    },
    eventResultData: function () {
      if (!this.eventResult) return {};
      return this.eventResult.sets ? this.eventResult.sets[0] : this.eventResult
    },
    hasStoppedTime: function () {
      return this.activityData.duration != this.activityData.netTime;
    },
    editableActivity: function () {
      if (this.activity.sets)
        return { ...this.activity, ...this.activity.sets[0] };
      return this.activity;
    },
  },
  watch: {
    activityData: function (newV) {
      if (this.paceSpeedToggle === null && newV != null) this.initToggle();
    },
    activityType: function (newV) {
      if (this.paceSpeedToggle === null && newV != null) this.initToggle();
    }
  }
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
