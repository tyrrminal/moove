<template>
  <layout-default>
    <template #sidebar>
      <SideBar />
    </template>

    <template v-if="goal">
      <h5>
        <b-link :to="{ name: 'goals' }">&#171; All Goals</b-link>
      </h5>

      <h3>{{ goal.name }}</h3>
      <b-list-group>
        <b-list-group-item v-for="g in goal.fulfillments" :key="g.date" class="py-1">
          <div class="d-flex">
            <label class="col-sm-2">{{ g.date | luxon({ output: "date_short" }) }}</label>
            <span class="col-sm-2">{{ g.description }}</span>
            <span class="flex-fill">
              <b-link v-if="g.activities[0].event" :to="{
                name: 'event',
                params: { id: g.activities[0].event.id, user: effectiveUser },
              }">{{ g.activities[0].event.name }}</b-link>
            </span>
          </div>
        </b-list-group-item>
      </b-list-group>
    </template>
  </layout-default>
</template>

<script>
import Branding from "@/mixins/Branding.js";
import LayoutDefault from "@/layouts/LayoutDefault.vue";
import SideBar from "@/components/SideBar.vue";

export default {
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  mixins: [Branding],
  components: {
    LayoutDefault,
    SideBar,
  },
  data: function () {
    return {
      goal: null,
    };
  },
  methods: {
    init() {
      let self = this;
      this.$http
        .get("goal/" + self.effectiveUser + "/" + self.goalId)
        .then((response) => {
          self.goal = response.data;
        })
        .catch((err) => (self.error = err.response.data.message));
    },
  },
  mounted: function () {
    this.init();
  },
  computed: {
    effectiveUser: function () {
      return this.$store.getters["auth/currentUser"].username;
    },
    goalId: function () {
      return this.$route.params.id;
    },
    title: function () {
      var t = `${this.applicationName} / Goal`;
      if (this.goal !== null) t = t + " / " + this.goal.name;
      return t;
    },
  },
};
</script>

<style>

</style>
