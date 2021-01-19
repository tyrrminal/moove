<template>
  <div>
    <NavBar />
    <template v-if="isAuthorized">
      <router-view />
    </template>
    <template v-else>
      <Unauthorized />
    </template>
  </div>
</template>

<script>
import NavBar from "@/components/NavBar.vue";
import Unauthorized from "@/components/auth/Unauthorized.vue";
export default {
  components: {
    NavBar,
    Unauthorized,
  },
  computed: {
    isAuthorized: function () {
      if (this.$route.meta.requiresAuth) {
        return this.$store.getters["auth/isLoggedIn"];
      }
      return true;
    },
  },
};
</script>

<style lang="scss">
</style>
