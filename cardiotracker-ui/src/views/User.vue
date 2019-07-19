<template>
  <layout-default>
    <template #sidebar>
      <SideBar :items="sidebarOps" />
    </template>

    <b-container>
      <p>{{ user }}</p>
    </b-container>
  </layout-default>
</template>

<script>
import LayoutDefault from '@/layouts/LayoutDefault.vue';
import SideBar from '@/components/SideBar.vue';

export default {
  components: {
    LayoutDefault,
    SideBar
  },
  data() {
    return {
      user: "digicow",
      sidebarOps: [
        { text: "Say Hello", to: { name: "wave" } }
      ]
    }
  }
}
</script>

<style>

</style>
