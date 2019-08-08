<template>
  <layout-default>
    <vue-headful :title="title" />

    <h3>{{ goal.name }}</h3>
    <b-list-group>
      <b-list-group-item
        v-for="g in goal.fulfillments.slice().reverse()"
        :key="g.date"
        class="py-1"
      >
        <div class="d-flex">
          <label class="col-sm-2">{{ g.date | moment('M/D/YY') }}</label>
          <span class="col-sm-2">{{ g.description }}</span>
          <span class="flex-fill">
            <b-link
              v-if="g.activities[0].event"
              :to="{ name: 'event', params: { id: g.activities[0].event.id, user: effectiveUser } }"
            >{{ g.activities[0].event.name }}</b-link>
          </span>
        </div>
      </b-list-group-item>
    </b-list-group>
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
      goal: null
    };
  },
  methods: {
    init() {
      let self = this;
      this.$http
        .get("goal/" + self.effectiveUser + "/" + self.goalId)
        .then(response => {
          self.goal = response.data;
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
    goalId: function() {
      return this.$route.params.id;
    },
    title() {
      var t = "Moo've / Goal";
      if (this.goal !== null) t = t + " / " + this.goal.name;
      return t;
    }
  }
};
</script>

<style>
</style>
