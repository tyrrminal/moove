<template>
  <b-container v-if="userEventActivity">
    <b-card no-body class="mt-3 mb-3">
      <b-card-header>
        <b-button-group class="float-right">
          <b-button
            v-for="n in navLinks"
            :key="n.id"
            variant="outline-secondary"
            :disabled="nav[n.id] == null"
            :to="
              nav[n.id] ? { to: 'event', params: { id: nav[n.id].id } } : null
            "
            :title="nav[n.id] ? nav[n.id].name : ''"
            ><b-icon :icon="n.icon"
          /></b-button>
        </b-button-group>
        <h2>{{ event.year }} {{ event.name }}</h2></b-card-header
      >
      <b-card-body>
        <b-row>
          <b-col cols="6">
            <b-jumbotron class="py-2 event-details" border-variant="primary">
              <b-form-group label="What">
                {{ Number.parseFloat(eventActivity.distance.value) }}
                {{ uom(eventActivity.distance.unitOfMeasureID).abbreviation }}
                {{ eventActivity.eventType.description }}
              </b-form-group>
              <b-form-group label="When">
                <b-icon icon="calendar" class="mr-1" />{{
                  eventActivity.scheduledStart
                    | luxon({ input: { zone: "local" }, output: "short" })
                }}
              </b-form-group>
              <b-form-group
                label="Where"
                v-if="$options.filters.formatAddress(event.address)"
              >
                <b-icon icon="compass" class="mr-1" />{{
                  event.address | formatAddress
                }}
              </b-form-group>
              <b-form-group
                label="Website"
                v-if="eventGroup != null && eventGroup.url"
              >
                <b-link :href="eventGroup.url" target="_blank">{{
                  eventGroup.url
                }}</b-link>
              </b-form-group>
            </b-jumbotron>
          </b-col>
          <b-col>
            <b-jumbotron class="py-2 event-details" border-variant="info">
              <b-form-group
                label="Registered On"
                v-if="userEventActivity.date_registered"
              >
                {{
                  userEventActivity.date_registered
                    | luxon({ input: { zone: "local" }, output: "date_med" })
                }}
              </b-form-group>
              <b-form-group
                label="Total Fee"
                v-if="userEventActivity.fee != null"
              >
                {{ userEventActivity.fee | currency }}
              </b-form-group>
              <b-form-group
                label="Registration Number"
                v-if="userEventActivity.registration_number != null"
              >
                #{{ userEventActivity.registration_number }}
              </b-form-group>
            </b-jumbotron>
          </b-col>
        </b-row>
      </b-card-body>
    </b-card>

    <b-card no-body class="mb-3" v-if="eventIsInFuture">
      <b-card-header><h3>Countdown</h3></b-card-header>
      <b-card-body>
        <Countdown :end="countdownTarget" />
      </b-card-body>
    </b-card>

    <b-card no-body v-if="activity" class="mb-3">
      <b-card-header><h3>Results</h3></b-card-header>
      <b-card-body>
        <b-jumbotron class="p-2" v-if="activity.note">
          <em>{{ activity.note }}</em>
        </b-jumbotron>
        <b-row>
          <b-col cols="4">
            <b-jumbotron class="event-details py-2" border-variant="secondary">
              <b-form-group label="Measured Distance">
                {{ fillUnits(activity.distance) | formatDistance }}
              </b-form-group>
              <b-form-group label="Total Time" v-if="activity.duration">
                {{ activity.duration }}
              </b-form-group>
              <b-form-group
                label="Net Time"
                v-if="
                  activity.net_time && activity.duration != activity.net_time
                "
              >
                {{ activity.net_time }}
              </b-form-group>
              <b-form-group label="Avg. Pace" v-if="activity.pace">
                {{ fillUnits(activity.pace) | formatDistance }}
              </b-form-group>
              <b-form-group label="Avg. Speed" v-if="activity.speed">
                {{ fillUnits(activity.speed) | formatDistance }}
              </b-form-group>
              <b-form-group label="Temperature" v-if="activity.temperature">
                {{ activity.temperature }}° F
              </b-form-group>
            </b-jumbotron>
          </b-col>

          <b-col cols="8">
            <div v-for="(p, i) in orderedPlacements" :key="i">
              <h5>{{ p.description }}: {{ p.place }} / {{ p.of }}</h5>
              <b-progress height="2rem" class="my-2">
                <b-progress-bar
                  :value="100 - (100 * p.place) / p.of"
                  :max="100"
                  :animated="p.place <= 3"
                  :style="{ fontSize: '1.25rem' }"
                  :variant="progressClass(1 - p.place / p.of, 2)"
                  >{{ (1 - p.place / p.of) | percent(1) }}
                </b-progress-bar>
              </b-progress>
            </div>

            <div class="text-center mt-4">
              <b-link
                v-if="eventActivity.resultsURL"
                :href="eventActivity.resultsURL"
                target="_blank"
                >Original Results</b-link
              >
            </div>
          </b-col>
        </b-row>
      </b-card-body>
    </b-card>

    <b-card v-if="fundraising" no-body class="mb-3">
      <b-card-header
        ><b-button
          class="float-right"
          size="sm"
          variant="outline-primary"
          v-b-modal.addDonation
          ><b-icon icon="plus"
        /></b-button>
        <h3>Fundraising</h3></b-card-header
      >
      <b-card-body>
        <h4>
          <div class="float-right">
            {{ (fundraising.received / fundraising.minimum) | percent(1) }}
          </div>
          Raised {{ fundraising.received | currency | stripDecimals }} of
          {{ fundraising.minimum | currency | stripDecimals }}
        </h4>

        <b-progress
          v-if="fundraising.received >= fundraising.minimum"
          height="8px"
          class="bg-success upper-progress-bar"
        >
          <b-progress-bar
            :value="fundraising.minimum"
            :max="fundraising.received"
            variant="secondary"
          >
          </b-progress-bar>
        </b-progress>
        <b-progress
          v-if="fundraising.donations"
          height="3rem"
          class="middle-progress-bar"
        >
          <b-progress-bar
            v-for="(d, i) in donors"
            :key="d.id"
            :value="donorTotal(d)"
            :max="fundraising.minimum"
            :class="donorProgressClass(d, i)"
            :variant="progressClass(fundraising.received / fundraising.minimum)"
            v-b-tooltip.hover
            :title="[d.firstname, d.lastname].join(' ')"
            @click.native="showDonorHistory(d)"
            >{{ sumStr(d.donations.map((v) => v.amount)) }}
          </b-progress-bar>
        </b-progress>
        <b-progress v-else height="2rem" class="middle-progress-bar">
          <b-progress-bar
            :variant="progressClass(fundraising.received / fundraising.minimum)"
            :value="fundraising.received"
            :max="fundraising.minimum"
          >
          </b-progress-bar>
        </b-progress>
        <b-progress
          v-if="fundraising.received >= fundraising.minimum"
          height="8px"
          class="bg-success lower-progress-bar"
        >
          <b-progress-bar
            :value="fundraising.minimum"
            :max="fundraising.received"
            variant="secondary"
          >
          </b-progress-bar>
        </b-progress>
      </b-card-body>
    </b-card>

    <AddDonation
      :userEventActivityID="userEventActivity.id"
      @update="updateFundraising"
    />

    <b-modal id="donationHistory" :title="donationHistoryTitle" size="lg">
      <b-table
        v-if="person"
        :items="person.donations"
        :fields="donorFields"
        foot-clone
      >
        <template #cell(amount)="data">
          {{ data.value | currency }}
        </template>
        <template #cell(date)="data">
          {{ data.value | luxon({ input: { zone: "local" }, output: "DD" }) }}
        </template>
        <template #cell(event)="data">
          {{ data.value.eventYear }} {{ data.value.eventName }}
          <span v-if="data.value.eventActivityName"
            >({{ data.value.eventActivityName }})</span
          >
        </template>

        <template #foot(amount)>
          {{
            person.donations.reduce(
              (a, c) => a + Number.parseFloat(c.amount),
              0
            ) | currency
          }}
        </template>
        <template #foot(date)>Total</template>
        <template #foot()><span></span></template>
      </b-table>
    </b-modal>
  </b-container>
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
  mixins: [Branding, EventFilters, UnitConversion],
  components: {
    Countdown,
    AddDonation,
  },
  data: function () {
    return {
      navLinks: [
        { id: "prev", icon: "chevron-left" },
        { id: "next", icon: "chevron-right" },
      ],
      nav: {
        next: null,
        prev: null,
      },

      event: null,
      eventActivity: null,
      eventGroup: null,
      eventSeries: null,
      userEventActivity: null,
      fundraising: null,
      activity: null,

      person: null,
      donorFields: [{ key: "date" }, { key: "event" }, { key: "amount" }],
    };
  },
  props: {
    id: {
      type: [Number, String],
      required: true,
    },
  },
  methods: {
    init: function () {
      let self = this;
      this.sequence = [];
      this.$http
        .get(["user", "events", this.id].join("/"))
        .then((response) => {
          self.userEventActivity = response.data;
          self.eventActivity = self.userEventActivity.eventActivity;
          delete self.userEventActivity.eventActivity;
          self.event = self.eventActivity.event;
          delete self.eventActivity.event;
          self.eventSeries = self.event.eventSeries;
          delete self.event.eventSeries;
          self.eventGroup = self.event.eventGroup;
          delete self.event.eventGroup;
          self.activity = self.userEventActivity.activity;
          delete self.userEventActivity.activity;
          self.fundraising = self.userEventActivity.fundraising;
          delete self.userEventActivity.fundraising;
          self.nav = self.userEventActivity.nav;
          delete self.userEventActivity.nav;
        })
        .catch((err) => (self.error = err.response.data.message));
    },
    updateFundraising: function (newValue) {
      this.fundraising = newValue;
    },
    progressClass: function (v, ts = 1) {
      let t = ts == 1 ? [1, 0.5] : [2 / 3, 1 / 3];
      if (v >= t[0]) return "success";
      if (v >= t[1]) return "warning";
      return "danger";
    },
    donorTotal: function (d) {
      let t = d.donations
        .map((v) => v.amount)
        .reduce((a, c) => Number.parseFloat(c) + a, 0);
      return t;
    },
    sumStr: function (a) {
      return a
        .map((v) =>
          this.$options.filters.stripDecimals(this.$options.filters.currency(v))
        )
        .join(" + ");
    },
    showDonorHistory: function (d) {
      this.$http.get(["donors", d.id].join("/")).then((resp) => {
        this.person = { ...resp.data.person, donations: resp.data.donations };
        this.$bvModal.show("donationHistory");
      });
    },
    donorProgressClass: function (d, i) {
      let c = ["clickable-progress"];
      if (i > 0) c.push("separated-progress");
      return c;
    },
  },
  mounted() {
    this.init();
  },
  watch: {
    id: {
      handler(newValue) {
        this.init();
      },
      immediate: true,
    },
  },
  computed: {
    ...mapGetters("meta", { uom: "getUnitOfMeasure" }),
    title: function () {
      if (this.event)
        return `${this.applicationName} / Event / ${this.event.year} ${this.event.name}`;
      else return this.applicationName;
    },
    effectiveUser: function () {
      if (this.$route.params.user) return this.$route.params.user;
      return this.$store.getters["auth/currentUser"].username;
    },
    eventIsInFuture: function () {
      return (
        DateTime.fromISO(this.eventActivity.scheduledStart) > DateTime.local()
      );
    },
    countdownTarget: function () {
      return DateTime.fromISO(this.eventActivity.scheduledStart)
        .setZone("local")
        .toFormat("f");
    },
    orderedPlacements: function () {
      if (
        this.userEventActivity == null ||
        this.userEventActivity.placements == null ||
        this.userEventActivity.placements.length == 0
      )
        return [];
      return [...this.userEventActivity.placements].sort((a, b) => b.of - a.of);
    },
    donors: function () {
      if (this.fundraising.donations == null) return null;
      let donors = [];
      this.fundraising.donations.forEach((d) => {
        let p = donors.find((x) => x.id == d.person.id);
        if (p == null) {
          p = { ...d.person, adddress: d.address, donations: [] };
          donors.push(p);
        }
        p.donations.push({ amount: d.amount, date: d.date });
      });
      return donors.sort((a, b) => this.donorTotal(a) - this.donorTotal(b));
    },
    donationHistoryTitle: function () {
      let base = "Donation History";
      if (this.person == null) return base;
      return [
        [this.person.firstname, this.person.lastname].join(" "),
        base,
      ].join("'s ");
    },
  },
};
</script>

<style>
.event-details legend {
  font-weight: bold;
}
.clickable-progress {
  cursor: pointer;
}
.separated-progress {
  border-left: 2px solid gray;
}
.upper-progress-bar {
  border-radius: 0.25rem 0.25rem 0px 0px !important;
}
.middle-progress-bar {
  border-radius: 0px !important;
}
.lower-progress-bar {
  border-radius: 0px 0px 0.25rem 0.25rem !important;
}
</style>
