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
          >
            <b-icon :icon="n.icon" />
          </b-button>
        </b-button-group>
        <h2>{{ event.year }} {{ event.name }}</h2>
      </b-card-header>
      <b-card-body>
        <b-row>
          <b-col cols="6">
            <b-jumbotron class="py-2 event-details" border-variant="primary">
              <b-form-group v-if="eventActivity" label="What"
                >{{ eventActivityDescription }}
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
            <b-jumbotron
              class="py-2 event-details"
              border-variant="info"
              v-if="relatedEvents.length"
            >
              <b-form-group label="Related Events">
                <RelatedEventNav
                  v-for="s in relatedEvents"
                  :key="s.id"
                  :series="{ ...s, username: userEventActivity.user.username }"
                  :next="s.next"
                  :prev="s.prev"
                  :create-event-params="{ event, eventGroup, eventActivity }"
                />
              </b-form-group>
            </b-jumbotron>
            <b-jumbotron
              class="py-2 event-details"
              border-variant="info"
              v-if="
                userEventActivity.dateRegistered ||
                Number.parseFloat(userEventActivity.registrationFee) ||
                userEventActivity.registrationNumber
              "
            >
              <b-form-group
                label="Registered On"
                v-if="userEventActivity.dateRegistered"
              >
                {{
                  userEventActivity.dateRegistered
                    | luxon({ input: { zone: "local" }, output: "date_med" })
                }}
              </b-form-group>
              <b-form-group
                label="Total Fee"
                v-if="userEventActivity.registrationFee != null"
              >
                {{ userEventActivity.registrationFee | currency }}
              </b-form-group>
              <b-form-group
                label="Registration Number"
                v-if="userEventActivity.registrationNumber != null"
              >
                #{{ userEventActivity.registrationNumber }}
              </b-form-group>
            </b-jumbotron>
          </b-col>
        </b-row>
      </b-card-body>
    </b-card>

    <b-card no-body class="mb-3" v-if="eventIsInFuture">
      <b-card-header>
        <h3>Countdown</h3>
      </b-card-header>
      <b-card-body>
        <Countdown :end="countdownTarget" />
      </b-card-body>
    </b-card>

    <b-card no-body class="mb-3" v-if="activity || eventResult">
      <b-card-header>
        <h3>Results</h3>
      </b-card-header>
      <b-card-body>
        <b-jumbotron class="p-2" v-if="activity && activity.note">
          <em>{{ activity.note }}</em>
        </b-jumbotron>
        <b-row>
          <b-col v-if="activity" cols="4">
            <ActivityCard :activity="activity" />
          </b-col>

          <b-col v-if="eventResult" cols="4">
            <ActivityCard
              :activity="eventResultActivity"
              :linkToActivity="false"
              :editable="false"
              title="Event Result"
            />
          </b-col>

          <b-col>
            <div v-if="canDoResultsFunctions" class="mb-4">
              <template v-if="isLoading">
                <b-progress-bar
                  label="Importing Results..."
                  animated
                  variant="success"
                  :value="100"
                  :max="100"
                />
              </template>
              <template v-else>
                <b-button
                  v-if="hasResults"
                  block
                  variant="warning"
                  @click="reimportResults"
                  size="sm"
                >
                  <b-icon icon="arrow-repeat" class="mr-2" />Re-import
                  Results</b-button
                >
                <b-button v-else block variant="success" @click="importResults">
                  <b-icon icon="upload" class="mr-1" />Import Results</b-button
                >
              </template>
            </div>

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

            <div
              v-if="eventActivity.results.importable"
              class="text-center mt-4"
            >
              <b-link
                v-if="eventActivity.results.url"
                :href="eventActivity.results.url"
                target="_blank"
                >Original Results
              </b-link>
            </div>
          </b-col>
        </b-row>
      </b-card-body>
    </b-card>

    <b-card v-if="fundraising" no-body class="mb-3">
      <b-card-header>
        <b-button
          class="float-right"
          size="sm"
          variant="outline-primary"
          v-b-modal.addDonation
        >
          <b-icon icon="plus" />
        </b-button>
        <h3>Fundraising</h3>
      </b-card-header>
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
import EventFilters from "@/mixins/events/Filters.js";
import UnitConversion from "@/mixins/UnitConversion.js";
import { DateTime } from "luxon";
import Countdown from "vuejs-countdown";
import AddDonation from "@/components/event/fundraising/AddDonation.vue";
import ActivityCard from "@/components/activity/cards/Result";
import RelatedEventNav from "@/components/event/RelatedEventNav";
import { unitValue } from "@/utils/unitValue";

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
    ActivityCard,
    RelatedEventNav,
  },
  data: function () {
    return {
      isLoading: true,
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
      eventResult: null,

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
          this.isLoading = false;
          self.userEventActivity = response.data;
          self.eventActivity = self.userEventActivity.eventActivity;
          delete self.userEventActivity.eventActivity;
          self.event = self.eventActivity.event;
          delete self.eventActivity.event;
          self.eventSeries = self.event.eventSeries;
          delete self.event.eventSeries;
          self.eventGroup = self.event.eventGroup;
          delete self.event.eventGroup;
          this.relatedEvents.forEach((s) => self.getGroupNav(s));
          self.activity = self.userEventActivity.activity;
          delete self.userEventActivity.activity;
          if (self.userEventActivity.eventResult)
            self.eventResult = {
              ...self.userEventActivity.eventResult,
              activityType: self.eventActivity.eventType.activityType,
            };
          else self.eventResult = null;
          delete self.userEventActivity.eventResult;
          self.fundraising = self.userEventActivity.fundraising;
          delete self.userEventActivity.fundraising;
          self.nav = self.userEventActivity.nav;
          delete self.userEventActivity.nav;
        })
        .catch((err) => (self.error = err.response.data.message));
    },
    getGroupNav: function (s) {
      let self = this;
      if (s == null) return;
      this.$http
        .get(["user", "events", "groups", s.id].join("/"))
        .then((resp) => {
          let l = resp.data.events;
          l.sort((a, b) =>
            a.eventActivity.scheduledStart.localeCompare(
              b.eventActivity.scheduledStart
            )
          );
          let idx = l.findIndex((el) => el.id == self.id);
          this.$set(s, "next", l[idx + 1]);
          this.$set(s, "prev", l[idx - 1]);
        });
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
    importResults: function () {
      this.isLoading = true;
      this.$http
        .post(
          ["events", "activities", this.eventActivity.id, "results"].join("/")
        )
        .then((resp) => this.init());
    },
    reimportResults: function () {
      let self = this;
      this.$bvModal
        .msgBoxConfirm(
          "All existing results will be deleted, before re-importing from the remote source. Proceed?"
        )
        .then((value) => {
          if (!value) return;
          self.eventResult = null;
          if (self.userEventActivity) self.userEventActivity.placements = null;
          self.importResults();
        });
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
    ...mapGetters("auth", { isAdmin: "isAdmin" }),
    ...mapGetters("meta", { uom: "getUnitOfMeasure", at: "getActivityType" }),
    title: function () {
      if (this.event)
        return `${this.applicationName} / Event / ${this.event.year} ${this.event.name}`;
      else return this.applicationName;
    },
    canDoResultsFunctions: function () {
      if (!this.isAdmin) return false;
      return this.eventActivity.results.importable;
    },
    hasResults: function () {
      return !!this.eventResult;
    },
    eventActivityDescription: function () {
      return [
        unitValue(this.eventActivity.distance).description,
        this.eventActivity.eventType.description,
      ].join(" ");
    },
    relatedEvents: function () {
      return [this.eventGroup, ...this.eventSeries].filter((s) => s != null);
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
      if (this.fundraising == null || this.fundraising.donations == null)
        return null;
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
    eventResultActivity: function () {
      return this.eventResult;
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
