<template>
  <b-card title="Results" class="event-results">
    <b-list-group flush>
      <b-list-group-item v-for="(r,index) in results" :key="`result-${index}`">
        <label>{{ r | eventResultLabel }}</label>: {{ r.place }}/{{ r.finishers }} ({{ 100-Number(r.percentile).toFixed(1) }}%)
      </b-list-group-item>
    </b-list-group>
  </b-card>
</template>

<script>
export default {
  props: {
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
