<template>
  <b-list-group class="mt-3">
    <b-list-group-item>
      <label>Events</label>
      <div class="text-monospace">{{ events.length }} total</div>
      <div class="text-monospace">{{ completedEvents.length }} completed</div>
      <div class="text-monospace">{{ futureEvents.length }} upcoming</div>
    </b-list-group-item>
    <b-list-group-item>
      <label>Total Fees</label>
      <div class="font-weight-bold text-monospace">{{ totalFees.toFixed(2) | currency }}</div>
    </b-list-group-item>
    <b-list-group-item>
      <label>Total Distance</label>
      <div class="font-weight-bold text-monospace">{{ totalDistance.toFixed(2) }} miles</div>
    </b-list-group-item>
  </b-list-group>
</template>

<script>
import { DateTime } from "luxon"
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
    futureEvents: function () {
      return this.events.filter(e => DateTime.fromISO(e.eventActivity.scheduledStart) > DateTime.now())
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
