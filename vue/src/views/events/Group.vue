<template>
  <b-container>
    <b-card v-if="group" no-body class="mt-2">
      <b-card-header>
        <h3>
          <span v-if="group.year">{{ group.year }} </span>{{ group.name }}
        </h3>
      </b-card-header>

      <b-card-body>
        <b-form-radio-group
          buttons
          button-variant="outline-primary"
          class="mb-2"
          :options="view.options"
          v-model="view.type"
        />

        <h4>Events</h4>
        <Grid v-if="group" :events="group.events" :viewType="view.type" />
      </b-card-body>
    </b-card>
  </b-container>
</template>

<script>
import Branding from "@/mixins/Branding.js";
import Events from "@/mixins/events/API.js";
import Grid from "@/components/event/Grid.vue";

export default {
  mixins: [Branding, Events],
  components: { Grid },
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  data: function () {
    return {
      group: null,
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
        return `${this.applicationName} / Event / ${this.group.year || ""} ${
          this.group.name
        }`;
      else return this.applicationName;
    },
  },
};
</script>

<style>
</style>