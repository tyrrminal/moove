<template>
  <div>
    <Sidebar :items="menu" />
  </div>
</template>

<script>
import Sidebar from "@/components/SideBar.vue";

export default {
  components: {
    Sidebar,
  },
  data: function () {
    return {
      menu: [{ text: "Summary", to: { name: "activitiesSummary" } }],
    };
  },
};
</script>

<style>
</style>