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
        { text: "Create", icon: "plus", to: { name: "createWorkout" } },
        {
          text: "Calendar",
          icon: "calendar2-date",
          to: {
            name: "calendar",
            params: { username: this.username },
          },
        },
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