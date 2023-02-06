<template>
  <b-list-group :flush="flush">
    <b-list-group-item v-for="r in records" :key="`pr-${r.id}`">
      <label>
        <b-link :to="{ name: 'goal', params: { id: r.id } }">{{
          r.name
        }}</b-link> </label>:
      <span :class="displayClass(r)">{{ r.fulfillments[0].description }}</span>
    </b-list-group-item>
  </b-list-group>
</template>

<script>
export default {
  props: {
    records: Array,
    flush: {
      type: Boolean,
      default: false,
    },
  },
  methods: {
    displayClass: function (r) {
      return r.fulfillments[0].isCurrent ? "current" : "text-muted";
    },
  },
};
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
