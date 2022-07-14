<template>
  <b-container>
    <b-card class="mt-5 text-center" border-variant="danger">
      <b-card-title>This page is restricted to authorized users</b-card-title>
      <b-link :to="{ name: 'login', query: { from: this.$route.path } }"
        >Sign In</b-link
      >
    </b-card>
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
      title: `${this.applicationName} / Authorization Required`,
    };
  },
};
</script>
