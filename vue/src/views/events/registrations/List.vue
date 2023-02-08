<template>
  <b-container fluid>
    <b-row>
      <b-col cols="2" class="bg-sidebar">
        <div class="sticky-top">
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
        <b-form-radio-group buttons button-variant="outline-primary" class="float-right" :options="view.options"
          v-model="view.type" size="sm" />
        <h2 class="d-inline-block mr-2">Events </h2><b-spinner v-if="!loaded" variant="info" />

        <div v-if="loaded && view.type != 1">
          <h4>Upcoming</h4>
          <Grid v-if="upcomingEvents.length" :events="upcomingEvents" :viewType="view.type" />
          <label v-else>No upcoming events</label>
          <hr />
        </div>

        <div>
          <h4 v-if="upcomingEvents.length || incompleteEvents.length">Completed</h4>
          <template v-if="viewSplitYears">
            <div v-for="y in eventYears" :key="grid + y" class="iterated-grid">
              <h5>{{ y }}</h5>
              <Grid :events="eventsByYear[y]" :viewType="view.type" />
            </div>
          </template>
          <template v-else>
            <Grid :events="completedEvents" :viewType="view.type" />
          </template>
          <hr v-if="incompleteEvents.length" />
        </div>

        <div v-if="incompleteEvents.length">
          <h4>DNS/DNF</h4>
          <Grid :events="incompleteEvents" :viewType="0" date-format="date_med" />
        </div>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import { DateTime } from "luxon";
import Branding from "@/mixins/Branding.js";
import Events from "@/mixins/events/API.js";

import EventSummary from "@/components/event/Summary.vue";
import Grid from "@/components/event/Grid.vue";

export default {
  components: {
    EventSummary,
    Grid,
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
      filters: {
        activityTypeID: null,
        completed: false,
      },
      view: {
        type: 0,
        splitYears: true,
        options: [
          { text: "Registration", value: 0 },
          { text: "Results", value: 1 },
          { text: "Fundraising", value: 2 },
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
    title: function () {
      return `${this.applicationName} / Events`;
    },
    viewSplitYears: function () {
      return (this.view.type == 0)
    },
    eventYears: function () {
      return Object.keys(this.eventsByYear).sort((a, b) => b - a)
    },
    eventsByYear: function () {
      let years = {};
      this.completedEvents.forEach(e => {
        let y = DateTime.fromISO(e.eventActivity.scheduledStart).year
        if (!years[y]) years[y] = [];
        years[y].push(e);
      })
      return years;
    },
    upcomingEvents: function () {
      return this.filteredEvents.filter(e => DateTime.fromISO(e.eventActivity.scheduledStart) > DateTime.now())
    },
    pastEvents: function () {
      return this.filteredEvents.filter(e => DateTime.fromISO(e.eventActivity.scheduledStart) < DateTime.now())
    },
    completedEvents: function () {
      return this.pastEvents.filter(e => e.activity != null)
    },
    incompleteEvents: function () {
      return this.pastEvents.filter(e => e.activity == null)
    },
    filteredEvents: function () {
      let events = this.events;
      if (this.filters.activityTypeID != null)
        events = events.filter(
          (e) =>
            e.eventActivity.event.eventType.activityTypeID ===
            this.filters.activityTypeID
        );
      if (this.view.type == 1) events = events.filter((e) => e.placements);
      if (this.view.type == 2) events = events.filter((e) => e.fundraising);
      return events;
    },
  },
};
</script>

<style scoped>
.bg-sidebar {
  background-color: #bdbdbd
}

.iterated-grid {
  padding-top: 0.5rem;
}

.iterated-grid:nth-child(odd) {
  background-color: #e4e4e485
}
</style>
