<template>
  <div>
    <Sidebar :items="menu.filter(x => !x.disabled)" />
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
        { text: "List", icon: "list", to: { name: "workouts" } },
        {
          text: "Calendar",
          icon: "calendar2-date",
          to: {
            name: "calendar",
          },
          disabled: true
        },
      ];
    },
    username: function () {
      return this.$store.getters["auth/currentUser"].username;
    },
  },
};
</script>

<style></style>