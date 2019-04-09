<template>
  <div>Hello</div>
</template>

<script>
import ActivitiesService from "@/services/ActivitiesService.js";

export default {
  data() {
    return {
      summary: {}
    };
  },
  created() {
    ActivitiesService.getSummary("digicow").then(response => {
      this.summary = response.data;
    });
  }
};
</script>

<style></style>
