<template>
  <b-container>
    <h2>Events</h2>

    <b-form-checkbox v-model="filters.completed" size="small"
      >Completed</b-form-checkbox
    >
    <b-form-checkbox id="results-filter" v-model="filters.results" size="small"
      >Results</b-form-checkbox
    >

    <b-table
      striped
      small
      hover
      :busy="isLoading"
      :items="displayedEvents"
      :fields="displayedFields"
      :sort-compare="sortCompare"
    >
      <template v-slot:table-busy>
        <div class="text-center text-info my-2">
          <b-spinner class="align-middle"></b-spinner>
          <strong>Loading...</strong>
        </div>
      </template>

      <template v-slot:thead-top="data" v-if="filters.results">
        <b-tr :title="data">
          <b-th colspan="5">
            <span class="sr-only">Default Fields</span>
          </b-th>
          <b-th>
            <span class="sr-only">Speed</span>
          </b-th>
          <b-th colspan="2" class="text-center">Overall</b-th>
          <b-th colspan="2" class="text-center">Gender</b-th>
          <b-th colspan="2" class="text-center">Division</b-th>
        </b-tr>
      </template>

      <template v-slot:cell(index)="data">{{ data.index + 1 }}</template>
      <template v-slot:cell(date)="data">{{
        data.item.eventActivity.scheduledStart | moment("M/D/YY h:mma")
      }}</template>
      <template v-slot:cell(type)="data">{{
        data.item.eventActivity.eventType.description
      }}</template>
      <template v-slot:cell(name)="data">
        <b-link
          :class="eventNameClass(data.item)"
          :to="{
            name: 'event',
            params: { id: data.item.id },
          }"
          >{{ data.item.eventActivity.event.name }}</b-link
        >
      </template>
      <template v-slot:cell(speed)="data"
        ><span v-if="data.item.activity">{{
          fillUnits(eventVelocity(data.item)) | formatDistance
        }}</span></template
      >
      <template v-slot:cell(distance)="data">{{
        fillUnits(
          filters.completed
            ? data.item.activity.distance
            : data.item.eventActivity.distance
        ) | formatDistance
      }}</template>

      <template v-slot:cell(place)="data">{{
        getResultsGroup(data.item.placements, "overall") | extract("place")
      }}</template>
      <template v-slot:cell(pct)="data">{{
        getResultsGroup(data.item.placements, "overall")
          | extract("percentile")
          | invDecimate
          | percent(1)
      }}</template>
      <template v-slot:cell(placeGender)="data">{{
        getResultsGroup(data.item.placements, "gender") | extract("place")
      }}</template>
      <template v-slot:cell(pctGender)="data">{{
        getResultsGroup(data.item.placements, "gender")
          | extract("percentile")
          | invDecimate
          | percent(1)
      }}</template>
      <template v-slot:cell(placeDiv)="data">{{
        getResultsGroup(data.item.placements, "division") | extract("place")
      }}</template>
      <template v-slot:cell(pctDiv)="data">{{
        getResultsGroup(data.item.placements, "division")
          | extract("percentile")
          | invDecimate
          | percent(1)
      }}</template>
    </b-table>
  </b-container>
</template>

<script>
import Branding from "@/mixins/Branding.js";
import UnitConversion from "@/mixins/UnitConversion.js";
import { mapGetters } from "vuex";
import EventFilters from "@/mixins/EventFilters.js";

