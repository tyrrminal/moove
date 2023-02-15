<template>
  <b-list-group-item>
    <template v-if="metaLoaded">
      <h5>{{ typeDescription }}</h5>

      <b-progress v-if="activity.nominal" height="0.5rem" :max="activity.nominal.distance" :title="nominalProgressText"
        class="mb-2">
        <b-progress-bar :value="activity.distance" :variant="nominalProgressVariant" />
      </b-progress>

      <b-badge :to="{ name: 'activities', query: qs() }" :variant="nominalProgressVariant">
        {{ formattedDistance(activity.distance) }}
      </b-badge>
      <span v-if="activity.eventDistance"> /
        <b-badge :to="{ name: 'activities', query: qs(true) }" variant="none">
          {{ formattedDistance(activity.eventDistance) }}
        </b-badge>
      </span>

    </template>
  </b-list-group-item>
</template>

<script>
import { mapGetters } from "vuex";
import { DateTime } from "luxon";

export default {
  name: "SummaryElement",
  props: {
    activity: {
      type: Object,
      required: true
    },
    context: {
      type: Object,
      required: false
    }
  },
  computed: {
    ...mapGetters("meta", {
      metaLoaded: "isLoaded",
      getActivityType: "getActivityType",
      getUnitOfMeasure: "getUnitOfMeasure",
    }),
    typeDescription: function () {
      if (this.activityType) return this.activityType.description;
      return 'All Activities';
    },
    activityType: function () {
      return this.getActivityType(this.activity.activityTypeID)
    },
    unit: function () {
      return this.getUnitOfMeasure(this.activity.unitID)
    },
    nominalProgressVariant: function () {
      if (this.activity.nominal) {
        let d = this.activity.distance;
        let n = this.activity.nominal.distance
        if (d >= n) return "success";
        if (d >= 0.8 * n) return "warning";
        return "danger";
      }
      return "none"
    },
    nominalProgressText: function () {
      if (this.activity.nominal && this.activity.nominal.distance)
        return this.$options.filters.percent(this.activity.distance / this.activity.nominal.distance)
          + ' of ' + this.formattedDistance(this.activity.nominal.distance)
      return "";
    },
  },
  methods: {
    formattedDistance: function (d) {
      return this.$options.filters.number(d, "0,0.00") + ' ' + this.unit.abbreviation
    },
    qs: function (withEvent) {
      let q = {};
      if (withEvent != null)
        q["event"] = withEvent;
      if (this.activity.activityTypeID)
        q["activityTypeID"] = this.activity.activityTypeID
      if (this.context) {
        q["start"] = this.context.start;
        let d = DateTime.fromISO(this.context.start);
        let r = {}; r[this.context.period] = 1;
        q["end"] = d.plus(r).minus({ days: 1 }).toISODate();
      }
      return q;
    }
  }
}
</script>

<style scoped>

</style>