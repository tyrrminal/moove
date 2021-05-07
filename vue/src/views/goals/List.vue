<template>
  <layout-default>
    <template #sidebar>
      <SideBar />
    </template>

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
            <span class="text-muted">[{{ g.activity_type.description }}]</span>
            <label class="listlabel">{{ g.name }}:</label>
            <template v-if="g.count">{{
              g.fulfillments[0].description
            }}</template>
          </span>
          <b-badge variant="info" pill>{{ g.count }}</b-badge>
        </b-list-group-item>
      </b-list-group>
    </template>

    <hr v-if="prs.length && achievements.length" />

    <template v-if="achievements.length">
      <h3>Achievements</h3>
      <b-list-group class="py-0">
        <b-list-group-item v-for="g in achievements" :key="g.id">
          <span class="text-muted">[{{ g.activity_type.description }}]</span>
          <label class="listlabel">{{ g.name }}:</label>
          <span v-if="g.count">
            {{ g.fulfillments[0].date | moment("M/D/YY") }}
            <b-link
              v-if="g.fulfillments[0].activities[0].event"
              :to="{
                name: 'event',
                params: { id: g.fulfillments[0].activities[0].event.id },
              }"
              >{{ g.fulfillments[0].activities[0].event.name }}</b-link
            >
          </span>
          <font-awesome-icon v-else icon="times" />
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
  mixins: [Branding],
  components: {
    LayoutDefault,
    SideBar,
  },
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  data: function () {
    return {
      prs: [],
      achievements: [],
      error: "",
    };
  },
  props: {
    user: {
      type: String,
    },
  },
  methods: {
    init() {
      let self = this;
      this.$http
        .get("goals/" + self.effectiveUser)
        .then((response) => {
          self.prs = response.data.personalRecords;
          self.achievements = response.data.achievements;
        })
        .catch((err) => (self.error = err.response.data.message));
    },
  },
  mounted: function () {
    this.init();
  },
  computed: {
    title: function () {
      return `${this.applicationName} / Goals`;
    },
    effectiveUser: function () {
      if (this.$route.params.user) return this.$route.params.user;
      return this.$store.getters["auth/currentUser"].username;
    },
  },
};
</script>

<style >
.listlabel {
  font-weight: bold;
  color: black;
  width: 16rem;
}
</style>
