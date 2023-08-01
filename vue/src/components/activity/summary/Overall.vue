<template>
  <div>
    <template>
      <b-list-group flush class="mb-4">
        <b-list-group-item>
          <h3>All Time</h3>
          <span v-if="loaded" :style="{ fontSize: '11pt' }">{{ elapsedYears | number("0,0.00") }} years
            ({{ elapsedDays | number("0,0") }} days)</span>
          <b-skeleton v-else />
        </b-list-group-item>
        <div v-if="loaded">
          <SummaryElement v-for="(a, i) in activities" :key="i" :activity="a" :hideNominal="true" />
        </div>
        <b-list-group-item v-else class="d-flex justify-content-center mb-3">
          <b-spinner label="Loading..."></b-spinner>
        </b-list-group-item>
      </b-list-group>
    </template>

  </div>
</template>

<script>
import { convertUnitValue } from "@/utils/unitConversion.js";
import SummaryElement from "@/components/activity/summary/Element";
import { mapGetters } from "vuex";
import { DateTime } from "luxon";

export default {
  name: "OverallSummary",
  components: {
    SummaryElement
  },
  props: {
    summaryData: {
      type: Array,
      required: false
    }
  },
  computed: {
    ...mapGetters('meta', ['getUnitOfMeasure']),
    loaded: function () {
      return this.summaryData?.length > 0
    },
    activities: function () {
      return this.summaryData.filter((a) => a.distance?.total?.value > 0).sort((a, b) => convertUnitValue(b.distance.total.value, this.getUnitOfMeasure(b.distance.total.unitOfMeasureID)) - convertUnitValue(a.distance.total.value, this.getUnitOfMeasure(a.distance.total.unitOfMeasureID)));
    },
    startDate: function () {
      return DateTime.fromISO(this.summaryData[0].startDate)
    },
    elapsedYears: function () {
      return DateTime.now().startOf('day').diff(this.startDate, ['years']).years
    },
    elapsedDays: function () {
      return DateTime.now().startOf('day').diff(this.startDate, ['days']).days
    }
  }
}
</script>

<style scoped></style>