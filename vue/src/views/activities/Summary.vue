<template>
  <b-container>
    <b-button-group class="mt-3 mb-3">
      <b-button
        v-for="l in orderedLevels"
        :key="l"
        variant="primary"
        :pressed.sync="levels[l]"
        >{{ l | capitalize }}</b-button
      >
    </b-button-group>

    <tree-table
      :columns="tableColumns"
      :table-data="summaryData"
      class="mt-2 mb-3"
    >
      <template #nodeTemplate="nodeProps">
        <TreeNode
          :row-data="nodeProps.rowData"
          :default-order="nodeProps.defaultOrder"
          :depth="nodeProps.depth"
          :on-open="nodeProps.onOpen"
          :on-toggle="nodeProps.onToggle"
          :on-close="nodeProps.onClose"
        />
      </template>
      <template #leafTemplate="leafProps">
        <TreeLeaf
          :row-data="leafProps.rowData"
          :default-order="leafProps.defaultOrder"
          :depth="leafProps.depth"
        />
      </template>
    </tree-table>
  </b-container>
</template>

<script>
import { mapGetters } from "vuex";
const { DateTime } = require("luxon");
import TreeTable from "vue-tree-table-component";
import TreeLeaf from "@/components/activity/summary/SummaryLeaf.vue";
import TreeNode from "@/components/activity/summary/SummaryNode.vue";

export default {
  name: "ActivitySummary",
  components: {
    TreeTable,
    TreeLeaf,
    TreeNode,
  },
  data: function () {
    return {
      selectedActivityTypes: [1, 2, 5],
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
              includeEmpty: true,
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
      this.allSummaries[l][a.id].forEach((d) => {
        let s = this.realignedSummaryData(a, l, d);
        let arr = !this.enabledLevels.indexOf(l)
          ? this.summaries
          : this.findParent(l, d.period).children;
        let i = this.findChildIdx(arr, s.label);
        if (i == null) arr.push(s);
        else this.$set(arr, i, { ...s, ...arr[i] });
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
    labelForPeriod: function (name, period) {
      switch (name) {
        case "all":
          return "All";
        case "year":
          return period.year;
        case "quarter":
          if (this.enabledLevels.includes("year")) return `Q${period.quarter}`;
          else return `${period.year} Q${period.quarter}`;
        case "month":
          let month = DateTime.local()
            .set({ month: period.month })
            .toFormat("MMM");
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
          else return `${period.year} W${period.weekOfYear}`;
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
  },
  computed: {
    ...mapGetters("meta", {
      getActivityTypes: "getActivityTypes",
      isLoaded: "isLoaded",
    }),
    activityTypes: function () {
      let self = this;
      if (!this.isLoaded) return [];
      return this.selectedActivityTypes.map((x) =>
        self.getActivityTypes.find((at) => at.id == x)
      );
    },
    enabledLevels: {
      get: function () {
        return this.orderedLevels.filter((x) => this.levels[x]);
      },
    },
    tableColumns: function () {
      let r = [{ label: "Period", id: "label" }];
      this.activityTypes.forEach((at) => {
        r.push({ label: at.description + "s", id: "count-" + at.id });
        r.push({ label: at.description + " Distance", id: "total-" + at.id });
        r.push({ label: at.description + " Avg", id: "avg-" + at.id });
      });
      return r;
    },
    summaryData: function () {
      return this.summaries;
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
  },
};
</script>

<style>
</style>