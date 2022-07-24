<template>
  <b-container>
    <div>{{ entity }}</div>
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
      this.$http.get(["activities", this.id].join("/")).then(resp => this.entity = resp.data);
    },
  },
};
</script>

<style>
</style>