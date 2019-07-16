<template>
  <div>
    <NavBar />
    <router-view />
  </div>
</template>

<script>
import NavBar from '@/components/NavBar.vue';
export default {
  components: {
    NavBar
  },
  mounted() {
    this.$store.dispatch("auth/check");
  }
}
</script>

<style lang="scss">

</style>