export default {
  mixins: [Branding, UnitConversion, EventFilters],
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  data: function () {
    return {
      isLoading: true,
      filters: {
        type: null,
        completed: false,
        results: false,
      },
      events: [],
      fields: [
        { key: "index", label: "" },
        { key: "date", sortable: true },
        { key: "name", sortable: true },
        { key: "type", sortable: true },
        { key: "distance", sortable: true },
        { key: "speed", sortable: true },
        { key: "place", sortable: true, label: "Place", results: true },
        { key: "pct", sortable: true, label: "%", results: true },
        { key: "place_gender", sortable: true, label: "Place", results: true },
        { key: "pct_gender", sortable: true, label: "%", results: true },
        { key: "place_div", sortable: true, label: "Place", results: true },
        { key: "pct_div", sortable: true, label: "%", results: true },
      ],
    };
  },
  props: {
    username: {
      type: String,
      required: true,
    },
  },
  methods: {
    init() {
      let self = this;
      self.isLoading = true;
      let qs = {
        username: this.username,
        "order.by": "scheduledStart",
        "order.dir": "desc",
      };

      let loadData = function (pageNumber) {
        self.$http
          .get(["user", "events"].join("/"), {
            params: { ...qs, "page.number": pageNumber },
          })
          .then((response) => {
            self.events.push(...response.data.elements);
            self.isLoading = false;
            if (self.events.length < response.data.pagination.counts.filter)
              self.$nextTick(() => loadData(pageNumber + 1));
          });
      };
      loadData(1);
    },
    sortCompare: function (a, b, key, sortDesc, formatterFn, options, locale) {
      var t = "str";
      if (key == "name") {
        a = a.eventActivity.event.name;
        b = b.eventActivity.event.name;
      }
      if (key == "type") {
        a = a.eventActivity.eventType.description;
        b = b.eventActivity.eventType.description;
      }
      if (key == "date") {
        a = a.eventActivity.scheduledStart;
        b = b.eventActivity.scheduledStart;
      }
      if (key == "distance") {
        t = "num";
        a = this.filters.completed
          ? fillUnits(a.activity.distance).normalizedQuantity.value
          : fillUnits(a.eventActivity.distance).normalizedQuantity.value;
        b = this.filters.completed
          ? fillUnits(b.activity.distance).normalizedQuantity.value
          : fillUnits(b.eventActivity.distance).normalizedQuantity.value;
      }
      if (key == "speed") {
        t = "num";
        a = a.activity ? a.activity.speed.value : 0;
        b = b.activity ? b.activity.speed.value : 0;
      }
      var m;
      if ((m = key.match(/(place|pct)?(Division|Gender)?/))) {
        t = "num";
        let f = m[1] == "pct" ? "percentile" : m[1];
        let g = m[2] === null ? "overall" : m[2];
        a = this.getResultsGroup(a.placements, g)[f] || 0;
        b = this.getResultsGroup(b.placements, g)[f] || 0;
      }
      if (t == "str") return a.localeCompare(b, locale, options);
      return a < b ? -1 : a > b ? 1 : 0;
    },
    eventVelocity: function (e) {
      if (e.hasOwnProperty("activity")) {
        return e.activity.pace || e.activity.speed;
      }
      return "";
    },
    eventNameClass: function (e) {
      if (e.visibilityTypeID == 1) return ["text-danger"];
      return [];
    },
    getResultsGroup: function (results, partitionType) {
      let groups = results;
      if (partitionType == "overall")
        groups = groups.filter((r) => !r.hasOwnProperty("partitionType"));
      else groups = groups.filter((r) => r.partitionType == partitionType);
      let g = groups[0];
      if (g == null) return null;
      g.percentile = (100 * g.place) / g.of;
      return g;
    },
  },
  filters: {
    extract: function (o, f) {
      if (o != null) if (o.hasOwnProperty(f)) return o[f];
      return "";
    },
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
    ...mapGetters("meta", ["getUnitOfMeasure"]),
    title: function () {
      return `${this.applicationName} / Events`;
    },
    displayedFields: function () {
      let fields = this.fields;
      if (this.filters.completed !== true) {
        fields = fields.filter(
          (f) => !f.hasOwnProperty("completed") || f.completed == false
        );
      }
      if (this.filters.results !== true) {
        fields = fields.filter(
          (f) => !f.hasOwnProperty("results") || f.results == false
        );
      }
      return fields;
    },
    displayedEvents: function () {
      let events = this.events;
      if (this.filters.type !== null)
        events = events.filter(
          (e) =>
            e.eventActivity.event.eventType.activityTypeID === this.filters.type
        );
      if (this.filters.completed)
        events = events.filter((e) => e.hasOwnProperty("activity"));
      if (this.filters.results)
        events = events.filter((e) => e.hasOwnProperty("placements"));
      return events;
    },
  },
};
</script>

<style>
</style>