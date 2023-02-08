<template>
  <b-list-group-item>
    <template v-if="metaLoaded">
      <h5 v-if="a.activityTypeID">
        {{ activityType(a.activityTypeID).description }}
      </h5>
      <h5 v-else>All Activities</h5>
      <b-progress v-if="a.nominal" height="1.5rem" :max="a.nominal.distance" :title="nominalProgressText(a)"
        class="mb-2">
        <b-progress-bar :value="a.distance" :variant="nominalProgressVariant(a.distance, a.nominal.distance)">
          {{ a.distance | number("0,0.00") }}
          {{ unit(a.unitID).abbreviation }}
        </b-progress-bar>
      </b-progress>
      <span v-else>
        {{ a.distance | number("0,0.00") }}
        {{ unit(a.unitID).abbreviation }}
      </span>
      <template v-if="a.eventDistance">
        <h5>Events</h5>
        {{ a.eventDistance | number("0,0.00") }}
        {{ unit(a.unitID).abbreviation }}
      </template>
    </template>
  </b-list-group-item>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  name: "SummaryElement",
  props: {
    activity: {
      type: Object,
      required: true
    }
  },
  computed: {
    ...mapGetters("meta", {
      metaLoaded: "isLoaded",
      activityType: "getActivityType",
      unit: "getUnitOfMeasure",
    }),
    a: function () {
      return this.activity
    },
  },
  methods: {
    nominalProgressVariant: function (d, n) {
      if (d >= n) return "success";
      if (d >= 0.8 * n) return "warning";
      return "danger";
    },
    nominalProgressText: function (a) {
      return [
        this.$options.filters.number(a.nominal.distance, "0,0"),
        this.unit(a.unitID).abbreviation,
        ["(", ")"].join(
          this.$options.filters.percent(a.distance / a.nominal.distance)
        ),
      ].join(" ");
    },
  }
}
</script>

<style scoped>

</style>