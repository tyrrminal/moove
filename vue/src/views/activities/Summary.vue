<template>
  <div></div>
</template>

<script>
const { DateTime } = require("luxon");

export default {
  name: "ActivitySummary",
  data: function () {
    return {
      overall: {},
      current: {
        year: {},
        month: {},
        week: {},
      },
    };
  },
  mounted: function () {
    let resource = ["activities", "summary"].join("/");
    this.$http.get(resource).then((resp) => {
      this.overall = resp.data;
    });
    this.$http
      .get(resource, {
        params: { start: this.startOfYear.toISODate(), period: "year" },
      })
      .then((resp) => {
        this.current.year = resp.data;
      });
  },
  computed: {
    startOfYear: function () {
      return DateTime.local().startOf("year");
    },
  },
};
</script>

<style>
</style>