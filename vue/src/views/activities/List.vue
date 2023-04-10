<template>
  <b-container class="mt-2">
    <b-row>
      <b-form-group label="From">
        <b-datepicker v-model="internal.start" reset-button />
      </b-form-group>
      <b-form-group label="To" class="ml-3">
        <b-datepicker v-model="internal.end" reset-button />
      </b-form-group>
      <b-col class="text-right mt-4">
        <ActivityTypeSelector v-model="activityTypes" />
        <b-dropdown :variant="filterButtonVariant" right>
          <template #button-content><b-icon v-if="isFiltered" icon="circle-fill" :scale="0.5"
              class="mr-1" />Filters</template>
          <b-container>
            <b-button size="sm" variant="warning" class="ml-1 py-0 float-right"
              @click="internal.whole = true; internal.event = null">Reset</b-button>
            <b-form-group label="Partial Activities" label-class="font-weight-bold">
              <b-checkbox v-model="internal.whole">Combine</b-checkbox>
            </b-form-group>
            <b-form-group label="Events" label-class="font-weight-bold">
              <b-radio-group v-model="internal.event" size="sm" stacked>
                <b-radio :value="undefined" class="text-nowrap">Show All Activities</b-radio>
                <b-radio :value="true" class="text-nowrap">Show Only Event Activities</b-radio>
                <b-radio :value="false" class="text-nowrap">Don't Show Event Activities</b-radio>
              </b-radio-group>
            </b-form-group>
          </b-container>
        </b-dropdown>
      </b-col>
    </b-row>

    <ActivityList tableId="activityListTable" :items="getData" :page.sync="page" :total="total"
      @update:currentPage="updateCurrentPage" @update:perPage="updatePerPage" />
  </b-container>
</template>

<script>
import { mapGetters } from "vuex";

import ActivityTypeSelector from "@/components/ActivityTypeSelector";
import ActivityList from "@/components/activity/List";
import { DateTime } from "luxon";

const ACTIVITIES_PER_ROW = 4;

export default {
  name: "ActivitiesList",
  components: {
    ActivityList,
    ActivityTypeSelector
  },
  data() {
    return {
      total: {
        rows: 0,
        results: 0,
      },
      page: {
        length: 10,
        current: 1,
      },
      internal: {
        start: null,
        end: null,
        whole: true,
        event: null,
      },
      activityTypes: {}
    };
  },
  mounted() {
    if (this.$route.query.activityTypeID) this.$route.query.activityTypeID.split(",").forEach(i => this.$set(this.activityTypes, Number(i), true))
    this.internal.start = this.$route.query.start;
    this.internal.end = this.$route.query.end;
    this.internal.event = this.$route.query.event;
  },
  methods: {
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
      let v = this.internal[k];
      if (k == 'end') {
        v = DateTime.fromISO(v).plus({ days: 1 }).toISODate();
      }
      return v;
    },
    getActivityTypesForContext: function (c) {
      return this.$store.getters["meta/getActivityTypesForContext"](c);
    },
    getActivityTypesForBase: function (b) {
      return this.$store.getters["meta/getActivityTypesForBase"](b)
    },
    activityTypesInRow: function (rowNum) {
      let max = this.getBaseActivityTypes.length;
      return this.getBaseActivityTypes.slice(rowNum * ACTIVITIES_PER_ROW, Math.min(rowNum * ACTIVITIES_PER_ROW + ACTIVITIES_PER_ROW, max))
    },
    toggleBaseActivity: function (base) {
      let self = this;
      let state = !this.baseActivityIsEnabled(base);
      this.getActivityTypesForBase(base).forEach(at => self.$set(self.activityTypes, at.id, state))
    },
    baseActivityIsEnabled: function (base) {
      let t = { ...this.activityTypes };
      return this.getActivityTypesForBase(base).reduce((a, v) => a && t[v.id] === true, true);
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
    activityTypeRows: function () {
      return [...Array(Math.ceil(this.getBaseActivityTypes.length / ACTIVITIES_PER_ROW)).keys()]
    },
    isFiltered: function () {
      return this.internal.whole != true || this.internal.event != null
    },
    filterButtonVariant: function () {
      if (this.isFiltered) return 'primary';
      return 'secondary';
    },
    isActivityFiltered: function () {
      return this.activityTypeID != null
    },
    activityButtonVariant: function () {
      return this.isActivityFiltered ? 'primary' : 'secondary'
    },
    queryParams: function () {
      let r = {
        ...this.sort,
        combine: this.internal.whole,
        "page.length": 0,
      };
      ["start", "end", 'event'].forEach((k) => {
        if (this.internal[k] != null) r[k] = this.postProcessParam(k);
      });
      if (this.activityTypeID)
        r.activityTypeID = this.activityTypeID
      return r;
    },
    activityTypeID: function () {
      let ids = [];
      Object.keys(this.activityTypes).forEach(k => {
        if (this.activityTypes[k] === true) ids.push(k);
      })
      return ids.length == 0 ? null : ids.join(',')
    }
  },
  watch: {
    activityTypeID: function () {
      this.$root.$emit("bv::refresh::table", "activityListTable");
    },
    internal: {
      deep: true,
      handler: function () {
        this.$root.$emit("bv::refresh::table", "activityListTable");
      },
    },
  },
};
</script>

<style></style>
