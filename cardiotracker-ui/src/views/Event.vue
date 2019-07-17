<template>
  <layout-default>
    <template #sidebar>
      <SideBar :items="sidebarOps" />
    </template>
    
    <b-container v-if="event">
      <vue-headful :title="'Moo\'ve / Events: ' + event.event.name" />
      <b-row>
        <b-col sm="2">
          <Links :links="links" :user="effectiveUser" direction="prev" />
        </b-col>
        <b-col sm="9" md="7" lg="5" class="mx-auto">
          <RegistrationStatus :registration="event.registration" :isInFuture="eventIsInFuture" />
          <EventDetails :event="event.event" :isPublic="event.registration.is_public" />
        </b-col>
        <b-col sm="2">
          <Links :links="links" :user="effectiveUser" direction="next" />
        </b-col>
      </b-row>

      <b-row class="mt-2">
        <b-col v-if="event.event.countdown" sm="12">
          <Countdown :event="event.event" />
        </b-col>

        <b-col v-if="event.activity" sm="4">
          <ActivityResult :activity="event.activity" />
        </b-col>

        <b-col v-if="event.results" sm="4">
          <EventResult :results="event.results" :results_url="event.event.results_url" />
        </b-col>

        <b-col v-if="event.registration.fundraising" sm="6">
          <Fundraising :fundraising="event.registration.fundraising" />
        </b-col>
      </b-row>

    </b-container>
    <b-container v-else>
      <h3>{{ error }}</h3>
    </b-container>
  </layout-default>
</template>

<script>
import LayoutDefault from '@/layouts/LayoutDefault.vue';
import SideBar from '@/components/SideBar.vue';

import EventDetails from '@/components/event/cards/EventDetails.vue';
import RegistrationStatus from '@/components/event/fragments/Registered.vue';
import Countdown from '@/components/event/cards/Countdown.vue';
import ActivityResult from '@/components/activity/cards/Result.vue';
import EventResult from '@/components/event/cards/Result.vue';
import Fundraising from '@/components/event/cards/Fundraising.vue';
import Links from '@/components/event/fragments/Links.vue';

const moment = require('moment');

export default {
  components: {
    LayoutDefault,
    SideBar,

    EventDetails,
    RegistrationStatus,
    Countdown,
    ActivityResult,
    EventResult,
    Fundraising,
    Links
  },
  data() {
    return {
      event: null,
      links: null,
      error: "",
      sidebarOps: [
        { text: 'Edit Event', to: { name: 'edit_event' } },
        { text: 'Delete Event', to: { name: 'delete_event' }, variant: "danger" }
      ]
    }
  },
  methods: {
    init() {
      let self = this;
      this.$http.get("event/" + self.effectiveUser + "/" + this.$route.params.id)
      .then(response => {
        self.event = response.data.event;
        self.links = response.data.links;
      })
      .catch(err => self.error = err.response.data.message);
    }
  },
  mounted() {
    this.init();
  },
  watch: {
    '$route.params': {
      handler(newValue) {
        this.init();
      },
      immediate: true
    }
  },
  computed: {
    effectiveUser: function() {
      if(this.$route.params.user)
        return this.$route.params.user;
      return this.$store.getters['auth/currentUser'].username;
    },
    eventIsInFuture: function() {
      return moment(this.event.event.scheduled_start).diff(moment()) > 0;
    }
  }
}
</script>

<style scoped>

</style>
