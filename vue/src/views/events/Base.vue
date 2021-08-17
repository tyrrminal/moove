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
      menu: [{ text: "Add", to: { name: "create-event" } }],
    };
  },
};
</script>

<style>
</style>