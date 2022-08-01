<template>
  <b-container>
    <ActivityCard v-if="entity" :activity="entity" class="mt-3" />
  </b-container>
</template>

<script>
import ActivityCard from "@/components/activity/cards/Result";
import UnitConversion from "@/mixins/UnitConversion.js";

export default {
  components: {
    ActivityCard
  },
  mixins: [UnitConversion],
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
      this.$http.get(["activities", this.id].join("/")).then(resp => this.entity = { ...resp.data, ...resp.data.sets[0] });
    },
  },
};
</script>

<style>
</style>