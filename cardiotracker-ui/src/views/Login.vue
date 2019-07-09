<template>
  <b-container>
    <b-row>
      <b-col sm="9" md="7" lg="5" class="mx-auto">
        <b-card title="Login" class="card-signin my-5">
          <b-form class="form-signin" @submit.prevent="login">
              <b-form-group id="username-fieldset" label-for="input-username" class="form-label-group" label="Username">
                <b-form-input id="input-username" type="text" v-model="username" required autofocus placeholder="username" trim></b-form-input>
              </b-form-group>

              <b-form-group id="password-fieldset" label-for="input-password" class="form-label-group" label="Password">
                <b-form-input id="input-password" type="password" v-model="password" placeholder="Password" required trim></b-form-input>
              </b-form-group>

              <b-button variant="primary" class="text-uppercase" type="submit" size="lg" block>Sign in</b-button>
          </b-form>
        </b-card>
      </b-col>
    </b-row>
    <div>{{ error }}</div>
  </b-container>
</template>

<script>
import { EventBus } from '@/services/event-bus.js';

export default {
  data() {
    return {
      username: "",
      password: "",
      error: ''
    };
  },
  methods: {
    login: function() {
      let self = this;
      const qs = require("qs");
      this.$http
        .post(
          "/auth/login",
          qs.stringify({ username: this.username, password: this.password }),
          { headers: { "Content-Type": "application/x-www-form-urlencoded", "Accept": "text/plain" } }
        )
        .then(() => {
          EventBus.$emit('login-status-changed', true);
          this.$router.replace(this.$route.query.redirect || "/");
        })
        .catch(function(error) {
          self.error = error.response.data;
        });
    }
  }
};
</script>

<style scoped>
input {
  border: 1px solid gray;
}
</style>
