<template>
  <b-card class="event-results">
    <b-card-title>Results <a v-if="results_url" :href="results_url" target="_blank"><font-awesome-icon icon="external-link-alt" /></a></b-card-title>
    <b-list-group flush>
      <b-list-group-item v-for="(r,index) in results" :key="`result-${index}`">
        <label>{{ r | eventResultLabel }}</label>: {{ r.place }}/{{ r.finishers }} ({{ Number(100-r.percentile).toFixed(1) }}%)
      </b-list-group-item>
    </b-list-group>
  </b-card>
</template>

<script>
export default {
  props: {
    results_url: String,
    results: Array
  },
  filters: {
    eventResultLabel: function(v) {
      if(v.division)
        return v.division;
      if(v.gender)
        return v.gender;
      return 'Overall';
    }
  }
}
</script>

<style scoped>
.event-results label {
  width: 4rem;
  text-align: right;
}
</style>
