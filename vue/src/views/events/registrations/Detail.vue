<template>
  <b-container v-if="userEventActivity" fluid>
    <b-row>
      <b-col cols="2" class="bg-light pt-2">
        <div>
          <h4 class="float-right">
            <b-link v-if="nav.global.prev"
              :to="{ name: 'registration-detail', params: { id: nav.global.prev.id } }"><b-icon icon="chevron-left"
                :title="`${nav.global.prev.year} ${nav.global.prev.name}`" variant="dark" /></b-link>
            <b-icon v-else icon="chevron-left" :style="{ color: 'gray' }" />
            <b-link v-if="nav.global.next"
              :to="{ name: 'registration-detail', params: { id: nav.global.next.id } }"><b-icon icon="chevron-right"
                :title="`${nav.global.next.year} ${nav.global.next.name}`" variant="dark" /></b-link>
            <b-icon v-else icon="chevron-right" :style="{ color: 'gray' }" />
          </h4>

          <h4>{{ event.year }} </h4>
          <div class="data-value-form">
            <b-form-group v-if="eventActivity" label="What">{{ eventActivityDescription }}
            </b-form-group>
            <b-form-group label="When">
              <b-icon icon="calendar" class="mr-1" />{{
                eventActivity.scheduledStart
                | luxon({ input: { zone: "local" }, output: "short" })
              }}
            </b-form-group>
            <b-form-group label="Where" v-if="$options.filters.formatAddress(event.address)">
              <b-icon icon="compass" class="mr-1" />{{
                event.address | formatAddress
              }}
            </b-form-group>
            <b-form-group label="Website" v-if="eventGroup != null && eventGroup.url">
              <b-link :href="eventGroup.url" target="_blank">{{
                eventGroup.url
                }}</b-link>
            </b-form-group>

            <b-button variant="secondary" :to="{ name: 'event-edit', params: { id: event.id } }" size="sm" block pill
              class="my-1"><b-icon icon="pencil" class="mr-1" />Modify</b-button>
            <b-button variant="success" :to="{ name: 'event-create', params: { event, eventGroup, eventActivity } }"
              size="sm" block pill class="my-1"><b-icon icon="plus-circle" class="mr-2" />Clone</b-button>
          </div>

          <div v-if="isRegistered" class="data-value-form">
            <hr />
            <b-form-group label="Registered On" v-if="userEventActivity.dateRegistered">
              {{
                userEventActivity.dateRegistered
                | luxon({ input: { zone: "local" }, output: "date_med" })
              }}
            </b-form-group>
            <b-form-group label="Total Fee" v-if="userEventActivity.registrationFee != null">
              {{ userEventActivity.registrationFee | currency }}
            </b-form-group>
            <b-form-group label="Registration Number" v-if="userEventActivity.registrationNumber != null">
              #{{ userEventActivity.registrationNumber }}
            </b-form-group>

            <b-button variant="secondary" :to="{ name: 'registration-edit', params: { id: userEventActivity.id } }"
              size="sm" block pill><b-icon icon="pencil" class="mr-2" />Modify</b-button>
          </div>
        </div>
      </b-col>

      <b-col cols="9">
        <h3 class="float-right my-2">
          <div v-if="nav.group && (nav.group.prev || nav.group.next)" :style="{ fontSize: '10pt' }">
            <b-link v-if="nav.group.prev"
              :to="{ name: 'registration-detail', params: { id: nav.group.prev.id } }"><b-icon icon="chevron-left"
                :title="`${nav.group.prev.year} ${nav.group.prev.name}`" variant="dark" /></b-link>
            <b-icon v-else icon="chevron-left" :style="{ color: 'gray' }" />
            <b-link :to="{ name: 'registration-series', params: { id: nav.group.id } }"
              class="text-dark font-weight-bold">{{
                nav.group.description
              }}</b-link>
            <b-link v-if="nav.group.next"
              :to="{ name: 'registration-detail', params: { id: nav.group.next.id } }"><b-icon icon="chevron-right"
                :title="`${nav.group.next.year} ${nav.group.next.name}`" variant="dark" /></b-link>
            <b-icon v-else icon="chevron-right" :style="{ color: 'gray' }" />
          </div>
          <div v-if="nav.series.length">
            <div v-for="s in nav.series.filter(s => s.prev || s.next)" :style="{ fontSize: '10pt' }">
              <b-link v-if="s.prev" :to="{ name: 'registration-detail', params: { id: s.prev.id } }"><b-icon
                  icon="chevron-left" :title="`${s.prev.year} ${s.prev.name}`" variant="dark" /></b-link>
              <b-icon v-else icon="chevron-left" :style="{ color: 'gray' }" />
              <b-link :to="{ name: 'registration-series', params: { id: s.id } }" class="text-dark">{{ s.description
                }}</b-link>
              <b-link v-if="s.next" :to="{ name: 'registration-detail', params: { id: s.next.id } }"><b-icon
                  icon="chevron-right" :title="`${s.next.year} ${s.next.name}`" variant="dark" /></b-link>
              <b-icon v-else icon="chevron-right" :style="{ color: 'gray' }" />
            </div>
          </div>
        </h3>

        <h3 class="my-2">
          <template v-if="eventGroup">
            <span class="text-dark">{{ event.name }}</span>
          </template>
          <template v-else>
            <span>{{ event.name }}</span>
          </template>
        </h3>

        <div v-if="eventIsInFuture" class="text-center mt-5">
          <vue-ellipse-progress v-if="countdownPctElapsed" :progress="countdownPctElapsed" :size="48" :thickness="3"
            color="gray" :legend="false" class="d-inline-block mr-3">
            <template #legend-caption>
              <vue-ellipse-progress v-if="countdownPctElapsed > 95"
                :progress="10 * (countdownPctElapsed - (Math.trunc(countdownPctElapsed / 10) * 10))" :size="24"
                :thickness="3" color="gray" :legend="false" :style="{ marginTop: '6px' }" />
            </template>
          </vue-ellipse-progress>
          <Countdown :end="countdownTarget" class="d-inline-block" />
        </div>

        <div :style="{ clear: 'both' }">
          <ActivityNote v-if="activity && activity.note" class="mb-2">{{ activity.note }}</ActivityNote>
        </div>

        <div class="bg-light p-2 mb-3 border border-gray" v-if="fundraising">
          <b-button @click="addDonation" size="sm" pill class="float-right mr-2 px-3"
            :variant="isOutOfDate ? 'warning' : 'success'"><b-icon icon="plus-circle" class="mr-2" />Add
            Donation</b-button>
          <legend>Fundraising</legend>
          <FundraisingChart :data="fundraisingChartData" @selectDonor="showDonorHistory" class="px-3" />
          <hr />
          <div class="d-inline-block w-50">
            Progress: {{ fundraising.received | currency }} of {{ fundraising.minimum | currency }} ({{
              fundraising.received / fundraising.minimum | percent(1) }}) <b-icon icon="check-lg" variant="success"
              v-if="fundraising.received >= fundraising.minimum" class="ml-1" />
          </div>
          <div class="text-right d-inline-block" :style="{ width: '49%' }">
            <b-button v-b-modal.donationHistory size="sm" variant="info"><b-icon icon="list"
                class="mr-1" />Donations</b-button>
          </div>
        </div>

        <div v-if="hasResults || canDoResultsFunctions" class="bg-light p-2 border border-gray mb-3">
          <EventResultChart v-if="hasResults" :data="orderedPlacements" class="px-3" :style="{ clear: 'both' }" />
          <b-progress v-else-if="isLoading" height="1.5rem" class="my-2">
            <b-progress-bar variant="info" :value="eventActivity.results.importCompletion" :max="100"><span
                class="font-weight-bold">Importing Results&hellip;</span></b-progress-bar>
          </b-progress>
          <div v-else-if="canDoResultsFunctions" class="text-center">
            <b-button pill variant="success" @click="initiateResultsImport" class="mr-2 px-3">
              <b-icon icon="download" class="mr-2" :rotate="-90" />Import Results</b-button>
          </div>
          <div v-if="eventActivity.results.url">
            <hr v-if="hasResults" />
            <b-button v-if="hasResults && canDoResultsFunctions" pill variant="warning" v-b-modal.importResults
              size="sm" class="float-right mr-2 px-3">
              <b-icon icon="arrow-repeat" class="mr-2" />Re-import Results</b-button>
            <b-link :href="eventActivity.results.url" target="_blank" :style="{ fontSize: '10pt' }">
              Original Results
            </b-link>
            <div :style="{ clear: 'both' }"></div>
          </div>
        </div>

        <ActivityCard v-if="activity" :activity="activity" :activity2="eventResult" class="mb-3" />

      </b-col>
    </b-row>

    <AddDonation :userEventActivityID="userEventActivity.id" @update="updateFundraising" />

    <b-modal id="donorHistory" :title="donorHistoryTitle" size="lg" ok-only>
      <DonationHistory v-if="person" :donations="person.donations"
        @selectEvent="e => { $bvModal.hide('donorHistory'); $bvModal.hide('donationHistory'); $router.push({ name: 'registration-detail', params: { id: e.id } }) }" />
    </b-modal>

    <b-modal id="donationHistory" :title="`${event.year} ${event.name} Donations`" size="lg" ok-only>
      <DonationHistory v-if="fundraising" :donations="fundraising.donations" contextKey="person"
        @selectDonor="showDonorHistory" />
    </b-modal>

    <b-modal id="importResults" body-class="mx-0 px-0 mb-0 pb-0" hide-footer>
      <template #modal-title>
        <span v-if="hasResults">Re-import Results</span>
        <span v-else>Import Results</span>
      </template>
      <b-form @submit.prevent="importResults" name="results-import-data-form">
        <div class="mx-4">
          <b-alert v-if="hasResults" show variant="warning">All existing results will be deleted prior to re-importing
            data.</b-alert>
          <b-alert v-else show variant="secondary">Import event activity results</b-alert>
          <b-form-group v-for="(f, i) in eventActivity.results.fields" :key="i" :label="f">
            <b-input v-model="importFields[f]" :name="`${f}_${eventActivity.id}`" autocomplete="on" />
          </b-form-group>
        </div>
        <footer class="modal-footer">
          <b-button variant="secondary" @click="$bvModal.hide('importResults')">Cancel</b-button>
          <b-button v-if="hasResults" variant="warning" type="submit">Re-import</b-button>
          <b-button v-else variant="primary" type="submit">Import</b-button>
        </footer>
      </b-form>
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
import { VueEllipseProgress } from "vue-ellipse-progress";
import AddDonation from "@/components/event/fundraising/AddDonation.vue";
import ActivityCard from "@/components/activity/cards/Result";
import ActivityNote from "@/components/activity/Note.vue";
import RelatedEventNav from "@/components/event/RelatedEventNav";
import FundraisingChart from "@/components/activity/charts/Fundraising.vue";
import EventResultChart from "@/components/activity/charts/EventResult.vue";
import DonationHistory from "@/components/event/fundraising/History.vue";
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
    VueEllipseProgress,
    AddDonation,
    ActivityCard,
    ActivityNote,
    RelatedEventNav,
    DonationHistory,
    FundraisingChart,
    EventResultChart
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
      eventResult: null,

      nav: {},

      person: null,

      importFields: {}
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
          self.nav.global = self.userEventActivity.nav.find(x => x.description == null);
          self.nav.group = self.userEventActivity.nav.find(x => x.id = self.eventGroup.id);
          self.nav.group.description = self.eventGroup.name;
          self.nav.series = self.userEventActivity.nav.filter(x => x.description != null && x.id != self.eventGroup.id)
          if (self.userEventActivity.eventResult)
            self.eventResult = {
              ...self.userEventActivity.eventResult,
              activityTypeID: self.eventActivity.eventType.activityType.id,
            };
          else self.eventResult = null;
          delete self.userEventActivity.eventResult;
          self.fundraising = self.userEventActivity.fundraising;
          delete self.userEventActivity.fundraising;
          if (
            self.eventActivity.results.importable &&
            self.eventActivity.results.importCompletion != null &&
            self.eventActivity.results.importCompletion < 100
          )
            self.checkImportStatus();
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
    addDonation: function () {
      if (this.isOutOfDate) {
        this.$bvModal.msgBoxConfirm('This event occurred over one year ago. Are you sure you want to add a new donation to it?', {
          title: "Event Out of Date",
          okVariant: "warning",
          okTitle: "Continue"
        }).then(value => {
          if (value) this.$bvModal.show('addDonation')
        })
      } else {
        this.$bvModal.show('addDonation')
      }
    },
    showDonorHistory: function (d) {
      this.$http.get(["donors", d.id].join("/")).then((resp) => {
        this.person = { ...resp.data.person, donations: resp.data.donations };
        this.$bvModal.show("donorHistory");
      });
    },
    donorProgressClass: function (d, i) {
      let c = ["clickable-progress"];
      if (i > 0) c.push("separated-progress");
      return c;
    },
    initiateResultsImport: function () {
      if (this.eventActivity.results.fields.length)
        this.$bvModal.show('importResults');
      else
        this.importResults();
    },
    importResults: function () {
      this.$root.$emit('bv::hide::modal', 'importResults')
      let self = this;
      if (this.hasResults) {
        self.$nextTick(() => {
          self.eventResult = null;
          if (self.userEventActivity)
            self.userEventActivity.placements = null;
        });
      }
      this.$http
        .post(["events", "activities", this.eventActivity.id, "results"].join("/"), { importFields: this.importFields })
        .then((resp) => {
          self.eventActivity.results.importCompletion = 1;
          self.checkImportStatus();
        });
    },
    checkImportStatus: function () {
      let self = this;
      let timeout = function () {
        return Math.floor(Math.random() * (1500 - 500) + 500);
      };
      this.$http
        .get(
          ["events", "activities", this.eventActivity.id, "results"].join("/")
        )
        .then((resp) => {
          this.eventActivity.results.importCompletion =
            resp.data.importCompletion;
          if (this.eventActivity.results.importCompletion == 100) {
            this.eventActivity.results.importCompletion = 99.9;
            this.init();
          } else
            setTimeout(function () {
              self.checkImportStatus();
            }, timeout());
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
    isLoading: function () {
      return (
        this.eventActivity.results.importCompletion != null &&
        this.eventActivity.results.importCompletion < 100
      );
    },
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
    isOutOfDate: function () {
      return DateTime.fromISO(this.eventActivity.scheduledStart) < DateTime.now().minus({ years: 1 })
    },
    isRegistered: function () {
      return this.userEventActivity.dateRegistered ||
        Number.parseFloat(this.userEventActivity.registrationFee) ||
        this.userEventActivity.registrationNumber
    },
    countdownPctElapsed: function () {
      if (!this.userEventActivity.dateRegistered) return null;
      let start = DateTime.fromISO(this.userEventActivity.dateRegistered).toUnixInteger();
      let end = DateTime.fromISO(this.eventActivity.scheduledStart).toUnixInteger();
      let now = DateTime.local().toUnixInteger();
      return 100 * (1 - ((end - now) / (end - start)));
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
    donorHistoryTitle: function () {
      let base = "Donation History";
      if (this.person == null) return base;
      return [
        [this.person.firstname, this.person.lastname].join(" "),
        base,
      ].join("'s ");
    },
    fundraisingChartData: function () {
      if (!this.fundraising) return {}
      return {
        donations: [...this.fundraising.donations],
        minimum: this.fundraising.minimum,
        received: this.fundraising.received,
        from: this.userEventActivity.dateRegistered,
        to: this.eventActivity.scheduledStart,
      };
    }
  },
};
</script>

<style>
.data-value-form {
  font-size: 10pt;
}

.data-value-form legend {
  font-weight: bold;
  font-size: 9pt;
}

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
