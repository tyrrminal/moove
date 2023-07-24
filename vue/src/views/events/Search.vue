<template>
  <b-container fluid>
    <b-row>
      <b-col cols="3" class="min-vh-100 bg-light pt-3">
        <div class="text-center"><strong>Search Events</strong></div>
        <b-form @submit.prevent="doSearch">
          <b-form-row>
            <b-col>
              <b-form-group label="Name">
                <b-input v-model="name" name="event_name" />
              </b-form-group>
            </b-col>
          </b-form-row>
          <b-form-row>
            <b-col>
              <b-form-group label="Start">
                <b-datepicker v-model="start" reset-button />
              </b-form-group>
            </b-col>
          </b-form-row>
          <b-form-row>
            <b-col>
              <b-form-group label="End">
                <b-datepicker v-model="end" reset-button />
              </b-form-group>
            </b-col>
          </b-form-row>
          <b-form-row>
            <b-col>
              <b-button type="submit" block variant="primary">Search</b-button>
            </b-col>
          </b-form-row>
        </b-form>
      </b-col>
      <b-col>
        <template v-if="hasSearched">
          <b-table id="resultsTable" :items="getItems" :fields="fields" :current-page="page.number"
            :per-page="page.length">
            <template #cell(name)="data">
              <b-link :to="{ name: 'event-detail', params: { id: data.item.id } }">{{ data.value }}</b-link>
              <event-activity-name-list :list="data.item.activities" />
            </template>
            <template #cell(address)="data">
              <span v-if="$options.filters.formatAddress(data.value, false)">
                {{ data.value | formatAddress(false) }}
              </span>
              <span v-else class="font-italic">Virtual</span>
            </template>
            <template #cell(edit)="data">
              <b-button v-if="isAdmin" :to="{ name: 'event-edit', params: { id: data.item.id } }" size="sm"
                variant="primary" class="text-uppercase">Edit</b-button>
            </template>
          </b-table>
          <DetailedPagination :currentPage.sync="page.number" :perPage.sync="page.length" :totalRows="counts.filter"
            :totalResults="counts.total" />
        </template>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import Vue from "vue";
import EventFilters from "@/mixins/events/Filters.js"
import { mapGetters } from "vuex";

import DetailedPagination from '@/components/DetailedPagination.vue';
import { DateTime } from "luxon";

Vue.component('event-activity-name-list', {
  props: {
    list: {
      type: Array,
      required: true
    }
  },
  render(createElement) {
    let els = [];
    if (this.list.length > 1 || (this.list.length == 1 && (this.list[0].name || "").trim())) {
      els.push('(')
      this.list.forEach((a, i) => {
        let n = (a.name || "").trim() || `#${i + 1}`;
        els.push(createElement('span', { class: this.$store.getters["meta/getEventType"](a.eventType.id).virtual ? 'font-italic' : '' }, n))
        if (i < this.list.length - 1) els.push(', ')
      })
      els.push(')')
    }
    return createElement('span', { class: 'pl-1' }, els)
  }
});

export default {
  name: "EventSearch",
  components: { DetailedPagination },
  mixins: [EventFilters],
  data: function () {
    return {
      hasSearched: false,
      page: {
        number: 1,
        length: 10,
      },
      counts: {
        filter: 0,
        page: 0,
        total: 0
      },
      name: "",
      start: DateTime.now().toISODate(),
      end: DateTime.now().plus({ years: 1 }).toISODate()
    };
  },
  methods: {
    doSearch: function () {
      this.hasSearched = true;
      this.$root.$emit('bv::refresh::table', 'resultsTable')
    },
    getItems: function (ctx, callback) {
      let q = this.queryParams;
      q["page.length"] = ctx.perPage;
      q["page.number"] = ctx.currentPage;
      q["order.by"] = ctx.sortBy;
      q["order.dir"] = ctx.sortDesc ? 'desc' : 'asc';
      this.$http.get(["events"].join("/"), { params: this.queryParams }).then(resp => {
        callback(resp.data.elements);
        this.counts = resp.data.pagination.counts;
      });
    },
  },
  computed: {
    ...mapGetters('auth', ['isAdmin']),
    fields: function () {
      let f = [
        {
          key: "name",
          sortable: true
        },
        {
          key: "address",
          label: "Location",
          sortable: true
        },
        {
          key: "year",
          sortable: true
        },
      ];
      if (this.isAdmin) f.unshift({
        key: "edit",
        label: "",
        sortable: false
      })
      return f;
    },
    queryParams: function () {
      let p = {};
      if (this.name)
        p.name = this.name;
      if (this.start)
        p.start = this.start;
      if (this.end)
        p.end = this.end;
      return p;
    }
  },
}
</script>

<style scoped></style>
