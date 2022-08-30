<template>
  <b-container>
    <b-card v-if="event" no-body class="mt-3">
      <b-card-header>
        <div class="float-right">
          <b-icon icon="compass" class="mr-1" />{{
           event.address | formatAddress 
          }}
        </div>
        <b-link href="event.url" target="_blank">{{  event.name  }}</b-link> - {{  event.year  }}
      </b-card-header>
      <b-card-body>

        <legend>Activities</legend>
        <b-table :items="sortedActivities" :fields="activityFields">
          <template #cell(scheduledStart)="data">
            {{  data.value | luxon({ input: { zone: "local" }, output: "short" })  }}
          </template>
          <template #cell(type)="data">
            {{  getEventType(data.item.eventType.id).description  }}
          </template>
          <template #cell(distance)="data">
            {{  data.value.value  }} {{  getUnit(data.value.unitOfMeasureID).abbreviation  }}
          </template>
          <template #cell(actions)="data">
            <b-button v-if="registered[data.item.id]" size="sm" class="text-uppercase" variant="primary"
              :to="{ name: 'registration-detail', params: { id: registered[data.item.id] } }">Show
            </b-button>
            <b-button v-else-if="registered[data.item.id] === false" size="sm" class="text-uppercase" variant="success"
              :to="{ name: 'registration-new', params: { eventActivityID: data.item.id } }">
              Register</b-button>
            <b-spinner v-else variant="secondary" small></b-spinner>
          </template>
        </b-table>
      </b-card-body>
    </b-card>
  </b-container>
</template>

<script>
import EventFilters from "@/mixins/events/Filters.js";

export default {
  mixins: [EventFilters],
  props: {
    id: {
      type: [Number, String],
      required: true
    }
  },
  data: function () {
    return {
      event: null,
      registered: {},

      activityFields: [
        { key: "scheduledStart", label: "Start Time" },
        { key: "type" },
        { key: "name" },
        { key: "distance" },
        { key: "actions", label: "Registration" }
      ]
    }
  },
  mounted: function () {
    this.$http.get(["events", this.id].join("/")).then(resp => {
      this.event = resp.data; this.event.activities.forEach(a => {
        this.$set(this.registered, a.id, null);
        this.$http.get(["user", "events"].join("/"), { params: { eventActivityID: a.id } }).then(resp => this.$set(this.registered, a.id, resp.data.pagination.counts.filter > 0 ? resp.data.elements[0].id : false))
      })
    })
  },
  methods: {
    getEventType: function (id) {
      return this.$store.getters["meta/getEventType"](id)
    },
    getUnit: function (id) {
      return this.$store.getters["meta/getUnitOfMeasure"](id)
    }
  },
  computed: {
    sortedActivities: function () {
      return [...this.event.activities].sort((a, b) => a.scheduledStart.localeCompare(b.scheduledStart))
    }
  }
};
</script>

<style scoped>
.event-details legend {
  font-weight: bold;
}
</style>
