<template>
  <div class="summary pt-2 px-4 rounded-lg mt-3">
    <span><label>Distance:</label>{{ formattedDistance(data.distance.total) }} ({{ data.counts.total }})</span>
    <span v-if="data.distance.eventTotal?.value"><label>Event Distance:</label>{{
      formattedDistance(data.distance.eventTotal) }} ({{ data.counts.eventTotal }})</span>
    <span><label>Average:</label>{{ formattedDistance(data.distance.avg) }}</span>
    <span><label>Min:</label>{{ formattedDistance(data.distance.min) }}</span>
    <span><label>Max:</label>{{ formattedDistance(data.distance.max) }}</span>

  </div>
</template>

<script>
import { unitValue } from "@/utils/unitValue.js";

export default {
  props: {
    data: {
      type: Object,
      required: true
    }
  },
  methods: {
    formattedDistance: function (d) {
      return unitValue(d, null, 2).description
    }
  }
}
</script>

<style scoped>
div.summary {
  background-color: rgba(209, 198, 255, 0.37)
}

div.summary label {
  font-weight: bold;
  margin-right: 1rem;
}

div.summary span {
  margin-right: 2rem;
}
</style>