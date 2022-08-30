<template>
  <b-container class="mt-3">
    <h3>Search for Events</h3>

    <b-jumbotron class="pt-1 pb-2">
      <b-form @submit.prevent="search">
        <b-form-row>
          <b-col>
            <b-form-group label="Name">
              <b-input v-model="name" />
            </b-form-group>
          </b-col>
        </b-form-row>
        <b-form-row>
          <b-col>
            <b-form-group label="Start">
              <b-datepicker v-model="start" reset-button />
            </b-form-group>
          </b-col>
          <b-col>
            <b-form-group label="End">
              <b-datepicker v-model="end" reset-button />
            </b-form-group>
          </b-col>
        </b-form-row>
        <b-form-row>
          <b-col>
            <b-button type="submit" class="float-right" variant="primary">Search</b-button>
          </b-col>
        </b-form-row>
      </b-form>
    </b-jumbotron>

    <template v-if="hasSearched">
      <b-table :items="list" :fields="fields">
        <template #cell(name)="data">
          <b-link :to="{ name: 'event-detail', params: { id: data.item.id } }">{{  data.value  }}</b-link> {{
           data.item.activities.map(a => a.name).join(", ") | pwrap("()")  }}
        </template>
        <template #cell(address)="data">
          {{  data.value.city  }}, {{  data.value.state  }}
        </template>
      </b-table>
      <DetailedPagination :currentPage.sync="page.number" :perPage.sync="page.length" :totalRows="counts.filter"
        :totalResults="counts.total" />
    </template>
  </b-container>
</template>

<script>
import DetailedPagination from '@/components/DetailedPagination.vue';

export default {
  name: "EventSearch",
  components: { DetailedPagination },
  data: function () {
    return {
      hasSearched: false,
      list: [],
      fields: [
        {
          key: "name"
        },
        {
          key: "address",
          label: "Location"
        },
        {
          key: "year"
        }
      ],
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
      start: null,
      end: null
    };
  },
  methods: {
    search: function () {
      this.$http.get(["events"].join("/"), { params: this.queryParams }).then(resp => {
        this.hasSearched = true;
        this.list = resp.data.elements;
        this.counts = resp.data.pagination.counts;
      });
    }
  },
  filters: {
    pwrap: function (str, pair) {
      let surround = pair.split("");
      if (str) return `${surround[0]}${str}${surround[1]}`;
      return ""
    }
  },
  computed: {
    queryParams: function () {
      let p = {
        "page.length": this.page.length,
        "page.number": this.page.number,
      };
      if (this.name)
        p.name = this.name;
      if (this.start)
        p.start = this.start;
      if (this.end)
        p.end = this.end;
      return p;
    }
  },
  watch: {
    "page.number": {
      deep: true,
      handler: function () {
        this.search();
      }
    }
  }
}
</script>

<style scoped>
</style>