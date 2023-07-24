<template>
  <b-container fluid>
    <b-row>
      <b-col cols="2" class="pt-2 bg-light min-vh-100">
        <b-form @submit.prevent="reloadTable">
          <b-dropdown text="Filters" class="mb-2" block variant="outline-secondary">
            <b-dropdown-item v-for="f in filterOrder" @click="filterSelection[f].enabled = !filterSelection[f].enabled"
              class="pl-0">
              <b-icon icon="check" v-show="filterSelection[f].enabled" /> {{ filterSelection[f].label }}
            </b-dropdown-item>
          </b-dropdown>
          <hr />
          <ActivityTypeSelector v-if="filterSelection.activityTypeID.enabled" v-model="filter.activityTypeID" block
            class="mb-2" />
          <b-form-group v-if="filterSelection.start.enabled" label="From" label-class="font-weight-bold">
            <b-datepicker v-model="filter.start" reset-button size="sm" />
          </b-form-group>
          <b-form-group v-if="filterSelection.end.enabled" label="To" label-class="font-weight-bold">
            <b-datepicker v-model="filter.end" reset-button size="sm" />
          </b-form-group>
          <b-form-group v-if="filterSelection.distance.enabled" label="Distance" label-class="font-weight-bold">
            <b-input-group>
              <template #prepend><b-select :options="operators" v-model="filter.distance.op" size="sm" /></template>
              <b-input name="filter.distance" v-model="filter.distance.value" number size="sm" class="text-right" />
              <template #append><b-select :options="distance_units" value-field="abbreviation" text-field="abbreviation"
                  v-model="filter.distance.uom_abbr" size="sm" /></template>
            </b-input-group>
          </b-form-group>
          <b-form-group v-if="filterSelection.net_time.enabled" label="Net Time" label-class="font-weight-bold">
            <b-input-group>
              <template #prepend><b-select :options="operators" v-model="filter.net_time.op" size="sm" /></template>
              <b-input name="filter.net_time" v-model="filter.net_time.value" size="sm" class="text-right" />
            </b-input-group>
          </b-form-group>
          <b-form-group v-if="filterSelection.duration.enabled" label="Duration" label-class="font-weight-bold">
            <b-input-group>
              <template #prepend><b-select :options="operators" v-model="filter.duration.op" size="sm" /></template>
              <b-input name="filter.duration" v-model="filter.duration.value" size="sm" class="text-right" />
            </b-input-group>
          </b-form-group>
          <b-form-group v-if="filterSelection.pace.enabled" label="Pace" label-class="font-weight-bold">
            <b-input-group>
              <template #prepend><b-select :options="operators" v-model="filter.pace.op" size="sm" /></template>
              <b-input name="filter.pace" v-model="filter.pace.value" size="sm" class="text-right" />
            </b-input-group>
          </b-form-group>
          <b-form-group v-if="filterSelection.speed.enabled" label="Speed" label-class="font-weight-bold">
            <b-input-group>
              <template #prepend><b-select :options="operators" v-model="filter.speed.op" size="sm" /></template>
              <b-input name="filter.speed" number v-model="filter.speed.value" size="sm" class="text-right" />
              <template #append><b-select :options="rate_units" value-field="abbreviation" text-field="abbreviation"
                  v-model="filter.speed.uom_abbr" size="sm" /></template>
            </b-input-group>
          </b-form-group>
          <b-form-group v-if="filterSelection.event.enabled" label="Events" label-class="font-weight-bold">
            <b-select :options="eventOptions" v-model="filter.event" size="sm" />
          </b-form-group>
          <b-form-group v-if="filterSelection.combine.enabled" label="Partial Activities" label-class="font-weight-bold">
            <b-checkbox v-model="filter.combine">Combine</b-checkbox>
          </b-form-group>
          <b-button variant="primary" class="py-0 mb-2" block @click="reloadTable">Apply</b-button>
          <b-button size="sm" variant="warning" class="py-0 mb-2" block @click="resetFilters">Reset</b-button>
        </b-form>
      </b-col>
      <b-col class="">
        <ActivityList tableId="activityListTable" :items="getData" :page.sync="page" :total="total"
          @update:currentPage="updateCurrentPage" @update:perPage="updatePerPage" />
      </b-col>
    </b-row>

  </b-container>
</template>

<script>
import cloneDeep from 'clone-deep';
import { mapGetters } from "vuex";

import ActivityTypeSelector from "@/components/ActivityTypeSelector";
import ActivityList from "@/components/activity/List";
import { DateTime } from "luxon";

