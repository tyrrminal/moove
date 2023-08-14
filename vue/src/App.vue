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
import { DateTime } from "luxon";

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
  mounted: function () {
    let r = this.$router;
    let exp = DateTime.fromISO(this.$store.getters["auth/expiration"]);
    if (exp.diffNow(["seconds"]).seconds < 0) {
      this.$store.dispatch("auth/logout").then(() => r.push({ name: "home" }));
    }

    if (this.$store.getters["auth/status"] === "") {
      this.$store.dispatch("auth/check");
    }

    if (!this.$store.getters["meta/isLoaded"])
      this.$store.dispatch("meta/initialize");
  }
};
</script>

<style>
.cursor-pointer {
  cursor: pointer;
}

table.rounded-row {
  border-collapse: separate;
  border-spacing: 0 0.5em;
}

table.rounded-row tr.rounded-row>td {
  background-color: #f8f9fa;
  border-top: 1px #b2c3cf solid;
  border-bottom: 1px #b2c3cf solid;
  font-weight: 600;
}

table.rounded-row tr.rounded-row>td:first-child {
  border-left: 1px #b2c3cf solid;
  border-top-left-radius: 8px;
  border-bottom-left-radius: 8px;
}

table.rounded-row tr.rounded-row>td:last-child {
  border-right: 1px #b2c3cf solid;
  border-top-right-radius: 8px;
  border-bottom-right-radius: 8px;
}

table.rounded-row .activityLink {
  color: inherit;
}

table.rounded-row .roundedRow:hover td {
  background-color: #ececec;
}

table.rounded-row .roundedRow:hover .activityLink {
  color: inherit;
  text-decoration: underline;
}
</style>
