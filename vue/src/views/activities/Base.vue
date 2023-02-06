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
        { text: "Import", icon: "upload", to: { name: "importActivities" } },
        { text: "List", icon: "list", to: { name: "activities" } },
        { text: "Summary", icon: "files", to: { name: "activitiesSummary" } },
        {
          text: "Slice",
          icon: "calendar-range",
          to: { name: "activitiesSlice" },
        },
      ],
    };
  },
};
</script>

<style>

</style>