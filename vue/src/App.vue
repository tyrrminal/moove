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
table#roundedRowTable {
  border-collapse: separate;
  border-spacing: 0 0.5em;
}
table#roundedRowTable tr.roundedRow > td {
  background-color: #f8f9fa;
  border-top: 1px #b2c3cf solid;
  border-bottom: 1px #b2c3cf solid;
  font-weight: 600;
}
table#roundedRowTable tr.roundedRow > td:first-child {
  border-left: 1px #b2c3cf solid;
  border-top-left-radius: 8px;
  border-bottom-left-radius: 8px;
}
table#roundedRowTable tr.roundedRow > td:last-child {
  border-right: 1px #b2c3cf solid;
  border-top-right-radius: 8px;
  border-bottom-right-radius: 8px;
}
table#roundedRowTable .activityLink {
  color: inherit;
}
table#roundedRowTable .roundedRow:hover td {
  background-color: #ececec;
}
table#roundedRowTable .roundedRow:hover .activityLink {
  color: inherit;
  text-decoration: underline;
}
</style>
