<template>
  <span>
    <a href='#' v-if="loggedIn()" @click.prevent="logout">Logout {{ cookie_username() }}</a>
    <router-link :to="{ name: 'login'}" v-else>Log in</router-link>
  </span>
</template>

<script>
import { EventBus } from '@/services/event-bus.js';

export default {
  methods: {
    loggedIn: function() {
      if(!this.user)
        return false;
      let u = this.cookie_username();
      let v = (u != null && u.username !== '');
      return v;
    },
    cookie_username: function() {
      return this.user.username;
    },
    logout: function() {
      var self = this;
      this.$http
        .post(
          "/auth/logout",
          '',
          { headers: { "Content-Type": "application/x-www-form-urlencoded", "Accept": "text/plain" } }
        ).then( () => {
          EventBus.$emit('login-status-changed', false);
          this.$router.replace("/");
        });
    }
  },
  computed: {
    user: function() {
      var c = this.$cookie.get('cardiotracker');
      if(!c)
        return null;
      return JSON.parse(atob(c));
    }
  },
  created() {
    EventBus.$on('login-status-changed', s => {
      this.$forceUpdate();
    })
  }
}
</script>

<style>

</style>
