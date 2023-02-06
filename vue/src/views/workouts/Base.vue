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
        { text: "Create", icon: "plus", to: { name: "create-workout" } },
        {
          text: "Calendar",
          icon: "calendar2-date",
          to: {
            name: "calendar",
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