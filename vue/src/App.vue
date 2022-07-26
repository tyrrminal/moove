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
};
</script>

<style>
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
