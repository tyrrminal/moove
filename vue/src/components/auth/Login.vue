<template>
  <b-container>
    <b-row>
      <b-col sm="9" md="7" lg="5" class="mx-auto">
        <b-card :title="title" class="card-signin my-5" bg-variant="light">
          <b-form class="form-signin" @submit.prevent="login">
            <b-form-group id="username-fieldset" label-for="input-username" class="form-label-group" label="Username">
              <b-form-input id="input-username" type="text" v-model="username" required autofocus placeholder="username"
                trim></b-form-input>
            </b-form-group>

            <b-form-group id="password-fieldset" label-for="input-password" class="form-label-group" label="Password">
              <b-form-input id="input-password" type="password" v-model="password" placeholder="Password" required
                trim></b-form-input>
            </b-form-group>

            <div class="text-center">
              <b-button variant="primary" class="text-uppercase mx-auto" type="submit">Sign in</b-button>
            </div>
          </b-form>
        </b-card>
      </b-col>
    </b-row>
    <div>{{ error }}</div>
  </b-container>
</template>

<script>
import Branding from "@/mixins/Branding.js";

export default {
  mixins: [Branding],
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  data: function () {
    return {
      username: "",
      password: "",
      error: "",
    };
  },
  methods: {
    login: function () {
      let self = this;
      let username = this.username;
      let password = this.password;
      this.$store
        .dispatch("auth/login", [username, password])
        .then(() =>
          self.$router.replace(this.$route.query.from || { name: "home" })
        )
        .catch((err) => (self.error = err.response.data.message));
    },
  },
  computed: {
    title: function () {
      return `${this.applicationName} Login`;
    },
  },
};
</script>

<style></style>
