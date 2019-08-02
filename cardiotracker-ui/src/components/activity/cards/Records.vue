<template>
  <b-card title="Personal Records" class="records">
    <b-list-group flush>
      <b-list-group-item v-for="r in records" :key="r.id"><label>{{ r.name }}</label>: <span :class="displayClass(r)">{{ r.description }}</span></b-list-group-item>
    </b-list-group>
  </b-card>
</template>

<script>
export default {
  props: {
    records: Array
  },
  methods: {
    displayClass: function(r) {
      return r.is_current ? 'current' : 'text-muted';
    }
  }
}
</script>

<style scoped>
.records .list-group-item {
  text-align: left;
}
.records label {
  width: 60%;
  text-align: right;
}
.current {
  font-weight: bold;
}
</style>
