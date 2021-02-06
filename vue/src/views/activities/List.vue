<template>
  <b-container class="mt-2">
    <b-form inline>
      <b-datepicker v-model="internal.range.start" reset-button />
      <b-icon icon="arrow-right" class="mx-2" />
      <b-datepicker v-model="internal.range.end" reset-button />
      <b-button variant="secondary" v-b-modal.filters>Filters</b-button>
    </b-form>
    <b-table
      id="activitiesListTable"
      class="mt-2"
      borderless
      :items="getData"
      :fields="columns"
      :per-page.sync="page.length"
      :current-page.sync="page.current"
    >
      <template #table-busy>
        <div class="text-center">
          <b-spinner variant="secondary" type="grow" />
        </div>
      </template>
      <template #cell(start_time)="data">
        {{ data.value | luxon }}
      </template>
      <template #cell(time)="data">
        {{ data.item.net_time }}
      </template>
      <template #cell(activityType)="data">
        {{ getActivityType(data.item.activityTypeID).description }}
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
        .get("activities", {
          params: {
            ...this.queryParams,
            "order.by": ctx.sortBy || "start_time",
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
  },
  computed: {
    ...mapGetters("meta", {
      getActivityType: "getActivityType",
      getUnitOfMeasure: "getUnitOfMeasure",
      isLoaded: "isLoaded",
    }),
    dateRange: function () {
      return this.internal.range;
    },
    columns: function () {
      let r = [
        {
          key: "start_time",
          sortable: true,
          label: "Start",
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
</style>
