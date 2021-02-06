<template>
  <b-container>
    <h2 class="mt-3">Activity Summary</h2>
    <b-row class="mt-3 mb-3">
      <b-col cols="3">
        <b-button-group>
          <b-button
            v-for="l in orderedLevels"
            :key="l"
            variant="primary"
            :pressed.sync="levels[l]"
            :disabled="lastLevelLeft(l)"
            >{{ l | capitalize }}</b-button
          >
        </b-button-group>
      </b-col>
      <b-col cols="3">
        <b-input-group class="ml-2">
          <template #prepend>
            <b-button variant="primary" :disabled="true"
              ><b-icon icon="search"></b-icon
            ></b-button>
          </template>
          <b-input
            v-model="search"
            placeholder="Search Period Label..."
          ></b-input>
        </b-input-group>
      </b-col>
      <b-col cols="1" offset="5">
        <b-button v-b-modal.filters>Filters</b-button>
      </b-col>
    </b-row>

    <b-row v-if="unloadedDataElements">
      <b-col cols="12">
        <b-progress
          class="mb-3"
          :animated="true"
          striped
          :max="selectedDataElements"
          :value="selectedDataElements - unloadedDataElements"
        >
        </b-progress>
      </b-col>
    </b-row>

    <TreeTable
      :columns="columns"
      :rows="rows"
      :initialState="(item, depth) => depth < 1"
      class="mb-3"
      table-class="summary"
      head-class="px-2 text-uppercase border-top border-bottom border-secondary"
      striped-rows
      striped-columns
      sortable
    >
      <template #cell(label)="data"
        ><span class="font-weight-bold">{{ data.value }}</span></template
      >
      <template #cell="data">
        <template v-if="data.value == null">-</template>
        <template
          v-else-if="data.column.meta != null && data.column.meta.units != null"
        >
          {{ data.value | number("0,0.0") }} {{ data.column.meta.units }}
        </template>
        <template v-else-if="data.column.key.startsWith('count-')"
          ><b-link
            :to="{
              name: 'activities',
              query: {
                activityTypeID: data.column.meta.activityTypeID,
                start: data.item.period.start,
                end: data.item.period.end,
              },
            }"
            >{{ data.value }}</b-link
          >
        </template>
        <template v-else>{{ data.value }}</template></template
      >
    </TreeTable>

    <b-modal id="filters">
      <b-row>
        <b-col cols="6">
          <b-form-group label="Start">
            <b-datepicker v-model="range.start" />
          </b-form-group>
        </b-col>
        <b-col cols="6">
          <b-form-group label="End">
            <b-datepicker v-model="range.end" />
          </b-form-group>
        </b-col>
      </b-row>
      <hr />
      <b-form-group label="Activity Types (select up to 3)">
        <b-button
          class="mb-2"
          :variant="
            selectedActivityTypes.includes(at.id) ? 'primary' : 'secondary'
          "
          :disabled="
            !selectedActivityTypes.includes(at.id) &&
            selectedActivityTypes.length >= 3
          "
          block
          v-for="at in selectableActivityTypes"
          :key="at.id"
          :pressed="selectedActivityTypes.includes(at.id)"
          @click="toggleActivityType(at.id)"
        >
          {{ at.description }}
        </b-button>
      </b-form-group>
    </b-modal>
  </b-container>
</template>

<script>
import { mapGetters } from "vuex";
const { DateTime } = require("luxon");
import TreeTable from "@/components/tree-table/TreeTable";

