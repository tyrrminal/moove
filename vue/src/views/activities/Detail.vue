<template>
  <b-container>
    <div>Activity...</div>
  </b-container>
</template>

<script>
export default {
  data: function () {
    return {
      id: this.$attrs.id,
      entity: null,
    };
  },
  mounted() {
    this.getData();
  },
  methods: {
    getData: function () {
      this.$http.get("activitry");
    },
  },
};
</script>

<style>
</style>