<template>
  <layout-default>
    <template #sidebar>
      <SideBar :items="sidebarOps" />
    </template>

    <b-container v-if="user">
      <b-row>
        <b-col sm="12" class="text-center">
          <h3>
            {{ user.person.firstname }}
            <template
              v-if="
                user.person.firstname.toLowerCase() !==
                user.username.toLowerCase()
              "
              >"{{ user.username }}"</template
            >
            {{ user.person.lastname }}
          </h3>
        </b-col>
      </b-row>

      <b-row>
        <b-col sm="10" class="text-center">
          <span class="text-muted">Lifetime:</span>
          <span v-for="t in totals.length" :key="totals[t - 1].activityType.id">
            {{ totals[t - 1].activityType.description }}
            {{ totals[t - 1].distance | formatDistance }}
            <span v-if="t < totals.length" class="text-muted">/</span>
          </span>
        </b-col>
      </b-row>

      <hr />

      <b-row>
        <b-col sm="4">
          <h4>Activities</h4>
          <h5>Recent</h5>
          <b-list-group>
            <b-list-group-item v-for="a in activities" :key="a.id">
              <timeago :datetime="a.startTime"></timeago>
              &mdash; {{ a.distance | formatDistance }}
              {{ a.activityType.description }}
            </b-list-group-item>
          </b-list-group>
        </b-col>

        <b-col sm="4">
          <h4>Events</h4>
          <h5>Most Recent</h5>
          <EventDetails
            v-if="events.previous"
            :event="events.previous.event"
            :isPublic="events.previous.registration.isPublic"
          />
          <h5>Next</h5>
          <EventDetails
            v-if="events.next"
            :event="events.next.event"
            :isPublic="events.next.registration.isPublic"
          />
        </b-col>

        <b-col sm="4">
          <h4>Personal Records</h4>
          <h5>Recent</h5>
          <ActivityRecords :records="prs" />
        </b-col>
      </b-row>
    </b-container>
  </layout-default>
</template>

<script>
import Branding from "@/mixins/Branding.js";
import EventFilters from "@/mixins/events/Filters.js";

import LayoutDefault from "@/layouts/LayoutDefault.vue";
import SideBar from "@/components/SideBar.vue";
import EventDetails from "@/components/event/cards/EventDetails.vue";
import ActivityRecords from "@/components/activity/lists/Records.vue";

export default {
  mixins: [Branding, EventFilters],
  components: {
    LayoutDefault,
    SideBar,
    EventDetails,
    ActivityRecords,
  },
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  data: function () {
    return {
      error: null,
      user: null,
      activities: [],
      goals: [],
      events: null,
      totals: [],
      sidebarOps: [],
    };
  },
  mounted: function () {
    let self = this;
    this.$http
      .get("user/" + self.effectiveUser + "/summary")
      .then((response) => {
        self.user = response.data.user;
        self.activities = response.data.recentActivities;
        self.events = response.data.events;
        self.totals = response.data.totals;
        self.goals = response.data.goals;
      })
      .catch((err) => (self.error = err.response.data.message));
  },
  computed: {
    title: function () {
      return `${this.applicationName} / ${effectiveUser}`;
    },
    effectiveUser: function () {
      if (this.$route.params.user) return this.$route.params.user;
      return this.$store.getters["auth/currentUser"].username;
    },
    prs: function () {
      return this.goals.filter((g) => g.isPR);
    },
  },
};
</script>

<style>
</style>
