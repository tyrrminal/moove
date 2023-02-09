<template>
  <b-container>
    <b-table tbody-tr-class="rounded-row" class="rounded-row mt-2" borderless :items="getData" :fields="columns"
      :per-page.sync="page.length" :current-page.sync="page.current" :sort-by.sync="sort.by"
      :sort-desc.sync="sort.desc">
      <template #cell(name)="data">
        <b-link :to="{ name: 'workout', params: { id: data.item.id } }">{{ data.value }}</b-link>
      </template>
      <template #cell(activities)="data">
        <b-link v-for="a in data.value" :key="a.id" :to="{ name: 'activity', params: { id: a.id } }">{{
          getActivityType(a.activityTypeID).description
        }}</b-link>
      </template>

    </b-table>
    <b-pagination v-model="page.current" :per-page="page.length" :total-rows="total" />
  </b-container>
</template>

<script>
import { DateTime } from "luxon";

export default {
  data: function () {
    return {
      total: 0,
      page: {
        length: 10,
        current: 1,
      },
      sort: {
        by: "date",
        desc: true
      }
    }
  },
  computed: {
    columns: function () {
      return [{
        key: 'date',
        sortable: true,
        formatter: (value) => DateTime.fromISO(value).toLocaleString()
      },
      { key: 'name', sortable: true },
      {
        key: 'activities',
        formatter: "activityListFormatter",
        sortByFormatted: true,
        filterByFormatted: true
      }
      ]
    }
  },
  methods: {
    getData: function (ctx, callback) {
      this.$http
        .get(["workouts"].join("/"), {
          params: {
            // ...this.queryParams,
            "order.by": ctx.sortBy,
            "order.dir": (ctx.sortDesc ? 'desc' : 'asc'),
            "page.number": ctx.currentPage,
            "page.length": ctx.perPage,
          },
        })
        .then((resp) => {
          callback(resp.data.elements);
          this.total = resp.data.pagination.counts.filter;
        });
    },
    getActivityType: function (id) {
      return this.$store.getters["meta/getActivityType"](id);
    },
  }
};
</script>

<style scoped>

</style>