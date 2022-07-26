<template>
  <div>
    <b-table :id="tableId" class="rounded-row mt-2" tbody-tr-class="rounded-row" borderless :items="loadData"
      :fields="columns" :per-page.sync="page.length" :current-page.sync="page.current">
      <template #table-busy>
        <div class="text-center">
          <b-spinner variant="secondary" type="grow" />
        </div>
      </template>
      <template #cell(activityTypeID)="data">
        <b-link :to="{ name: 'activity', params: { id: data.item.id } }" class="activityLink">{{ activityName(data.item)
        }}</b-link>
      </template>
      <template #cell(startTime)="data">
        <span v-b-tooltip.hover :title="formatDate(data.value)">
          {{ data.value | luxon }}
        </span>
      </template>
      <template #cell(time)="data">
        {{ data.item.netTime || data.item.duration }}
      </template>
      <template #cell(distance)="data">
        <template v-if="data.value">
          {{ data.value.value | number("0.00") }}
          {{ getUnitOfMeasure(data.value.unitOfMeasureID).abbreviation }}
        </template>
      </template>
      <template #cell(pace)="data">
        <template v-if="data.value">
          {{ data.value.value | trimTime
          }}{{ getUnitOfMeasure(data.value.unitOfMeasureID).abbreviation }}
        </template>
      </template>
      <template #cell(speed)="data">
        <template v-if="data.value">
          {{ data.value.value | number("0.0") }}
          {{ getUnitOfMeasure(data.value.unitOfMeasureID).abbreviation }}
        </template>
      </template>
      <template #cell(reps)="data">
        {{ data.item.repetitions }}
      </template>
    </b-table>
    <b-pagination v-if="page.length" v-model="page.current" :per-page="page.length" :total-rows="total" />
  </div>
</template>

<script>
const { DateTime } = require("luxon");
import { mapGetters } from "vuex";

export default {
  name: "ActivitiesListComponent",
  data: function () {
    return {
      visibleRows: [],
    }
  },
  props: {
    items: {
      type: [Array, String, Function],
      required: true
    },
    page: {
      type: Object,
      default: () => ({ length: 0, current: 1 })
    }
  },
  filters: {
    trimTime: function (t) {
      if (t == null) return t;
      return t.replace(/^[0:]*/, "");
    },
  },
  methods: {
    dayPart: function (d) {
      let dt = DateTime.fromISO(d);
      if (dt.hour > 22 || dt.hour < 5) return "Night";
      else if (dt.hour >= 5 && dt.hour < 12) return "Morning";
      else if (dt.hour >= 12 && dt.hour < 18) return "Afternoon";
      else return "Evening";
    },
    activityName: function (a) {
      let at = this.getActivityType(a.activityTypeID);
      if (at.hasDistance)
        return `${this.dayPart(a.startTime)} ${at.labels.base}`;
      return at.labels.base
    },
    formatDate: function (d) {
      return DateTime.fromISO(d).toLocaleString(DateTime.DATETIME_FULL);
    },
    loadData: function (ctx, callback) {
      let cb = function (items) { this.visibleRows = items; callback(items); };
      if (this.items instanceof Function) {
        this.items(ctx, cb);
      } else if (this.items instanceof Array) {
        this.visibleRows = this.items; callback(this.items)
      }
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
      console.log(types);
      let resultCols = {
        hasDistance: 'distance',
        hasDuration: 'time',
        hasPace: 'pace',
        hasSpeed: 'speed',
        hasRepeats: 'reps'
      };

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
      if (types.length > 1) {
        r.push({
          key: "activityType",
          sortable: true,
          label: "Type",
        });
      }
      for (let k in resultCols) {
        if (types.some(t => t[k] == true)) {
          r.push({
            key: resultCols[k],
            sortable: true
          })
        }
      }
      return r;
    },
  }
}
</script>

<style scoped>
</style>