const DEFAULT_FILTER = {
  start: null,
  end: null,
  combine: true,
  event: null,
  activityTypeID: {},
  distance: {
    value: "",
    uom_abbr: "mi",
    op: "="
  },
  speed: {
    value: "",
    uom_abbr: "mph",
    op: "="
  },
  net_time: {
    value: "",
    op: "="
  },
  duration: {
    value: "",
    op: "="
  },
  pace: {
    value: "",
    op: "="
  }
};
const DEFAULT_FILTER_SELECTION = {
  activityTypeID: { label: "Activity Type", enabled: false },
  start: { label: "From", enabled: false },
  end: { label: "To", enabled: false },
  distance: { label: "Distance", enabled: false },
  net_time: { label: "Net Time", enabled: false },
  duration: { label: "Duration", enabled: false },
  pace: { label: "Pace", enabled: false },
  speed: { label: "Speed", enabled: false },
  event: { label: "Events", enabled: false },
  combine: { label: "Partial Activities", enabled: true },
};

export default {
  name: "ActivitiesList",
  components: {
    ActivityList,
    ActivityTypeSelector
  },
  data() {
    return {
      eventOptions: [{ text: 'Show only event activities', value: true }, { text: "Don't show event activities", value: false }],
      operators: ["=", "<", "<=", ">", ">="],
      filterOrder: ["activityTypeID", "start", "end", "distance", "net_time", "duration", "speed", "pace", "event"],
      filterSelection: cloneDeep(DEFAULT_FILTER_SELECTION),
      filter: cloneDeep(DEFAULT_FILTER),

      total: {
        rows: 0,
        results: 0,
      },
      page: {
        length: 10,
        current: 1,
      },
    };
  },
  mounted() {
    if (this.$route.query.activityTypeID) this.$route.query.activityTypeID.split(",").forEach(i => this.$set(this.filter.activityTypeID, Number(i), true))
    this.filter.start = this.$route.query.start;
    this.filter.end = this.$route.query.end;
    this.filter.event = this.$route.query.event;
  },
  methods: {
    resetFilters: function () {
      this.filter = cloneDeep(DEFAULT_FILTER);
      this.filterSelection = cloneDeep(DEFAULT_FILTER_SELECTION);
      this.reloadTable();
    },
    getData: function (ctx, callback) {
      this.$http
        .get(["activities"].join("/"), {
          params: {
            ...this.queryParams,
            "order.by": ctx.sortBy || "startTime",
            "order.dir": ctx.sortDesc ? "desc" : "asc",
            "page.number": ctx.currentPage,
            "page.length": ctx.perPage,
          },
        })
        .then((resp) => {
          this.total.rows = resp.data.pagination.counts.filter;
          this.total.results = resp.data.pagination.counts.total;
          callback(resp.data.elements);
        });
    },
    updatePerPage: function (newValue) {
      this.page.length = newValue
    },
    updateCurrentPage: function (newValue) {
      this.page.current = newValue;
    },
    postProcessParam: function (k) {
      let v = this.filter[k];
      switch (k) {
        case 'activityTypeID':
          let ids = [];
          Object.keys(this.filter.activityTypeID).forEach(k => {
            if (this.filter.activityTypeID[k] === true) ids.push(k);
          })
          v = ids.length == 0 ? null : ids.join(',');
          break;
        case 'end':
          v = DateTime.fromISO(v).plus({ days: 1 }).toISODate(); break;
        case 'distance':
        case 'duration':
        case 'net_time':
        case 'pace':
        case 'speed':
          v = v.value ? JSON.stringify(v) : null;
          break;
      }
      return v;
    },
    reloadTable: function () {
      this.total = { rows: 0, results: 0 }
      this.$root.$emit("bv::refresh::table", "activityListTable");
    }
  },
  computed: {
    ...mapGetters("meta", {
      getActivityType: "getActivityType",
      getUnitOfMeasure: "getUnitOfMeasure",
      isLoaded: "isLoaded",
      getActivityTypeContexts: "getActivityTypeContexts",
      getBaseActivityTypes: "getBaseActivityTypes",
    }),
    ...mapGetters("auth", {
      currentUser: "currentUser",
    }),
    distance_units: function () {
      return this.$store.getters["meta/getUnitsOfMeasure"].filter(uom => uom.type == 'Distance')
    },
    rate_units: function () {
      return this.$store.getters["meta/getUnitsOfMeasure"].filter(uom => uom.type == 'Rate')
    },
    queryParams: function () {
      let r = {};
      Object.keys(this.filterSelection).filter(k => this.filterSelection[k].enabled).forEach(k => {
        r[k] = this.postProcessParam(k)
      })
      return r;
    },
  },
};
</script>

<style></style>
