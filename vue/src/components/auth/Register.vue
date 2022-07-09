<template>
  <div>
    <h4>Register</h4>
    <form @submit.prevent="register">
      <label for="name">Name</label>
      <div>
        <input id="name" type="text" v-model="name" required autofocus />
      </div>
      <label for="name">Username</label>
      <div>
        <input
          id="username"
          type="text"
          v-model="username"
          required
          autofocus
        />
      </div>
      <label for="password">Password</label>
      <div>
        <input id="password" type="password" v-model="password" required />
      </div>
      <label for="password">Confirm Password</label>
      <div>
        <input
          id="password-confirm"
          type="password"
          v-model="passwordConfirmation"
          required
        />
      </div>
      <div>
        <button type="submit">Register</button>
      </div>
    </form>
  </div>
</template>

<script>
export default {
  data() {
    return {
      name: "",
      username: "",
      password: "",
      passwordConfirmation: "",
    };
  },
  methods: {
    register: function () {
      let data = {
        name: this.name,
        username: this.username,
        password: this.password,
      };
      this.$store
        .dispatch("auth/register", data)
        .then(() => this.$router.push("/"))
        .catch((err) => console.log(err));
    },
  },
};
</script>

<style>
</style>
