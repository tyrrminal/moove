<template>
  <div>
    <Sidebar :items="menu" />
    <router-view></router-view>
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
      menu: [
        { text: "Create", to: { name: "createWorkout" } },
        { text: "Summary", to: { name: "activitiesSummary" } },
      ],
    };
  },
};
</script>

<style>
</style>