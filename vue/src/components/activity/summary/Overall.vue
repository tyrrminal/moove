<template>
  <div>
    <template>
      <b-list-group flush class="mb-4">
        <b-list-group-item>
          <h3>All Time</h3>
          }} days)</span>
          <b-skeleton v-else />
        </b-list-group-item>
        <div v-if="loaded">
      <SummaryElement v-for="a in activities" :key="a.activityTypeID || 0" :activity="a" />
        </div>
        <b-list-group-item v-else class="d-flex justify-content-center mb-3">
          <b-spinner label="Loading..."></b-spinner>
        </b-list-group-item>
    </b-list-group>
    </template>

  </div>
</template>

<script>
import SummaryElement from "@/components/activity/summary/Element"

export default {
  name: "OverallSummary",
  components: {
    SummaryElement
  },
  props: {
    summaryData: {
      type: Object,
      required: false
    }
  },
  computed: {
    loaded: function () {
      return this.summaryData != null
    },
    activities: function () {
      return this.summaryData.activities.filter((a) => a.distance > 0).sort((a, b) => b.distance - a.distance);
    },
  }
}
</script>

<style scoped>

</style>