export default {
  name: "ActivitySummary",
  components: {
    TreeTable,
  },
  data: function () {
    return {
      selectedActivityTypes: [1, 2],
      range: {
        start: null,
        end: null,
      },
      search: "",
      allSummaries: {},
      summaries: [],
      orderedLevels: ["all", "year", "quarter", "month", "week"],
      levels: {
        all: true,
        year: true,
        quarter: false,
        month: false,
        week: false,
      },
    };
  },
  methods: {
    changeLevelSelection: function (event) {
      this.processAllData();
    },
    lastLevelLeft: function (l) {
      return (
        this.levels[l] && Object.values(this.levels).filter((x) => x).length < 2
      );
    },
    getAllData: function () {
      let self = this;
      this.activityTypes.forEach((a) =>
        this.orderedLevels.forEach((l) => self.getData(l, a))
      );
    },
    processAllData: function () {
      let q = [];
      let self = this;
      self.summaries = [];
      self.activityTypes.forEach((a) =>
        self.enabledLevels.forEach((l) => {
          if (
            self.allSummaries[l] == null ||
            self.allSummaries[l][a.id] == null
          )
            return;
          q.push(function () {
            self.processData(l, a);
          });
        })
      );
      q.forEach((fn) => fn());
    },
    getData: function (l, a, force = false) {
      if (
        this.allSummaries[l] == null ||
        this.allSummaries[l][a.id] == null ||
        force
      ) {
        let self = this;
        this.$http
          .get("activities/summary", {
            params: {
              activityTypeID: a.id,
              period: l,
              ...this.queryParams,
            },
          })
          .then((resp) => {
            if (self.allSummaries[l] == null)
              self.$set(self.allSummaries, l, {});
            self.$set(self.allSummaries[l], a.id, resp.data);
          });
      }
    },
    processData: function (l, a) {
      let self = this;
      this.allSummaries[l][a.id].forEach((d) => {
        let s = self.realignedSummaryData(a, l, d);
        let arr;
        if (self.enabledLevels.indexOf(l)) {
          let p;
          if ((p = self.findParent(l, d.period))) arr = p.children;
          else return;
        } else {
          arr = self.summaries;
        }
        let i = self.findChildIdx(arr, s.label);
        if (i == null) arr.push(s);
        else self.$set(arr, i, { ...s, ...arr[i] });
      });
    },
    findParent: function (level, period) {
      let node;
      let lvlIdx = this.enabledLevels.indexOf(level);
      let list = this.summaries;
      if (this.enabledLevels[0] == this.orderedLevels[0] && lvlIdx == 1)
        return list[0]; // All
      for (let l = 0; l < lvlIdx; l++) {
        for (let i = 0; i < list.length; i++) {
          if (
            this.comparePeriods(this.enabledLevels[l], list[i].period, period)
          ) {
            node = list[i];
            if (node.children == null) node.children = [];
            break;
          }
        }
        list = node.children;
      }
      return node;
    },
    findChildIdx: function (children, label) {
      let idx = null;
      for (let i = 0; i < children.length; i++)
        if (children[i].label == label) idx = i;
      return idx;
    },
    realignedSummaryData: function (activityType, level, data) {
      let o = {};
      if (this.enabledLevels.length > this.enabledLevels.indexOf(level) + 1)
        o["children"] = [];
      o["id"] = this.idForPeriod(level, data.period);
      o["label"] = this.labelForPeriod(level, data.period);
      o.level = level;
      o.period = data.period;
      if (data.count) {
        o["count-" + activityType.id] = data.count;
        o["total-" + activityType.id] = data.distance.sum;
        o["avg-" + activityType.id] = data.distance.sum / data.count;
      }
      return o;
    },
    idForPeriod: function (name, period) {
      switch (name) {
        case "all":
          return "all";
        case "year":
          return `Y${period.year}`;
        case "quarter":
          return `${this.idForPeriod("year", period)}Q${period.quarter}`;
        case "month":
          return (
            `${this.idForPeriod("year", period)}M` +
            period.month.toString().padStart(2, "0")
          );
        case "week":
          return (
            `${this.idForPeriod("year", period)}W` +
            period.weekOfYear.toString().padStart(2, "0")
          );
      }
    },
    labelForPeriod: function (name, period) {
      let month = DateTime.local().set({ month: period.month }).toFormat("MMM");
      switch (name) {
        case "all":
          return "All";
        case "year":
          return period.year;
        case "quarter":
          if (this.enabledLevels.includes("year")) return `Q${period.quarter}`;
          else return `${period.year} Q${period.quarter}`;
        case "month":
          if (
            this.enabledLevels.includes("year") ||
            this.enabledLevels.includes("quarter")
          )
            return `${month}`;
          else return `${period.year} ${month}`;
        case "week":
          if (this.enabledLevels.includes("month"))
            return `W${period.weekOfMonth}`;
          else if (this.enabledLevels.includes("year"))
            return `W${period.weekOfYear}`;
          else return `${period.year} ${month} W${period.weekOfMonth}`;
        default:
          return "-";
      }
    },
    comparePeriods: function (level, p1, p2) {
      let levels = this.orderedLevels;
      for (let i = 1; i <= levels.indexOf(level); i++) {
        let x = levels[i];
        if (p1[x] != p2[x]) return false;
      }
      return true;
    },
    toggleActivityType: function (id) {
      let idx = this.selectedActivityTypes.indexOf(id);
      if (idx >= 0) this.selectedActivityTypes.splice(idx, 1);
      else this.selectedActivityTypes.push(id);
      this.selectedActivityTypes.sort();
    },
  },
  computed: {
    ...mapGetters("meta", {
      getActivityTypes: "getActivityTypes",
      isLoaded: "isLoaded",
    }),
    rows: function () {
      return this.summaries.filter(
        (s) => !this.search || s.label.match(this.search)
      );
    },
    activityTypes: function () {
      let self = this;
      if (!this.isLoaded) return [];
      return this.selectedActivityTypes.map((x) =>
        self.getActivityTypes.find((at) => at.id == x)
      );
    },
    selectableActivityTypes: function () {
      return this.getActivityTypes.filter(
        (at) => at.hasDistance || this.selectedActivityTypes.includes(at.id)
      );
    },
    selectedDataElements: function () {
      return this.enabledLevels.length * this.selectedActivityTypes.length;
    },
    unloadedDataElements: function () {
      let c = 0;
      this.enabledLevels.forEach((l) => {
        if (this.allSummaries[l] == null)
          c += this.selectedActivityTypes.length;
        else
          this.activityTypes.forEach((at) => {
            if (this.allSummaries[l][at.id] == null) c += 1;
          });
      });
      return c;
    },
    enabledLevels: function () {
      return this.orderedLevels.filter((x) => this.levels[x]);
    },
    columns: function () {
      let r = [{ title: "Period", key: "label", "sort-key": "id" }];
      this.activityTypes.forEach((at) => {
        r.push({
          title: at.description + "s",
          key: "count-" + at.id,
          tdClass: "text-center numeric-data",
          meta: {
            activityTypeID: at.id,
          },
        });
        r.push({
          title: at.description + " Distance",
          key: "total-" + at.id,
          tdClass: "text-right numeric-data",
          meta: {
            units: "mi",
            activityTypeID: at.id,
          },
        });
        r.push({
          title: at.description + " Avg",
          key: "avg-" + at.id,
          tdClass: "text-right numeric-data",
          meta: {
            units: "mi",
            activityTypeID: at.id,
          },
        });
      });
      return r;
    },
    summaryData: function () {
      return this.summaries;
    },
    queryParams: function () {
      let p = { includeEmpty: true };
      if (this.range.start) p.start = this.range.start;
      if (this.range.end) p.end = this.range.end;
      return p;
    },
  },
  watch: {
    levels: {
      deep: true,
      handler: function () {
        this.processAllData();
      },
    },
    activityTypes: {
      deep: true,
      immediate: true,
      handler: function () {
        this.getAllData();
        this.processAllData();
      },
    },
    allSummaries: {
      deep: true,
      handler: function () {
        this.processAllData();
      },
    },
    range: {
      deep: true,
      handler: function () {
        this.allSummaries = {};
        this.getAllData();
        this.processAllData();
      },
    },
  },
};
</script>

<style>
td.numeric-data {
  font-family: Monaco, monospace;
  font-size: 10pt;
}

table.summary td {
  border-right: 1px solid silver !important;
}
</style>