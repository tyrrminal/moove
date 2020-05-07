<template>
  <b-card title="Achievements" class="records">
    <b-list-group flush>
      <b-list-group-item v-for="r in records" :key="r.id">
        <label :class="displayClass(r)">{{ r.name }}</label>
      </b-list-group-item>
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
      return r.fulfillments[0].is_current ? "current" : "text-muted";
    }
  }
};
</script>

<style scoped>
.current {
  font-weight: bold;
}
</style>
