<template>
  <b-container fluid>
    <b-row>
      <b-col offset="2">
        <b-card v-if="group" no-body class="mt-2">
          <b-card-header>
            <h3>
              Event Series: <span v-if="group.year">{{ group.year }} </span>{{ group.name }}
            </h3>
          </b-card-header>

          <b-card-body>
            <div class="float-right"><b-checkbox v-model="distanceType">Show actual distance</b-checkbox></div>
            <b-form-radio-group buttons button-variant="outline-primary" class="mb-2" :options="viewOptions"
              v-model="viewType" />

            <h4>Events</h4>
            <UngroupedList v-if="group" :events="group.events" :loaded="loaded" :gridOptions="gridOptions" />
          </b-card-body>
        </b-card>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import Branding from "@/mixins/Branding.js";
import Events from "@/mixins/events/API.js";
import UngroupedList from "@/components/event/UngroupedList.vue"

export default {
  mixins: [Branding, Events],
  components: { UngroupedList },
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  data: function () {
    return {
      loaded: false,
      group: null,
      viewType: 'registration',
      distanceType: false,
    };
  },
  props: {
    username: {
      type: String,
    },
    id: {
      type: [Number, String],
      required: true,
    },
  },
  mounted: function () {
    this.init();
  },
  methods: {
    init: function () {
      this.$http
        .get(["user", "events", "groups", this.id].join("/"))
        .then((resp) => {
          this.loaded = true;
          this.group = resp.data;
          this.group.events = this.group.events.map((x) =>
            this.processEventPlacements(x)
          );
        });
    },
  },
  computed: {
    title: function () {
      if (this.group)
        return `${this.applicationName} / Event / ${this.group.year || ""} ${this.group.name
          }`;
      else return this.applicationName;
    },
    viewOptions: function () {
      return [
        { text: "Performance", value: 'registration' },
        { text: "Results", value: 'results', disabled: !this.hasAnyResults },
        { text: "Fundraising", value: 'fundraising', disabled: !this.hasAnyFundraising },
      ]
    },
    hasAnyResults: function () {
      return this.group.events.some(e => Object.hasOwn(e, "eventResult"))
    },
    hasAnyFundraising: function () {
      return this.group.events.some(e => Object.hasOwn(e, "fundraising"))
    },
    gridOptions: function () {
      return {
        showFees: this.viewType == 'registration' || this.viewType == 'fundraising',
        showSpeed: this.viewType == 'registration' || this.viewType == 'results',
        showResults: this.viewType == 'results',
        showFundraising: this.viewType == 'fundraising',
        showActivityDistance: this.distanceType,
      }
    },
  },
};
</script>

<style>
</style>
