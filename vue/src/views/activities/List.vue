<template>
  <b-container class="mt-2">
    <b-button variant="secondary" v-b-modal.filters class="float-right">Filters</b-button>
    <b-datepicker v-model="internal.start" reset-button class="col-3 mr-2" />
    <b-datepicker v-model="internal.end" reset-button class="col-3" />

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
      },
    };
  },
  props: {
    activityTypeID: {
      type: [String, Number],
    },
    start: {
      type: String,
    },
    end: {
      type: String,
    },
  },
  mounted() {
    this.internal.activityTypeID = this.activityTypeID;
    this.internal.start = this.start;
    this.internal.end = this.end;
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
      ["activityTypeID", "start", "end"].forEach((k) => {
        if (this.internal[k]) r[k] = this.internal[k];
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
