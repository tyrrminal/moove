<template>
  <span>
    <template v-if="isLoggedIn"><a href='#' @click="logout">Logout {{ username }}</a></template>
    <template v-else><router-link to="/login">Login</router-link></template>
  </span>
</template>

<script>

export default {
  computed: {
    isLoggedIn: function() {
      return this.$store.getters['auth/isLoggedIn'];
    },
    username: function() {
      return this.$store.getters['auth/currentUser'].username;
    }
  },
  methods: {
    logout: function() {
      this.$store.dispatch("auth/logout").then(() => {
        this.$router.push("/login");
      })
    }
  }
}
</script>

<style>

</style>
