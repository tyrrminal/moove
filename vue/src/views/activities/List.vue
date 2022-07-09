<template>
  <b-container class="mt-2">
    <b-row>
      <b-col cols="3">
        <b-datepicker v-model="internal.range.start" reset-button />
      </b-col>
      <b-col cols="1" class="text-center">
        <b-icon icon="arrow-right" class="mx-2" />
      </b-col>
      <b-col cols="3">
        <b-datepicker v-model="internal.range.end" reset-button />
      </b-col>
      <b-col cols="1" offset="4">
        <b-button variant="secondary" v-b-modal.filters class="float-right"
          >Filters</b-button
        >
      </b-col>
    </b-row>
    <b-table
      id="activitiesListTable"
      class="mt-2"
      borderless
      :items="getData"
      :fields="columns"
      :per-page.sync="page.length"
      :current-page.sync="page.current"
      tbody-tr-class="activityRow"
    >
      <template #table-busy>
        <div class="text-center">
          <b-spinner variant="secondary" type="grow" />
        </div>
      </template>
      <template #cell(activityTypeID)="data"
        ><b-link
          :to="{ name: 'activity', params: { id: data.item.id } }"
          class="activityLink"
          >{{ dayPart(data.item.startTime) }}
          {{ getActivityType(data.value).labels.base }}</b-link
        ></template
      >
      <template #cell(startTime)="data">
        <span v-b-tooltip.hover :title="formatDate(data.value)">
          {{ data.value | luxon }}
        </span>
      </template>
      <template #cell(time)="data">
        {{ data.item.netTime }}
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
    </b-table>
    <b-pagination
      v-model="page.current"
      :per-page="page.length"
      :total-rows="total"
    />

    <b-modal id="filters">
      <b-checkbox v-model="internal.whole"
        >Combine Partial Activities</b-checkbox
      >
    </b-modal>
  </b-container>
</template>

<script>
const { DateTime } = require("luxon");
import { mapGetters } from "vuex";

export default {
  name: "ActivitiesList",
  data() {
    return {
      watchInternal: false,
      activityType: null,
      total: 0,
      page: {
        length: 10,
        current: 1,
      },
      internal: {
        activityTypeID: null,
        range: {
          start: null,
          end: null,
        },
        whole: true,
      },
    };
  },
  props: {
    activityTypeID: {
      type: Number,
    },
    start: {
      type: String,
    },
    end: {
      type: String,
    },
  },
  mounted() {
    this.internal.activityTypeID =
      this.$route.query.activityTypeID || this.activityTypeID;
    this.internal.range.start = this.$route.query.start || this.start;
    this.internal.range.end = this.$route.query.end || this.end;

    if (this.internal.start != null) this.sort["order.dir"] = "asc";
    if (this.internal.end != null) this.sort["order.dir"] = "desc";

    this.$nextTick(function () {
      this.watchInternal = true;
    });
  },
  filters: {
    trimTime: function (t) {
      if (t == null) return t;
      return t.replace(/^[0:]*/, "");
    },
  },
  methods: {
    getData: function (ctx, callback) {
      let self = this;
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
          callback(resp.data.elements);
          self.total = resp.data.pagination.counts.filter;
        });
    },
    dayPart: function (d) {
      let dt = DateTime.fromISO(d);
      if (dt.hour > 22 || dt.hour < 5) return "Night";
      else if (dt.hour >= 5 && dt.hour < 12) return "Morning";
      else if (dt.hour >= 12 && dt.hour < 18) return "Afternoon";
      else return "Evening";
    },
    formatDate: function (d) {
      return DateTime.fromISO(d).toLocaleString(DateTime.DATETIME_FULL);
    },
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
    dateRange: function () {
      return this.internal.range;
    },
    columns: function () {
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
      let a = this.getActivityType(this.internal.activityTypeID);
      if (a == null) {
        r.push({
          key: "activityType",
          sortable: true,
          label: "Type",
        });
      }
      if (a == null || a.hasDistance) {
        r.push({
          key: "distance",
          sortable: true,
        });
      }
      if (a == null || a.hasDuration) {
        r.push({
          key: "time",
          sortable: true,
        });
      }
      if (a == null || a.hasPace) {
        r.push({
          key: "pace",
          sortable: true,
        });
      }
      if (a == null || a.hasSpeed) {
        r.push({
          key: "speed",
          sortable: true,
        });
      }
      return r;
    },
    queryParams: function () {
      let r = {
        ...this.sort,
        combine: this.internal.whole,
        "page.length": 0,
      };
      ["activityTypeID"].forEach((k) => {
        if (this.internal[k] != null) r[k] = this.internal[k];
      });
      ["start", "end"].forEach((k) => {
        if (this.internal.range[k]) r[k] = this.internal.range[k];
      });
      return r;
    },
  },
  watch: {
    internal: {
      deep: true,
      handler: function () {
        if (this.watchInternal)
          if (Object.keys(this.$route.query).length)
            this.$router.push({ query: {} });
        this.$root.$emit("bv::refresh::table", "activitiesListTable");
      },
    },
  },
};
</script>

<style>
table#activitiesListTable {
  border-collapse: separate;
  border-spacing: 0 0.5em;
}
table#activitiesListTable tr.activityRow > td {
  background-color: #f8f9fa;
  border-top: 1px #b2c3cf solid;
  border-bottom: 1px #b2c3cf solid;
  font-weight: 600;
}
table#activitiesListTable tr.activityRow > td:first-child {
  border-left: 1px #b2c3cf solid;
  border-top-left-radius: 8px;
  border-bottom-left-radius: 8px;
}
table#activitiesListTable tr.activityRow > td:last-child {
  border-right: 1px #b2c3cf solid;
  border-top-right-radius: 8px;
  border-bottom-right-radius: 8px;
}
table#activitiesListTable .activityLink {
  color: inherit;
}
table#activitiesListTable .activityRow:hover td {
  background-color: #ececec;
}
table#activitiesListTable .activityRow:hover .activityLink {
  color: inherit;
  text-decoration: underline;
}
</style>
