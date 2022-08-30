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
  computed: {
    menu: function () {
      return [
        { text: "Add", icon: "plus", to: { name: "event-create" } },
        { text: "List", icon: "list", to: { name: "registrations" } },
        { text: "Search", icon: "search", to: { name: "event-search" } },
      ];
    },
    username: function () {
      return this.$store.getters["auth/currentUser"].username;
    },
  },
};
</script>

<style>
</style>