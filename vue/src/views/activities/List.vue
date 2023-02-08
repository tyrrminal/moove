<template>
  <b-container class="mt-2">
    <b-row>
      <b-form-group label="From">
        <b-datepicker v-model="internal.start" reset-button />
      </b-form-group>
      <b-form-group label="To" class="ml-3">
        <b-datepicker v-model="internal.end" reset-button />
      </b-form-group>
      <b-col class="text-right">
        <b-button variant="secondary" v-b-modal.filters>Filters</b-button>
      </b-col>
    </b-row>

    <ActivityList tableId="activityListTable" :items="getData" :page.sync="page" :total="total"
      @update:currentPage="updateCurrentPage" @update:perPage="updatePerPage" />

    <b-modal id="filters">
      <b-checkbox v-model="internal.whole">Combine Partial Activities</b-checkbox>
    </b-modal>
  </b-container>
</template>

<script>
import { mapGetters } from "vuex";

import ActivityList from "@/components/activity/List";
import { DateTime } from "luxon";

export default {
  name: "ActivitiesList",
  components: {
    ActivityList
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
        activityTypeID: null,
        start: null,
        end: null,
        whole: true,
        event: null,
      },
    };
  },
  mounted() {
    this.internal.activityTypeID = this.$route.query.activityTypeID;
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
    queryParams: function () {
      let r = {
        ...this.sort,
        combine: this.internal.whole,
        "page.length": 0,
      };
      ["activityTypeID", "start", "end", 'event'].forEach((k) => {
        if (this.internal[k]) r[k] = this.postProcessParam(k);
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
        this.$root.$emit("bv::refresh::table", "activityListTable");
      },
    },
  },
};
</script>

<style>

</style>
