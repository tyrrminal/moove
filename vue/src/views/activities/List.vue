<template>
  <b-container fluid>
    <b-row>
      <b-col cols="2" class="pt-2 bg-light min-vh-100">
        <b-form @submit.prevent="reloadTable">
          <b-dropdown block variant="secondary" :disabled="addableFilters.length < 1">
            <template #button-content>
              <b-icon icon="plus-circle" class="mr-2" />Add Filter
            </template>
            <b-dropdown-item v-for="f in addableFilters" @click="addFilter(f)" class="pl-0">
              {{ filterTypes[f].label }}
            </b-dropdown-item>
          </b-dropdown>
          <hr />
          <template v-for="(f, i) in filters">
            <b-row>
              <b-col cols="10">
                <ActivityTypeSelector v-if="f.key == 'activityTypeID'" class="mb-2" v-model="f.value" block />

                <b-form-group v-else-if="f.key == 'start' || f.key == 'end' || f.key == 'on'"
                  :label="filterTypes[f.key].label" label-class="font-weight-bold">
                  <b-datepicker v-model="f.value" reset-button size="sm" />
                </b-form-group>

                <b-form-group v-else-if="f.key == 'combine'" :label="filterTypes[f.key].label"
                  label-class="font-weight-bold">
                  <b-checkbox v-model="f.value">Combine</b-checkbox>
                </b-form-group>

                <b-form-group v-else-if="f.key == 'event'" :label="filterTypes[f.key].label"
                  label-class="font-weight-bold">
                  <b-select :options="eventOptions" v-model="f.value" size="sm" />
                </b-form-group>

                <b-form-group v-else-if="f.key == 'distance'" :label="filterTypes[f.key].label"
                  label-class="font-weight-bold">
                  <b-input-group>
                    <template #prepend><b-select :options="operators" v-model="f.value.op" size="sm" /></template>
                    <b-input name="filter.distance" v-model="f.value.value" number size="sm" class="text-right" />
                    <template #append><b-select :options="distance_units" value-field="abbreviation"
                        text-field="abbreviation" v-model="f.value.uom_abbr" size="sm" /></template>
                  </b-input-group>
                </b-form-group>

                <b-form-group v-else-if="f.key == 'net_time'" :label="filterTypes[f.key].label"
                  label-class="font-weight-bold">
                  <b-input-group>
                    <template #prepend><b-select :options="operators" v-model="f.value.op" size="sm" /></template>
                    <b-input name="filter.net_time" v-model="f.value.value" size="sm" class="text-right" />
                  </b-input-group>
                </b-form-group>

                <b-form-group v-else-if="f.key == 'duration'" :label="filterTypes[f.key].label"
                  label-class="font-weight-bold">
                  <b-input-group>
                    <template #prepend><b-select :options="operators" v-model="f.value.op" size="sm" /></template>
                    <b-input name="filter.duration" v-model="f.value.value" size="sm" class="text-right" />
                  </b-input-group>
                </b-form-group>

                <b-form-group v-else-if="f.key == 'pace'" :label="filterTypes[f.key].label"
                  label-class="font-weight-bold">
                  <b-input-group>
                    <template #prepend><b-select :options="operators" v-model="f.value.op" size="sm" /></template>
                    <b-input name="filter.pace" v-model="f.value.value" size="sm" class="text-right" />
                  </b-input-group>
                </b-form-group>

                <b-form-group v-else-if="f.key == 'speed'" :label="filterTypes[f.key].label"
                  label-class="font-weight-bold">
                  <b-input-group>
                    <template #prepend><b-select :options="operators" v-model="f.value.op" size="sm" /></template>
                    <b-input name="filter.speed" number v-model="f.value.value" size="sm" class="text-right" />
                    <template #append><b-select :options="rate_units" value-field="abbreviation" text-field="abbreviation"
                        v-model="f.value.uom_abbr" size="sm" /></template>
                  </b-input-group>
                </b-form-group>
              </b-col>

              <b-col cols="1">
                <b-button v-if="f.key != 'combine'" variant="none" class="p-0" @click="filters.splice(i, 1)"><b-icon
                    icon="x-square" variant="danger" /></b-button>
              </b-col>
            </b-row>
          </template>

          <b-button variant="primary" class="py-0 my-2" block @click="reloadTable">Apply</b-button>
          <b-button size="sm" variant="secondary" class="py-0 mb-2" block @click="resetFilters">Reset</b-button>
        </b-form>
      </b-col>
      <b-col>
        <ActivityListSummary :data="summary" v-if="summary?.counts.total > 0" bgColor="rgba(214, 147, 255, 0.41)" />
        <ActivityListSummary :data="eventSummary" v-if="eventSummary?.counts.total > 0" title="Events"
          bgColor="rgba(142, 134, 255, 0.2)" />
        <ActivityList tableId="activityListTable" :items="getData" :page.sync="page" :total="total"
          @update:currentPage="updateCurrentPage" @update:perPage="updatePerPage" @filterDate="setDateFilter" />
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import cloneDeep from 'clone-deep';

import ActivityTypeSelector from "@/components/ActivityTypeSelector";
import ActivityList from "@/components/activity/List";
import ActivityListSummary from "@/components/activity/Summary.vue";
import { DateTime } from "luxon";

const OPERATORS = ["=", "<", "<=", ">", ">="];

