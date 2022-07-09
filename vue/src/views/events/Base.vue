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
        { text: "Add", icon: "plus", to: { name: "create-event" } },
        {
          text: "List",
          icon: "list",
          to: { name: "events", params: { username: this.username } },
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