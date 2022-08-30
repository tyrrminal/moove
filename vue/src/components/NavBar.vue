<template>
  <div>
    <b-navbar toggleable="lg" type="dark" variant="secondary">
      <b-navbar-brand :to="{ name: 'home' }">{{
         applicationName 
        }}</b-navbar-brand>

      <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>

      <b-collapse id="nav-collapse" is-nav>
        <b-navbar-nav v-if="isLoggedIn">
          <b-nav-item v-for="i in mainMenu" :key="i.name" :to="i.to">{{
             i.name 
            }}</b-nav-item>
        </b-navbar-nav>
      </b-collapse>

      <b-navbar-nav class="ml-auto">
        <b-nav-item-dropdown v-if="isLoggedIn" right id="nav-user-dropdown">
          <!-- Using 'button-content' slot -->
          <template slot="button-content">
            <em>{{  username  }}</em>
          </template>
          <b-dropdown-item :to="{ name: 'user', params: { username: username } }">Profile</b-dropdown-item>
          <b-dropdown-item @click="logout">Sign Out</b-dropdown-item>
        </b-nav-item-dropdown>
        <b-nav-item v-else :to="{ name: 'login' }">Sign In</b-nav-item>
      </b-navbar-nav>
    </b-navbar>
  </div>
</template>

<script>
import Branding from "@/mixins/Branding.js";

export default {
  mixins: [Branding],
  computed: {
    mainMenu: function () {
      return [
        {
          name: "Workouts",
          to: { name: "workouts" },
        },
        {
          name: "Activities",
          to: { name: "activities" },
        },
        {
          name: "Events",
          to: { name: "registrations" },
        },
        //        {
        //          name: "Goals",
        //          to: { name: "goals" },
        //        },
      ];
    },
    isLoggedIn: function () {
      return this.$store.getters["auth/isLoggedIn"];
    },
    username: function () {
      return this.$store.getters["auth/currentUser"].username;
    },
  },
  methods: {
    logout: function () {
      this.$store.dispatch("auth/logout").then(() => {
        this.$router.go();
      });
    },
  },
};
</script>

<style>
</style>
