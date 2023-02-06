<template>
  <b-container class="mt-4 mb-2">
    <b-row>
      <b-col v-for="(s, i) in sections" :key="i" cols="3">
        <Summary :period="s" />
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import Summary from "@/components/activity/Summary";

export default {
  name: "ActivitySummary",
  components: {
    Summary,
  },
  data: function () {
    return {
      sections: [null, "year", "month", "week"],
    };
  },
};
</script>

<style>

</style>