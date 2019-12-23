<template>
  <div>
    <b-navbar toggleable="lg" type="dark" variant="secondary">
      <b-navbar-brand :to="{ name: 'home' }">Moo've</b-navbar-brand>

      <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>

      <b-collapse id="nav-collapse" is-nav>
        <b-navbar-nav v-if="isLoggedIn">
          <b-nav-item>Activities</b-nav-item>
          <b-nav-item :to="{ name: 'events', params: { user: this.username } }">Events</b-nav-item>
          <b-nav-item :to="{ name: 'goals', params: { user: this.username } }">Goals</b-nav-item>
          <b-nav-item>Fundraising</b-nav-item>
        </b-navbar-nav>
      </b-collapse>

      <b-navbar-nav class="ml-auto">
        <b-nav-item-dropdown v-if="isLoggedIn" right id="nav-user-dropdown">
          <!-- Using 'button-content' slot -->
          <template slot="button-content">
            <em>{{ username }}</em>
          </template>
          <b-dropdown-item :to="{ name: 'user', params: { user: username } }">Profile</b-dropdown-item>
          <b-dropdown-item @click="logout">Sign Out</b-dropdown-item>
        </b-nav-item-dropdown>
        <b-nav-item v-else :to="{ name: 'login' }">Sign In</b-nav-item>
      </b-navbar-nav>
    </b-navbar>
  </div>
</template>

<script>
export default {
  computed: {
    isLoggedIn: function() {
      return this.$store.getters["auth/isLoggedIn"];
    },
    username: function() {
      return this.$store.getters["auth/currentUser"].username;
    }
  },
  methods: {
    logout: function() {
      this.$store.dispatch("auth/logout").then(() => {
        this.$router.go();
      });
    }
  }
};
</script>

<style>
</style>
