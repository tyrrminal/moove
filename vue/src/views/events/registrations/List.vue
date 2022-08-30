<template>
  <b-container>
    <h2>Events</h2>
    <b-row>
      <b-col cols="3">
        <b-checkbox v-model="filters.completed" size="small" switch>Hide Incomplete Events</b-checkbox>
      </b-col>
      <b-col offset="6" cols="2">
        <b-form-radio-group buttons button-variant="outline-primary" class="mb-2" :options="view.options"
          v-model="view.type" />
      </b-col>
    </b-row>

    <Grid :events="filteredEvents" :viewType="view.type" />
  </b-container>
</template>

<script>
import Branding from "@/mixins/Branding.js";
import Events from "@/mixins/events/API.js";
import Grid from "@/components/event/Grid.vue";

export default {
  components: {
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
        options: [
          { text: "Performance", value: 0, disabled: false },
          { text: "Results", value: 1, disabled: false },
          { text: "Fundraising", value: 2, disabled: false },
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
        });
    },
  },
  computed: {
    title: function () {
      return `${this.applicationName} / Events`;
    },
    filteredEvents: function () {
      let events = this.events;
      if (this.filters.activityTypeID != null)
        events = events.filter(
          (e) =>
            e.eventActivity.event.eventType.activityTypeID ===
            this.filters.activityTypeID
        );
      if (this.filters.completed) events = events.filter((e) => e.activity);
      if (this.view.type == 1) events = events.filter((e) => e.placements);
      if (this.view.type == 2) events = events.filter((e) => e.fundraising);
      return events;
    },
  },
};
</script>

