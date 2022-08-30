<template>
  <b-container>
    <b-row>
      <b-col cols="6">
        <b-card class="mt-2" no-body v-if="eventGroup">
          <b-card-header><strong>Parent Event
              <b-icon v-if="eventGroup" icon="lock-fill" />
            </strong></b-card-header>
          <b-card-body>
            <b-form-group>
              <b-input :disabled="true" :value="eventGroup.name" />
            </b-form-group>
            <b-form-group>
              <b-input-group>
                <b-input :disabled="true" :value="eventGroup.url" />
                <template #append>
                  <b-button :href="eventGroup.url" target="_blank">
                    <b-icon icon="link" />
                  </b-button>
                </template>
              </b-input-group>
            </b-form-group>
          </b-card-body>
        </b-card>
      </b-col>
    </b-row>

    <b-card class="mt-2" no-body>
      <b-card-header><strong>Event</strong></b-card-header>
      <b-card-body>
        <b-row>
          <b-col cols="6">
            <b-form-group label="Name" label-cols="2">
              <b-input v-model="newEvent.event.name" />
            </b-form-group>
          </b-col>
          <b-col offset="3" cols="3">
            <b-form-group label="Year" label-cols="2">
              <b-input v-model="newEvent.event.year" />
            </b-form-group>
          </b-col>
        </b-row>
        <b-form-group label="URL" label-cols="1">
          <b-input v-model="newEvent.event.url" />
        </b-form-group>
        <b-form-group label="Address" label-cols="1">
          <b-input-group>
            <b-input :disabled="true" :value="
              $options.filters.formatAddress(newEvent.event.address || {})
            " />
            <template #append>
              <b-button variant="warning" @click="makeNewAddress">Change</b-button>
            </template>
          </b-input-group>
        </b-form-group>
        <b-row>
          <b-col cols="4">
            <b-form-group label="Results" label-cols="3" content-cols="9">
              <b-input-group>
                <b-select :options="eventDataSources" text-field="name" value-field="id"
                  v-model="newEvent.event.externalDataSourceID" />
                <template #append>
                  <b-button variant="outline-danger" @click="newEvent.event.externalDataSourceID = null">
                    <b-icon icon="x" />
                  </b-button>
                </template>
              </b-input-group>
            </b-form-group>
          </b-col>
          <b-col cols="4">
            <b-form-group label="Results Event ID" label-cols="4" content-cols="6">
              <b-input v-model="newEvent.event.externalIdentifier" :disabled="!newEvent.event.externalDataSourceID" />
            </b-form-group>
          </b-col>
        </b-row>
      </b-card-body>
    </b-card>

    <b-card class="mt-2 mb-4" no-body>
      <b-card-header><strong>Event Activities</strong></b-card-header>
      <b-card-body>
        <div v-for="(a, i) in newEvent.eventActivities" :key="i"
          class="border-left border-success mb-2 pl-2 pb-1 bg-light">
          <div class="float-right">
            <b-button v-if="i > 0" variant="danger" @click="newEvent.eventActivities.splice(i, 1)" size="sm">
              <b-icon icon="x" />
            </b-button>
          </div>
          <b-row class="pt-2">
            <b-col cols="4">
              <b-form-group label="Name" label-cols="3">
                <b-input v-model="a.name" title="Required when Event has multiple activities" />
              </b-form-group>
            </b-col>
            <b-col cols="4">
              <b-form-group label="Type" label-cols="3">
                <b-select :options="eventTypes" text-field="description" value-field="id" v-model="a.eventType.id" />
              </b-form-group>
            </b-col>
            <b-col cols="3">
              <b-form-group label="Distance" label-cols="4">
                <b-input-group>
                  <b-input v-model="a.distance.value" />
                  <template #append>
                    <b-select :options="unitsOfMeasure" text-field="abbreviation" value-field="id"
                      v-model="a.distance.unitOfMeasureID" />
                  </template>
                </b-input-group>
              </b-form-group>
            </b-col>
          </b-row>
          <b-row>
            <b-col cols="6">
              <b-form-group label="Start" label-cols="2">
                <b-input-group>
                  <b-datepicker v-model="a.date" />
                  <template #append>
                    <b-timepicker v-model="a.time" />
                  </template>
                </b-input-group>
              </b-form-group>
            </b-col>
          </b-row>
          <b-form-group label="Results Activity ID" label-cols="2" content-cols="2">
            <b-input v-model="a.externalIdentifier" :disabled="!newEvent.event.externalDataSourceID" />
          </b-form-group>
        </div>
        <b-button variant="outline-success" @click="addEventActivity">
          <b-icon scale="3" icon="plus" class="mr-1"></b-icon> Add an
          Activity
        </b-button>
      </b-card-body>
    </b-card>

    <b-button @click="saveEvent" class="mb-4 float-right" variant="primary">Save</b-button>

    <b-modal id="changeAddress" title="Edit Address" @cancel="newAddress = null" @ok="
  newEvent.event.address = newAddress;
