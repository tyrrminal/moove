<template>
  <b-container fluid>
    <b-row v-if="isMetaLoaded">
      <b-col cols="2" class="bg-sidebar min-vh-100">
        <div class="sticky-top">
          <div class="bg-white mt-2 py-2 pl-3 rounded-lg rounded-top">
            <label class="font-weight-bold" :style="{ fontSize: '10pt' }">Filters</label>
            <EventTypeSelector v-model="eventTypes" class="mb-2 d-block" />
            <multiselect v-if="distanceOptions.length > 1 && isMetaLoaded" v-model="selectedDistances"
              :options="distanceOptions" label="text" track-by="id" class="mb-2" :close-on-select="false"
              :multiple="true" />
            <b-button-group size="sm" v-if="hasPrivateEvents" class="d-block">
              <b-button :pressed.sync="nonprivate" variant="outline-secondary">Public</b-button>
              <b-button :pressed.sync="private" variant="outline-danger">Private</b-button>
            </b-button-group>
          </div>
          <div class="bg-white mt-2 py-2 pl-3 rounded-lg rounded-top">
            <label class="font-weight-bold" :style="{ fontSize: '10pt' }">Options</label>
            <b-checkbox v-model="view.distanceType" size="sm">Show Recorded Distance</b-checkbox>
            <b-checkbox v-model="view.splitYears" v-if="!eventGroupMode" size="sm">Collate by Year</b-checkbox>
          </div>
          <b-skeleton-wrapper :loading="!loaded">
            <EventSummary :events="events" />
            <template #loading>
              <b-list-group class="mt-2 mb-4">
                <b-list-group-item v-for="( s, i ) in  [[90, 50], [55, 66], [70, 80]] " :key="i">
                  <b-skeleton :width="s[0] + '%'" />
                  <b-skeleton :width="s[1] + '%'" type="input" />
                </b-list-group-item>
              </b-list-group>
            </template>
          </b-skeleton-wrapper>
        </div>
      </b-col>
      <b-col cols="10" class="mt-2">
        <div class="float-right" v-if="viewOptions.length > 1">
          <b-form-radio-group buttons button-variant="outline-primary" :options="viewOptions" v-model="view.type"
            size="sm" />
        </div>
        <h2 class="d-inline-block mr-2">{{ listTitle }} </h2><b-spinner v-if="!loaded" variant="info" /><b-select
          v-else-if="eventActivityNames.length > 2 && eventGroupMode" :options="eventActivityNames"
          v-model="eventActivityName" :style="{ width: '8rem' }" class="mb-2 ml-2" />
        <component :is="listView" :events="filteredEvents" :loaded="loaded" :gridOptions="gridOptions" />

        <div v-if="view.splitYears == false && loaded && filteredEvents.length > 1" class="events-chart-container mb-3">
          <component :is="chartType" :data="chartData" />
        </div>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import { mapGetters } from "vuex";
import Multiselect from 'vue-multiselect'

import Branding from "@/mixins/Branding.js";
import Events from "@/mixins/events/API.js";

import EventTypeSelector from "@/components/EventTypeSelector";
import EventSummary from "@/components/event/Summary.vue";
import YearGroupedList from "@/components/event/YearGroupedList.vue";
import UngroupedList from "@/components/event/UngroupedList.vue"

import ActivityChart from "@/components/activity/charts/Speed.vue";
import ResultsChart from "@/components/event/charts/Results.vue";
import FundraisingChart from "@/components/event/charts/Fundraising.vue";

