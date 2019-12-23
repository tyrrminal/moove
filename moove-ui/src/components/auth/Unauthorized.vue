<template>
  <b-container>
    <vue-headful title="Moo've / Authorization Required" />
    <b-card class="mt-5 text-center" border-variant="danger" >
      <b-card-title>This page is restricted to authorized users</b-card-title>
      <router-link :to="{ name: 'login', query: { from: this.$route.path } }" >Sign In</router-link>
    </b-card>
  </b-container>
</template>
