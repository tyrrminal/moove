<template>
  <layout-default>
    <vue-headful :title="'Moo\'ve / ' + effectiveUser" />

    <template #sidebar>
      <SideBar :items="sidebarOps" />
    </template>

    <b-container v-if="user">
      <b-row>
        <b-col sm="12" class="text-center">
          <h3>{{ user.person.first_name }}<template v-if="user.person.first_name.toLowerCase() !== user.username.toLowerCase()"> "{{ user.username }}"</template> {{ user.person.last_name }}</h3>
        </b-col>
      </b-row>

      <b-row>
        <b-col sm="10" class="text-center">
          <span class="text-muted">Lifetime: </span><span v-for="t in totals.length" :key="totals[t-1].activity_type.id">{{ totals[t-1].activity_type.description }} {{ totals[t-1].distance | format_distance }}<span v-if="t < totals.length" class="text-muted"> / </span></span>
        </b-col>
      </b-row>

      <hr />

      <b-row>
        <b-col sm="4">
          <h4>Activities</h4>
          <h5>Recent</h5>
          <b-list-group>
            <b-list-group-item v-for="a in activities" :key="a.id" ><timeago :datetime="a.start_time"></timeago> &mdash; {{ a.distance | format_distance }} {{ a.activity_type.description }}</b-list-group-item>
          </b-list-group>
        </b-col>

        <b-col sm="4">
          <h4>Events</h4>
          <h5>Most Recent</h5>
          <EventDetails v-if="events.previous" :event="events.previous.event" :isPublic="events.previous.registration.is_public" />
          <h5>Next</h5>
          <EventDetails v-if="events.next" :event="events.next.event" :isPublic="events.next.registration.is_public" />
        </b-col>
      </b-row>
    </b-container>
  </layout-default>
</template>

<script>
import '@/filters/event_filters.js';

import LayoutDefault from '@/layouts/LayoutDefault.vue';
import SideBar from '@/components/SideBar.vue';
import EventDetails from '@/components/event/cards/EventDetails.vue';

export default {
  components: {
    LayoutDefault,
    SideBar,
    EventDetails
  },
  data() {
    return {
      error: null,
      user: null,
      activities: [],
      events: null,
      totals: [],
      sidebarOps: [
        
      ]
    }
  },
  mounted() {
    let self = this;
    this.$http.get("user/" + self.effectiveUser + "/summary")
      .then(response => {
        self.user = response.data.user;
        self.activities = response.data.recent_activities;
        self.events = response.data.events;
        self.totals = response.data.totals;
      })
      .catch(err => self.error = err.response.data.message);
  },
  computed: {
    effectiveUser: function() {
      if(this.$route.params.user)
        return this.$route.params.user;
      return this.$store.getters['auth/currentUser'].username;
    },
  }
}
</script>

<style>

</style>
