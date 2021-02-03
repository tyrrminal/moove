<template>
  <b-container class="mt-2">
    <b-row>
      <b-col>
        <b-datepicker v-model="internal.start" /> -
        <b-datepicker v-model="internal.end" />
      </b-col>
    </b-row>
    <b-table :items="activities" :fields="columns" borderless>
      <template #cell(start_time)="data">
        {{ data.value | luxon }}
      </template>
      <template #cell(distance)="data">
        {{ data.item.distance.value }}
        {{ getUnitOfMeasure(data.item.distance.unitOfMeasureID).abbreviation }}
      </template>
      <template #cell(time)="data">
        {{ data.item.net_time }}
      </template>
    </b-table>
  </b-container>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  name: "ActivitiesList",
  data() {
    return {
      activities: [],
      sort: {
        "order.by": "start_time",
        "order.dir": "asc",
      },
      internal: {
        activityTypeID: null,
        start: null,
        end: null,
      },
      columns: [
        {
          key: "start_time",
        },
        {
          key: "distance",
        },
        {
          key: "time",
        },
        {
          key: "pace",
        },
      ],
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
    this.internal.start = this.$route.query.start || this.start;
    this.internal.end = this.$route.query.end || this.end;

    if (this.internal.start != null) this.sort["order.dir"] = "asc";
    if (this.internal.end != null) this.sort["order.dir"] = "desc";

    this.getData();
  },
  methods: {
    getData: function () {
      let self = this;
      this.$http
        .get("activities", { params: this.queryParams })
        .then((resp) => {
          self.activities = resp.data.elements;
        });
    },
  },
  computed: {
    ...mapGetters("meta", {
      getActivityType: "getActivityType",
      getUnitOfMeasure: "getUnitOfMeasure",
      isLoaded: "isLoaded",
    }),
    queryParams: function () {
      let r = {
        ...this.sort,
      };
      ["activityTypeID", "start", "end"].forEach((k) => {
        if (this.internal[k] != null) r[k] = this.internal[k];
      });
      return r;
    },
  },
};
</script>

<style>
</style>