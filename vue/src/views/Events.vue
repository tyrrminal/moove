<template>
  <b-container>
    <vue-headful title="Moo've / Events" />

    <h2>Events</h2>

    <b-form-checkbox id="completed-filter" v-model="filters.completed" size="small">Completed</b-form-checkbox>
    <b-form-checkbox id="results-filter" v-model="filters.results" size="small">Results</b-form-checkbox>

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
      <template
        v-slot:cell(date)="data"
      >{{ data.item.event.scheduled_start | moment("M/D/YY h:mma") }}</template>
      <template v-slot:cell(type)="data">{{ data.item.event.event_type.description }}</template>
      <template v-slot:cell(name)="data">
        <router-link
          v-bind:class="eventNameClass(data.item)"
          :to="{ name: 'event', params: { id: data.item.event.id, user: effectiveUser }}"
        >{{ data.item.event.name }}</router-link>
      </template>
      <template v-slot:cell(speed)="data">{{ eventVelocity(data.item) }}</template>
      <template
        v-slot:cell(distance)="data"
      >{{ filters.completed ? data.item.activity.distance : data.item.event.distance | format_distance }}</template>

      <template
        v-slot:cell(place)="data"
      >{{ getResultsGroup(data.item.results, 'overall') | extract('place') }}</template>
      <template
        v-slot:cell(pct)="data"
      >{{ getResultsGroup(data.item.results, 'overall') | extract('percentile') | format_pct }}</template>
      <template
        v-slot:cell(place_gender)="data"
      >{{ getResultsGroup(data.item.results, 'gender') | extract('place') }}</template>
      <template
        v-slot:cell(pct_gender)="data"
      >{{ getResultsGroup(data.item.results, 'gender') | extract('percentile') | format_pct }}</template>
      <template
        v-slot:cell(place_div)="data"
      >{{ getResultsGroup(data.item.results, 'division') | extract('place') }}</template>
      <template
        v-slot:cell(pct_div)="data"
      >{{ getResultsGroup(data.item.results, 'division') | extract('percentile') | format_pct }}</template>
    </b-table>
  </b-container>
</template>

<script>
import "@/filters/event_filters.js";

export default {
  data() {
    return {
      isLoading: true,
      sequence_id: null,
      filters: {
        type: null,
        completed: null,
        results: null,
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
  methods: {
    init() {
      let self = this;
      self.isLoading = true;
      let qs = {};
      this.sequence_id = this.$route.params.sequence_id;

      if (this.sequence_id) {
        qs["sequence_id"] = this.sequence_id;
      }

      this.$http
        .get("events/" + this.effectiveUser, { params: qs })
        .then((response) => {
          self.events = response.data;
          self.events.forEach(function (item, index) {
            item.year = self.$options.filters.event_year(item.event);
          });
          self.isLoading = false;
        });
    },
    sortCompare: function (a, b, key, sortDesc, formatterFn, options, locale) {
      var t = "str";
      if (key == "name") {
        a = a.event.name;
        b = b.event.name;
      }
      if (key == "type") {
        a = a.event.event_type.description;
        b = b.event.event_type.description;
      }
      if (key == "date") {
        a = a.event.scheduled_start;
        b = b.event.scheduled_start;
      }
      if (key == "distance") {
        t = "num";
        a = this.filters.completed
          ? a.activity.distance.normalized_quantity.value
          : a.event.distance.normalized_quantity.value;
        b = this.filters.completed
          ? b.activity.distance.normalized_quantity.value
          : b.event.distance.normalized_quantity.value;
      }
      if (key == "speed") {
        t = "num";
        a = a.activity ? a.activity.result.speed.quantity.value : 0;
        b = b.activity ? b.activity.result.speed.quantity.value : 0;
      }
      var m;
      if ((m = key.match(/(place|pct)_?(division|gender)?/))) {
        t = "num";
        let f = m[1] == "pct" ? "percentile" : m[1];
        let g = m[2] === null ? "overall" : m[2];
        a = this.getResultsGroup(a.results, g)[f] || 0;
        b = this.getResultsGroup(b.results, g)[f] || 0;
      }
      if (t == "str") return a.localeCompare(b, locale, options);
      return a < b ? -1 : a > b ? 1 : 0;
    },
    eventVelocity: function (e) {
      if (e.hasOwnProperty("activity")) {
        if (e.activity.activity_type.id == 1) {
          return e.activity.result.pace;
        } else {
          return this.$options.filters.format_distance(e.activity.result.speed);
        }
      }
      return "";
    },
    eventNameClass: function (e) {
      if (!e.registration.is_public) return ["text-danger"];
      return [];
    },
    getResultsGroup: function (results, g) {
      let groups = results.groups;
      if (g == "overall")
        groups = groups.filter(
          (r) => !r.hasOwnProperty("division") && !r.hasOwnProperty("gender")
        );
      if (g == "gender")
        groups = groups.filter(
          (r) => !r.hasOwnProperty("division") && r.hasOwnProperty("gender")
        );
      if (g == "division")
        groups = groups.filter(
          (r) => r.hasOwnProperty("division") && !r.hasOwnProperty("gender")
        );
      return groups[0];
    },
  },
  mounted() {
    this.init();
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
    effectiveUser: function () {
      if (this.$route.params.user) return this.$route.params.user;
      return this.$store.getters["auth/currentUser"].username;
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
          (e) => e.event.event_type.activity_type.id === this.filters.type
        );
      if (this.filters.completed !== null)
        events = events.filter(
          (e) =>
            (e.hasOwnProperty("activity") &&
              e.activity.hasOwnProperty("result")) == this.filters.completed
        );
      if (this.filters.results !== null)
        events = events.filter(
          (e) => e.hasOwnProperty("results") == this.filters.results
        );
      return events;
    },
  },
};
</script>

<style>
</style>