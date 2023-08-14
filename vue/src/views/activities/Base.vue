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
        { text: "Import", icon: "upload", to: { name: "importActivities" }, },

        { text: "Summary", icon: "files", to: { name: "activitiesSummary" }, section: 'middle' },
        { text: "List", icon: "list", to: { name: "activities" }, section: 'middle' },
        { text: "Slice", icon: "calendar-range", to: { name: "activitiesSlice" }, section: 'middle' },
      ],
    };
  },
};
</script>

<style></style>