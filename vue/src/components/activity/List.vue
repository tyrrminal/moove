<template>
  <div>
    <b-table v-if="isLoaded" :id="tableId" class="rounded-row mt-2" tbody-tr-class="rounded-row" borderless
      :items="loadData" :fields="columns" :per-page.sync="page.length" :current-page.sync="page.current"
      :sort-by="sort.by" :sort-desc="sort.desc" show-empty>
      <template #empty>
        <div class="text-center">
          <h4>No Activities Found</h4>
        </div>
      </template>
      <template #table-busy>
        <div class="text-center">
          <b-spinner variant="secondary" type="grow" />
        </div>
      </template>
      <template #cell(activityTypeID)="data">
        <b-icon v-if="activityHasMap(data.item)" icon="pin-map" class="mr-2" />
        <b-link :to="{ name: 'activity', params: { id: data.item.id } }" class="activityLink">{{
          activityName(data.item)
        }}</b-link>
      </template>
      <template #cell(startTime)="data">
        <span v-b-tooltip.hover :title="formatDate(data.item.sets[0].startTime)">
          <b-link class="link-black" @click="$emit('filterDate', data.item.sets[0].startTime)">{{
            data.item.sets[0].startTime | luxon({ output: { format: "date_med" } })
          }}</b-link>,
          {{ data.item.sets[0].startTime | luxon({ output: { format: "time" } }) }}
        </span>
      </template>
      <template #cell(time)="data">
        <div v-for="(s, i) in data.item.sets" :key="i">
          {{ (s.netTime == '00:00:00' ? null : s.netTime) || s.duration }}<br />
        </div>
      </template>
      <template #cell(distance)="data">
        <template v-if="data.value">
          {{ data.value.value | number("0.00") }}
          {{ getUnitOfMeasure(data.value.unitOfMeasureID).abbreviation }}
        </template>
      </template>
      <template #cell(speed)="data">
        <template v-if="getActivityType(data.item.activityTypeID).hasPace">
          <span :title="describeSpeed(data.item.speed)">{{ describePace(data.item.pace) }}</span>
        </template>
        <template v-if="getActivityType(data.item.activityTypeID).hasSpeed">
          <span :title="describePace(data.item.pace)">{{ describeSpeed(data.item.speed) }}</span>
        </template>
      </template>
      <template #cell(reps)="data">
        <div v-for="(s, i) in data.item.sets" :key="i">
          {{ s.repetitions }}<br />
        </div>
      </template>
      <template #cell(weight)="data">
        <div v-for="(s, i) in data.item.sets" :key="i">
          {{ s.weight }}{{ s.weight == null ? '' : ' lbs' }}<br />
        </div>
      </template>
      <template #cell(addSet)="data">
        <b-link
          :to="{ name: 'create-activity', params: { workoutID: data.item.workoutID, activityTypeID: data.item.activityTypeID, group: data.item.group } }">
          <b-icon icon="plus" />Set
        </b-link>
      </template>
    </b-table>
    <DPagination v-if="page.length && total.results > 0" :per-page="page.length" :current-page="page.current"
      @update:currentPage="updateCurrentPage" @update:perPage="updatePerPage" :total-rows="total.rows"
      :total-results="total.results" />
  </div>
</template>

<script>
import { DateTime } from 'luxon';
import { mapGetters } from "vuex";

import DPagination from "@/components/DetailedPagination";

export default {
  name: "ActivitiesListComponent",
  components: {
    DPagination
  },
  data: function () {
    return {
      visibleRows: [],
      sort: {
        desc: true,
        by: 'startTime'
      }
    }
  },
  props: {
    tableId: {
      type: String,
      default: null
    },
    items: {
      type: [Array, String, Function],
      required: true
    },
    page: {
      type: Object,
      default: () => ({ length: 0, current: 1 })
    },
    total: {
      type: Object,
      default: () => ({ rows: 0, results: 0 })
    },
    editor: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    describeSpeed: function (s) {
      return `${this.$options.filters.number(s.value, "0.0")} ${this.getUnitOfMeasure(s.unitOfMeasureID).abbreviation}`
    },
    describePace: function (p) {
      if (p.value == null) return "";
      return `${p.value.replace(/^[0:]*/, "")}${this.getUnitOfMeasure(p.unitOfMeasureID).abbreviation}`
    },
    dayPart: function (d) {
      let dt = DateTime.fromISO(d);
      if (dt.hour >= 5 && dt.hour < 10) return "Morning";
      else if (dt.hour >= 10 && dt.hour < 14) return 'Midday';
      else if (dt.hour >= 14 && dt.hour < 18) return "Afternoon";
      else if (dt.hour >= 18 && dt.hour < 22) return 'Evening';
      else return "Night";
    },
    activityName: function (a) {
      if (a.userEventActivity != null)
        return a.userEventActivity.name;
      let at = this.getActivityType(a.activityTypeID);
      if (at.hasDistance)
        return `${this.dayPart(a.startTime)} ${at.labels.base}`;
      return at.labels.base
    },
    activityHasMap: function (a) {
      let at = this.getActivityType(a.activityTypeID);
      return at.hasMap;
    },
    formatDate: function (d) {
      return DateTime.fromISO(d).toLocaleString(DateTime.DATETIME_FULL);
    },
    loadData: function (ctx, callback) {
      let self = this;
      let cb = function (items) {
        self.visibleRows = items.map(r => {
          return { ...r, ...r.sets[0] }
        });
        callback(self.visibleRows);
      };
      if (this.items instanceof Function) {
        this.items(ctx, cb);
      } else if (this.items instanceof Array) {
        cb(this.items);
      }
    },
    updatePerPage: function (newValue) {
      this.$emit("update:perPage", newValue);
    },
    updateCurrentPage: function (newValue) {
      this.$emit("update:currentPage", newValue);
    }
  },
  computed: {
    ...mapGetters("meta", {
      getActivityType: "getActivityType",
      getUnitOfMeasure: "getUnitOfMeasure",
      isLoaded: "isLoaded",
    }),
    ...mapGetters("auth", {
      currentUser: "currentUser",
    }),
    columns: function () {
      let types = [...new Set(this.visibleRows.map(r => r.activityTypeID))].map(t => this.getActivityType(t));
      let resultCols = new Map();
      resultCols.set('hasRepeats', 'reps');
      resultCols.set('hasDistance', 'distance');
      resultCols.set('hasDuration', 'time');

      let r = [
        {
          key: "startTime",
          sortable: true,
          label: "Date",
        },
        {
          key: "activityTypeID",
          sortable: true,
          label: "Activity",
        },
      ];
      // if (types.length > 1) {
      if (false) {
        r.push({
          key: "activityType",
          sortable: true,
          label: "Type",
        });
      }
      for (var [k, v] of resultCols) {
        if (types.some(t => t[k] == true)) {
          r.push({
            key: v,
            sortable: true
          })
        }
      }
      if (types.some(t => t.hasSpeed || t.hasPace)) {
        r.push({
          key: 'speed',
          label: this.visibleRows.map(r => this.getActivityType(r.activityTypeID)).some(t => t.hasSpeed) ? 'Speed' : 'Pace',
          sortable: true
        })
      }
      ["weight"].forEach(k => {
        if (this.visibleRows.some(row => row.sets.some(s => s[k] != null))) {
          r.push({
            key: k,
            sortable: true
          })
        }
      })
      if (this.editor) {
        r.push({
          label: '',
          key: 'addSet',
          sortable: false
        })
      }
      return r;
    },
  }
}
</script>

<style scoped>
a.link-black:link {
  color: black !important
}
</style>