export default {
  name: 'ActivitiesList',
  components: {
    ActivityList,
    ActivityListSummary,
    ActivityTypeSelector
  },
  data: function () {
    return {
      eventOptions: [{ text: 'Show only event activities', value: true }, { text: "Don't show event activities", value: false }],

      filterTypes: {
        activityTypeID: { label: "Activity Type", multiplicity: 1, default: {} },
        start: { label: "Date: From", multiplicity: 1, default: null },
        end: { label: "Date: To", multiplicity: 1, default: null },
        on: { label: "Date: On", multiplicity: 1, default: null },
        distance: { label: "Distance", multiplicity: 2, default: { value: "", uom_abbr: "mi", op: "=" } },
        net_time: { label: "Net Time", multiplicity: 2, default: { value: "0:00:00", op: "=" } },
        duration: { label: "Duration", multiplicity: 2, default: { value: "0:00:00", op: "=" } },
        pace: { label: "Pace", multiplicity: 2, default: { value: "0:00:00", op: "=" } },
        speed: { label: "Speed", multiplicity: 2, default: { value: "0", uom_abbr: "mph", op: "=" } },
        event: { label: "Events", multiplicity: 1, default: null },
        combine: { label: "Partial Activities", multiplicity: 1, default: true }
      },
      filters: [],

      summary: null,
      eventSummary: null,
      total: {
        rows: 0,
        results: 0,
      },
      page: {
        length: 10,
        current: 1
      }
    }
  },
  mounted: function () {
    this.resetFilters();
    let dirty = false;
    Object.keys(this.filterTypes).forEach(k => {
      let v = this.$route.query[k]
      if (v != null) {
        if (k == 'activityTypeID') {
          let t = v;
          v = {}
          v[t] = true
        }
        this.addFilter(k, v)
        dirty = true
      }
    });
    if (dirty) this.loadSummary();
  },
  computed: {
    operators: function () {
      return OPERATORS
    },
    addableFilters: function () {
      return Object.keys(this.filterTypes).filter(x => this.canAddFilter(x)).sort((a, b) => this.filterTypes[a].label.localeCompare(this.filterTypes[b].label))
    },
    distance_units: function () {
      return this.$store.getters["meta/getUnitsOfMeasure"].filter(uom => uom.type == 'Distance')
    },
    rate_units: function () {
      return this.$store.getters["meta/getUnitsOfMeasure"].filter(uom => uom.type == 'Rate')
    },
  },
  methods: {
    searchParams: function () {
      let params = new URLSearchParams();
      this.filters.forEach(f => params.append(f.key, this.paramValue(f)))
      return params;
    },
    getData: function (ctx, callback) {
      let params = this.searchParams();
      params.append("order.by", ctx.sortBy || "startTime")
      params.append("order.dir", ctx.sortDesc ? "desc" : "asc")
      params.append("page.number", ctx.currentPage);
      params.append("page.length", ctx.perPage)
      this.$http.get("activities", { params: params })
        .then((resp) => {
          this.total.rows = resp.data.pagination.counts.filter;
          this.total.results = resp.data.pagination.counts.total;
          callback(resp.data.elements)
        })
    },
    loadSummary: function () {
      let eventFilter = this.filters.find(f => f.key == 'event');
      let p = this.searchParams();
      this.summary = null;
      this.eventSummary = null;
      if (eventFilter == null || eventFilter.value == false)
        this.$http.get("activities/summary", { params: p })
          .then(resp => this.summary = resp.data[0])
      if (eventFilter == null || eventFilter.value == true) {
        p.set('combine', false)
        p.set('event', true);
        this.$http.get("activities/summary", { params: p })
          .then(resp => this.eventSummary = resp.data[0])
      }
    },
    reloadTable: function () {
      this.total = { rows: 0, results: 0 }
      this.$root.$emit("bv::refresh::table", "activityListTable");
      this.loadSummary();
    },
    resetFilters: function () {
      this.filters = [];
      this.addFilter('combine');
      this.reloadTable();
    },
    canAddFilter: function (k) {
      let t = this.filterTypes[k];
      if ((k == 'start' || k == 'end') && this.filters.find(x => x.key == 'on')) return false;
      if (k == 'on' && this.filters.find(x => x.key == 'start' || x.key == 'end')) return false;
      return this.filters.filter(x => x.key == k).length < t.multiplicity
    },
    addFilter: function (k, v = null) {
      if (this.canAddFilter(k)) {
        this.filters.push({ key: k, value: v || cloneDeep(this.filterTypes[k].default) })
      }
    },
    removeAllFilters: function (k) {
      let idx;
      do {
        idx = this.filters.findIndex(x => x.key == k);
        if (idx >= 0) this.filters.splice(idx, 1);
      } while (idx != -1);
    },
    setDateFilter: function (d) {
      let dts = DateTime.fromISO(d);

      this.removeAllFilters('start');
      this.removeAllFilters('end');
      this.addFilter('on')
      this.filters.find(x => x.key == 'on').value = dts.toISODate();

      this.reloadTable();
    },
    updateCurrentPage: function (newValue) {
      this.page.current = newValue
    },
    updatePerPage: function (newValue) {
      this.page.length = newValue
    },
    paramValue: function (f) {
      let k = f.key;
      let v = f.value;
      switch (k) {
        case 'activityTypeID':
          let ids = [];
          Object.keys(v).forEach(k => {
            if (v[k] === true) ids.push(k);
          })
          v = ids.length == 0 ? null : ids.join(',');
          break;
        case 'distance':
        case 'duration':
        case 'net_time':
        case 'pace':
        case 'speed':
          v = v.value ? JSON.stringify(v) : null;
          break;
      }
      return v;
    }
  }
}
</script>

<style></style>
