<template>
  <b-card title="Countdown">
    <b-list-group flush>
      <b-list-group-item v-for="i in significantIntervals" :key="`cdinterval-${i.label}`">{{ i.amount }} {{ i.label }}</b-list-group-item>
    </b-list-group>
  </b-card>
</template>

<script>
export default {
  data() {
    return {
      intervals: ['day','week','month']
    }
  },
  props: {
    event: Object
  },
  computed: {
    significantIntervals: function() {
      let r = [];
      this.intervals.forEach(i => {
        let c = this.event.countdown[this.$pluralize(i)];
        if(c >= 1) 
          r.push({ label: this.$pluralize(i, c), amount: c });
      });
      return r;
    }
  }
}
</script>

<style>

</style>
