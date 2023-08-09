<template>
  <b-list-group-item>
    <template v-if="metaLoaded">
      <h5>{{ typeDescription }}</h5>

      <b-progress v-if="showNominal" height="0.5rem" :max="normalizedNominalValue" :title="nominalProgressText"
        v-b-tooltip.bottom class="mb-2" :striped="!activity.distance.nominal?.value">
        <b-progress-bar :value="normalizedValue" :variant="nominalProgressVariant" />
      </b-progress>

      <b-badge :to="{ name: 'activities', query: qs() }" :variant="nominalProgressVariant">
        {{ formattedDistance(activity.distance.total) }}
      </b-badge>
      <span v-if="activity.event?.distance.total?.value"> /
        <b-badge :to="{ name: 'activities', query: qs(true) }" variant="none">
          {{ formattedDistance(activity.event.distance.total) }}
        </b-badge>
      </span>
    </template>
  </b-list-group-item>
</template>

<script>
import { mapGetters } from "vuex";
import { DateTime } from "luxon";

import { convertUnitValue } from "@/utils/unitConversion.js"

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
    },
    hideNominal: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapGetters("meta", {
      metaLoaded: "isLoaded",
      getActivityType: "getActivityType",
      getUnitOfMeasure: "getUnitOfMeasure",
    }),
    showNominal: function () {
      return this.activity.distance.nominal && !this.hideNominal;
    },
    typeDescription: function () {
      return this.activity.label;
    },
    activityType: function () {
      let t = this.activity.activityTypes;
      if (t) t = t[0]
      return this.getActivityType(t?.id)
    },
    normalizedValue: function () {
      return convertUnitValue(this.activity.distance.total.value, this.getUnitOfMeasure(this.activity.distance.total.unitOfMeasureID))
    },
    normalizedNominalValue: function () {
      return convertUnitValue(this.activity.distance.nominal.value, this.getUnitOfMeasure(this.activity.distance.nominal.unitOfMeasureID))
    },
    nominalProgressVariant: function () {
      if (this.showNominal) {
        let d = this.normalizedValue;
        let n = this.normalizedNominalValue;
        if (d >= n) return "success";
        if (d >= 0.8 * n) return "warning";
        return "danger";
      }
      return "none"
    },
    nominalProgressText: function () {
      if (this.activity.distance.nominal?.value)
        return this.$options.filters.percent(this.normalizedValue / this.normalizedNominalValue)
          + ' of ' + this.formattedDistance(this.activity.distance.nominal)
      return "";
    },
  },
  methods: {
    formattedDistance: function (d) {
      return `${this.$options.filters.number(d.value, "0,0.00")} ${this.getUnitOfMeasure(d.unitOfMeasureID).abbreviation}`
    },
    qs: function (withEvent) {
      let q = {};
      if (withEvent != null)
        q["event"] = withEvent;
      if (this.activity.activityTypes)
        q["activityTypeID"] = this.activity.activityTypes[0].id
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

<style scoped></style>