<template>
  <div class="mt-3">
    <label>Events (completed/all)</label>
    <p class="font-weight-bold text-monospace">{{ completedEvents.length }} / {{ events.length }}</p>
    <label>Total Fees</label>
    <p class="font-weight-bold text-monospace">{{ totalFees.toFixed(2) | currency }}</p>
    <label>Total Distance</label>
    <p class="font-weight-bold text-monospace">{{ totalDistance.toFixed(2) }} miles</p>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import { convertUnitValue } from "@/utils/unitConversion.js";

export default {
  props: {
    events: {
      type: Array,
      required: true
    }
  },
  computed: {
    ...mapGetters("meta", ["getUnitOfMeasure"]),
    completedEvents: function () {
      return this.events.filter(e => e.activity)
    },
    totalFees: function () {
      return this.events.map(e => e.registrationFee).reduce((ps, a) => ps + a, 0)
    },
    totalDistance: function () {
      return this.completedEvents.map(e => (e.activity ?? e.eventActivity).distance).reduce((ps, a) => ps + convertUnitValue(a.value, this.getUnitOfMeasure(a.unitOfMeasureID)), 0)
    }
  }
}
</script>

<style>

</style>