newAddress = null;
    ">
      <template v-if="newAddress">
        <b-form-group label="Street (1)" label-cols="2">
          <b-input v-model="newAddress.street1" />
        </b-form-group>
        <b-form-group label="Street (2)" label-cols="2">
          <b-input v-model="newAddress.street2" />
        </b-form-group>
        <b-form-group label="City" label-cols="2">
          <b-input v-model="newAddress.city" />
        </b-form-group>
        <b-form-group label="State" label-cols="2">
          <b-input v-model="newAddress.state" />
        </b-form-group>
        <b-form-group label="Zip" label-cols="2">
          <b-input v-model="newAddress.zip" />
        </b-form-group>
        <b-form-group label="Country" label-cols="2">
          <b-input v-model="newAddress.country" />
        </b-form-group>
        <b-form-group label="Phone" label-cols="2">
          <b-input v-model="newAddress.phone" />
        </b-form-group>
        <b-form-group label="Email" label-cols="2">
          <b-input v-model="newAddress.email" />
        </b-form-group>
      </template>
    </b-modal>
  </b-container>
</template>

<script>
import { mapGetters } from "vuex";
import { DateTime } from "luxon";
import EventFilters from "@/mixins/events/Filters.js";

export default {
  mixins: [EventFilters],
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  data: function () {
    return {
      title: "Create Event",

      newEvent: {
        event: { name: "" },
        eventGroup: { name: "" },
        eventActivities: [],
      },
      newAddress: null,
    };
  },
  props: {
    event: null,
    eventGroup: null,
    eventActivity: null,
  },
  mounted: function () {
    if (this.event) {
      this.newEvent.event = this.event;
      this.newEvent.event.year = DateTime.now().year;
    }
    if (this.eventActivity) {
      let dt = this.eventActivity.scheduledStart.split("T");
      this.newEvent.eventActivities.push({
        ...this.eventActivity,
        date: dt[0],
        time: dt[1],
      });
    }
  },
  methods: {
    makeNewAddress: function () {
      this.newAddress = Object.assign({}, this.newEvent.event.address);
      delete this.newAddress.id;
      this.$bvModal.show("changeAddress");
    },
    addEventActivity: function () {
      this.newEvent.eventActivities.push({
        eventType: { id: 0 },
        name: null,
        distance: { value: '', unitOfMeasureID: 1 },
        date: '',
        time: '',
      })
    },
    saveEvent: function () {
      this.$http.post("events", this.apiRecord).then((resp) => {
        let promises = [];
        this.newEvent.eventActivities.forEach((a) => {
          let p = this.$http.post(["events", resp.data.id, "activities"].join("/"), {
            scheduledStart: [a.date, a.time].join("T"),
            name: a.name,
            eventType: { id: a.eventType.id },
            distance: a.distance,
            externalIdentifier: a.externalIdentifier,
          });
          promises.push(p);
        });
        Promise.all(promises).then(results => this.$router.push({ name: "event-detail", params: { id: resp.data.id } }))
      });
    },
  },
  computed: {
    ...mapGetters("meta", {
      eventTypes: "getEventTypes",
      unitsOfMeasure: "getUnitsOfMeasure",
      externalDataSources: "getExternalDataSources",
    }),
    eventDataSources: function () {
      return this.externalDataSources.filter((x) => x.type == "Event");
    },
    apiRecord: function () {
      let r = { eventGroup: {}, ...this.newEvent.event };
      delete r.id;
      if (this.eventGroup) r.eventGroup.id = this.eventGroup.id;
      return r;
    },
  },
};
</script>

<style>
</style>