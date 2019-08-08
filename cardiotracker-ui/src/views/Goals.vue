<template>
  <layout-default>
    <vue-headful :title="'Moo\'ve / Goals'" />

    <template v-if="prs.length">
      <h3>Personal Records</h3>
      <b-list-group>
        <b-list-group-item
          class="py-2 d-flex align-items-center justify-content-between"
          v-for="g in prs"
          :key="g.id"
          :to="{ name: 'goal', params: { user: effectiveUser, id: g.id } }"
        >
          <span>
            <label class="listlabel">{{ g.name }}:</label>
            <template
              v-if="g.fulfillments.length"
            >{{ g.fulfillments[g.fulfillments.length-1].description }}</template>
          </span>
          <b-badge variant="info" pill>{{ g.fulfillments.length }}</b-badge>
        </b-list-group-item>
      </b-list-group>
    </template>

    <hr v-if="prs.length && achievements.length" />

    <template v-if="achievements.length">
      <h3>Achievements</h3>
      <b-list-group class="py-0">
        <b-list-group-item v-for="g in achievements" :key="g.id">
          <label class="listlabel">{{ g.name }}:</label>
          <span
            v-if="g.fulfillments.length"
          >{{ g.fulfillments[g.fulfillments.length-1].date | moment('M/D/YY') }}</span>
          <font-awesome-icon v-else icon="times" />
        </b-list-group-item>
      </b-list-group>
    </template>
  </layout-default>
</template>

<script>
import LayoutDefault from "@/layouts/LayoutDefault.vue";

export default {
  components: {
    LayoutDefault
  },
  data() {
    return {
      goals: [],
      error: ""
    };
  },
  methods: {
    init() {
      let self = this;
      this.$http
        .get("goals/" + self.effectiveUser)
        .then(response => {
          self.goals = response.data;
        })
        .catch(err => (self.error = err.response.data.message));
    }
  },
  mounted() {
    this.init();
  },
  computed: {
    effectiveUser: function() {
      if (this.$route.params.user) return this.$route.params.user;
      return this.$store.getters["auth/currentUser"].username;
    },
    prs: function() {
      return this.goals.filter(i => i.is_pr);
    },
    achievements: function() {
      return this.goals.filter(i => !i.is_pr);
    }
  }
};
</script>

<style >
.listlabel {
  font-weight: bold;
  color: black;
  width: 16rem;
}
</style>
