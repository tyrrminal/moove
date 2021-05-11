<template>
  <layout-default>
    <template #sidebar>
      <SideBar :items="sidebarOps" />
    </template>

    <b-container v-if="event">
      <b-row>
        <b-col sm="1">
          <Links :links="links" :user="effectiveUser" direction="prev" />
        </b-col>
        <b-col sm="10" md="7" lg="5" class="mx-auto">
          <RegistrationStatus
            :registration="event.registration"
            :isInFuture="eventIsInFuture"
          />
          <EventDetails
            :event="event.event"
            :isPublic="event.registration.is_public"
          />
        </b-col>
        <b-col sm="1">
          <Links :links="links" :user="effectiveUser" direction="next" />
        </b-col>
      </b-row>

      <b-row v-if="sequence && sequence.length > 1">
        <EventSequence
          class="mx-auto"
          :id="event.event.event_sequence_id"
          :events="sequence"
          :current="event.event.id"
        />
      </b-row>

      <b-row class="mt-2">
        <b-col v-if="event.event.countdown" sm="12">
          <Countdown :event="event.event" />
        </b-col>

        <b-col v-if="event.activity" sm="4" class="mb-2">
          <ActivityResult :activity="event.activity" />
        </b-col>

        <b-col v-if="event.results" sm="4" class="mb-2">
          <EventResult
            :results="event.results.groups"
            :results_url="event.results.url"
          />
        </b-col>

        <b-col
          v-if="event.activity && event.activity.records"
          sm="6"
          class="mb-2"
        >
          <ActivityRecords :records="event.activity.records" />
        </b-col>

        <b-col
          v-if="event.activity && event.activity.achievements"
          sm="3"
          class="mb-2"
        >
          <ActivityAchievements :records="event.activity.achievements" />
        </b-col>

        <b-col v-if="event.registration.fundraising" sm="6" class="mb-2">
          <Fundraising :fundraising="event.registration.fundraising" />
        </b-col>

        <b-col v-if="event.activity && event.activity.note" sm="4" class="mb-2">
          <Notes :text="event.activity.note" />
        </b-col>
      </b-row>
    </b-container>
    <b-container v-else>
      <h3>{{ error }}</h3>
    </b-container>
  </layout-default>
</template>

<script>
import { mapGetters } from "vuex";
import Branding from "@/mixins/Branding.js";
import EventFilters from "@/mixins/EventFilters.js";
import UnitConversion from "@/mixins/UnitConversion.js";
import { DateTime } from "luxon";
import Countdown from "vuejs-countdown";
import AddDonation from "@/components/event/fundraising/AddDonation.vue";

export default {
  name: "EventDetail",
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  mixins: [Branding],
  components: {
    LayoutDefault,
    SideBar,

    EventDetails,
    RegistrationStatus,
    Countdown,
    ActivityResult,
    ActivityRecords,
    ActivityAchievements,
    EventResult,
    Fundraising,
    Notes,
    Links,
    EventSequence,
  },
  data: function () {
    return {
      event: null,
      links: null,
      error: "",
      sequence: [],
      eventSidebarOps: [
        { text: "Edit Registration", to: { name: "edit_event" } },
        {
          text: "Remove from My Events",
          to: { name: "delete_event" },
          variant: "danger",
        },
      ],
    };
  },
  methods: {
    init() {
      let self = this;
      this.sequence = [];
      this.$http
        .get("event/" + self.effectiveUser + "/" + this.$route.params.id)
        .then(response => {
          self.event = response.data.event;
          self.sequence = response.data.sequence;
          self.links = response.data.links;
        })
        .catch(err => (self.error = err.response.data.message));
    }
  },
  created() {
    this.init();
  },
  watch: {
    "$route.params": {
      handler(newValue) {
        this.init();
      },
      immediate: true,
    },
  },
  computed: {
    title: function () {
      return `${this.applicationName} / Events: ${this.event.eventActivity.event.name}`;
    },
    effectiveUser: function () {
      if (this.$route.params.user) return this.$route.params.user;
      return this.$store.getters["auth/currentUser"].username;
    },
    eventIsInFuture: function () {
      return moment(this.event.event.scheduled_start).diff(moment()) > 0;
    },
    sidebarOps: function () {
      if (
        this.event &&
        this.event.registration.user.id ===
          this.$store.getters["auth/currentUser"].id
      )
        return this.eventSidebarOps;
      return [];
    },
  },
};
</script>

<style scoped>
</style>