export default {
  name: "EventRegistrationList",
  components: {
    Multiselect,
    EventTypeSelector,
    EventSummary,
    YearGroupedList,
    UngroupedList,
    ActivityChart,
    ResultsChart,
    FundraisingChart
  },
  mixins: [Branding, Events],
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  data: function () {
    return {
      loaded: false,
      events: [],
      params: {
        username: this.username,
        "order.by": "scheduledStart",
        "order.dir": "desc",
      },
      listTitle: "Events",
      eventActivityName: 'All',
      eventTypes: {},
      filters: {
        eventTypeID: null,
        completed: false,
        private: null,
      },
      view: {
        type: 'registration',
        distanceType: false,
        splitYears: true,
      },
      selectedDistances: [],
    };
  },
  props: {
    username: {
      type: String,
    },
  },
  mounted: function () {
    this.init();
  },
  methods: {
    init: function () {
      this.events = [];
      this.loaded = false;
      this.eventActivityName = 'All';
      this.listTitle = "Events";
      delete (this.params.eventGroupID);
      this.view.splitYears = true;
      if (this.eventGroupMode) {
        this.params.eventGroupID = this.$route.params.id
        this.view.splitYears = false
      }
      this.loadEvents();
    },
    loadEvents: function (pageNum = 1) {
      let self = this;
      let params = this.params;
      self.$http
        .get(["user", "events"].join("/"), {
          params: { ...params, "page.number": pageNum },
        })
        .then((resp) => {
          self.events.push(
            ...resp.data.elements.map((x) => this.processEventPlacements(x))
          );
          if (self.events.length < resp.data.pagination.counts.filter)
            self.loadEvents(pageNum + 1);
          else
            self.loaded = true
          if (self.eventGroupMode) {
            self.$http.get("/eventgroups/" + self.params.eventGroupID).then(resp => this.listTitle = resp.data.name)
            this.listTitle = self.events[0].eventActivity.event.eventGroup.name
          }
        });
    },
  },
  computed: {
    ...mapGetters("meta", { getUnitOfMeasure: "getUnitOfMeasure", isMetaLoaded: "isLoaded" }),
    eventGroupMode: function () {
      return this.$route.name == 'registration-series'
    },
    chartType: function () {
      switch (this.view.type) {
        case 'registration': return 'ActivityChart';
        case 'results': return 'ResultsChart';
        case 'fundraising': return 'FundraisingChart';
      }
    },
    gridOptions: function () {
      return {
        showFees: this.view.type == 'registration' || this.view.type == 'fundraising',
        showSpeed: this.view.type == 'registration' || this.view.type == 'results',
        showResults: this.view.type == 'results',
        showFundraising: this.view.type == 'fundraising',
        showActivityDistance: this.view.distanceType,
      }
    },
    viewOptions: function () {
      let opt = [{ text: "Details", value: 'registration' }];
      if (this.events.some(e => !!e.placements))
        opt.push({ text: "Results", value: 'results' });
      if (this.events.some(e => !!e.fundraising))
        opt.push({ text: "Fundraising", value: 'fundraising' })
      return opt;
    },
    title: function () {
      return `${this.applicationName} / ${this.listTitle}`;
    },
    listView: function () {
      return this.view.splitYears ? YearGroupedList : UngroupedList;
    },
    hasPrivateEvents: function () {
      return this.events.some((e) => e.visibilityTypeID == 1)
    },
    eventActivityNames: function () {
      let unique = function (value, index, array) {
        return array.indexOf(value) === index;
      }
      return ["All", ...this.events.map(e => e.eventActivity ? e.eventActivity.name : null).filter(n => n != null).filter(unique)]
    },
    prefilteredEvents: function () {
      let events = this.events;
      if (Object.keys(this.eventTypes).length) events = events.filter(e => this.eventTypes[e.eventActivity.eventType.id])
      if (this.view.type == 'results') events = events.filter((e) => e.placements);
      if (this.view.type == 'fundraising') events = events.filter((e) => e.fundraising);
      if (this.filters.private === true) events = events.filter((e) => e.visibilityTypeID == 1)
      if (this.filters.private === false) events = events.filter((e) => e.visibilityTypeID > 1)
      if (this.eventActivityName != 'All') events = events.filter((e) => e.eventActivity.name == this.eventActivityName)

      return events;
    },
    distanceOptions: function () {
      let self = this;
      function uniqueBy(a, cond) { return a.filter((e, i) => a.findIndex(e2 => cond(e, e2)) === i); }
      let distances = uniqueBy(this.prefilteredEvents.map(e => {
        let uom = self.getUnitOfMeasure(e.eventActivity.distance.unitOfMeasureID);
        return {
          id: e.eventActivity.distance.id,
          value: e.eventActivity.distance.value,
          unitOfMeasure: uom,
          normalizedValue: e.eventActivity.distance.value * uom.normalizationFactor,
          text: `${e.eventActivity.distance.value} ${uom.abbreviation}`,
        }
      }), (o1, o2) => o1.id == o2.id)
      distances.sort((a, b) => a.normalizedValue > b.normalizedValue)
      return distances
    },
    filteredEvents: function () {
      let events = this.prefilteredEvents;
      if (this.selectedDistances.length) events = events.filter((e) => this.selectedDistances.map(d => d.id).includes(e.eventActivity.distance.id))
      return events;
    },
    chartData: function () {
      return this.filteredEvents
        .filter(e => e.eventResult || e.activity)
        .map(e => ({ ...(e.eventResult ?? e.activity), ...e.placements, ...e.fundraising, year: e.eventActivity.event.year, activityTypeID: e.eventActivity.eventType.activityType.id }))
    },
    private: {
      get() {
        return this.filters.private === true
      },
      set(newVal) {
        this.filters.private = newVal ? true : null
      }
    },
    nonprivate: {
      get() {
        return this.filters.private === false
      },
      set(newVal) {
        this.filters.private = newVal ? false : null
      }
    }
  },
  watch: {
    '$route.name': function () {
      this.init();
    },
    'view.type': function (newValue) {
      this.view.splitYears = newValue == 'registration' && !this.eventGroupMode
    }
  }
};
</script>

<style src="vue-multiselect/dist/vue-multiselect.min.css">
</style>

<style scoped>
.bg-sidebar {
  background-color: #bdbdbd
}

.events-chart-container {
  background-color: rgba(65, 65, 65, 0.05);
  border: 1px solid rgb(200, 200, 200);
  padding: 1rem;
}
</style>
