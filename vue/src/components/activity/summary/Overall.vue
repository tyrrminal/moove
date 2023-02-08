<template>
  <div>
    <h3>Overall</h3>
    <span>{{ summaryData.period.daysElapsed | number("0,0") }} days ~
      {{ summaryData.period.years | number("0,0.00") }} years</span>

    <b-list-group flush>
      <SummaryElement v-for="a in activities" :key="a.activityTypeID || 0" :activity="a" />
    </b-list-group>
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
      required: true
    }
  },
  computed: {
    activities: function () {
      return this.summaryData.activities.filter((a) => a.distance > 0).sort((a, b) => b.distance - a.distance);
    },
  }
}
</script>

<style scoped>

</style>