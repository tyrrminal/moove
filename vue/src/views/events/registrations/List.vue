<template>
  <b-container fluid>
    <b-row>
      <b-col cols="2" class="bg-sidebar min-vh-100">
        <div class="sticky-top">
          <EventTypeSelector v-model="eventTypes" class="mt-2" />
          <b-skeleton-wrapper :loading="!loaded">
            <EventSummary :events="events" />
            <template #loading>
              <b-list-group class="mt-3 mb-4">
                <b-list-group-item v-for="(s, i) in [[90, 50], [55, 66], [70, 80]]" :key="i">
                  <b-skeleton :width="s[0] + '%'" />
                  <b-skeleton :width="s[1] + '%'" type="input" />
                </b-list-group-item>
              </b-list-group>
            </template>
          </b-skeleton-wrapper>
        </div>
      </b-col>
      <b-col cols="10" class="mt-2">
        <div class="float-right">
          <b-form-radio-group buttons button-variant="outline-primary" :options="view.options" v-model="view.type"
            size="sm" />

        </div>


        <h2 class="d-inline-block mr-2">Events </h2><b-spinner v-if="!loaded" variant="info" />
        <component :is="listView" :events="filteredEvents" :loaded="loaded" :gridOptions="gridOptions" />
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import Branding from "@/mixins/Branding.js";
import Events from "@/mixins/events/API.js";

import EventTypeSelector from "@/components/EventTypeSelector";
import EventSummary from "@/components/event/Summary.vue";
import YearGroupedList from "@/components/event/YearGroupedList.vue";
import UngroupedList from "@/components/event/UngroupedList.vue"

export default {
  name: "EventRegistrationList",
  components: {
    EventTypeSelector,
    EventSummary,
    YearGroupedList,
    UngroupedList
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
      eventTypes: {},
      filters: {
        eventTypeID: null,
        completed: false,
      },
      view: {
        type: 'registration',
        splitYears: true,
        options: [
          { text: "Registration", value: 'registration' },
          { text: "Results", value: 'results' },
          { text: "Fundraising", value: 'fundraising' },
        ],
      },
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
      this.loadEvents();
    },
    loadEvents: function (pageNum = 1) {
      let self = this;
      let params = Object.prototype.hasOwnProperty.call(this, "params")
        ? this.params
        : {};
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
        });
    },
  },
  computed: {
    gridOptions: function () {
      return {
        showFees: this.view.type == 'registration' || this.view.type == 'fundraising',
        showSpeed: this.view.type == 'registration' || this.view.type == 'results',
        showResults: this.view.type == 'results',
        showFundraising: this.view.type == 'fundraising',
      }
    },
    title: function () {
      return `${this.applicationName} / Events`;
    },
    listView: function () {
      return this.view.splitYears && this.view.type == 'registration' ? YearGroupedList : UngroupedList;
    },
    filteredEvents: function () {
      let events = this.events;
      if (Object.keys(this.eventTypes).length) {
        events = events.filter(e => this.eventTypes[e.eventActivity.eventType.id])
      }
      if (this.view.type == 'results') events = events.filter((e) => e.placements);
      if (this.view.type == 'fundraising') events = events.filter((e) => e.fundraising);
      return events;
    },
  },
};
</script>

<style scoped>
.bg-sidebar {
  background-color: #bdbdbd
}
</style>
