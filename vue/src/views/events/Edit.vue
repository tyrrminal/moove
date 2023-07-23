<template>
  <b-container fluid>
    <b-row>
      <b-col cols="2" class="vh-100 bg-dark pt-3">
        <b-button block variant="primary" @click="saveEvent"><b-icon icon="save" class="mr-2" />Save</b-button>
        <b-button block variant="secondary" @click="$router.back()">Cancel</b-button>
      </b-col>
      <b-col cols="9" class="mt-3 event-editor">
        <b-form-row class="mb-2">
          <b-col class="text-center">
            <label v-if="edit.eventGroup.name" class="font-weight-bold" :style="{ fontSize: '1.25rem' }">{{
              edit.eventGroup.name }}</label>
            <label v-else class="font-italic">No Event Group Selected</label>
            <b-button class="py-0 ml-2" variant="success" pill size="sm" v-b-modal.selectEventGroup>Change</b-button>
          </b-col>
        </b-form-row>
        <b-form-row>
          <b-col :cols="edit.eventSeries.length == 0 ? 3 : 12">
            <div class="bg-primary-light border border-primary rounded-lg py-2 px-3 mb-2">
              <strong :style="{ fontSize: '1.0rem' }">Event Series</strong>
              <b-button class="py-0 ml-2" variant="secondary" pill size="sm" v-b-modal.selectEventSeries><b-icon
                  icon="plus" class="mr-1" />Add</b-button>
              <div v-for="(s, i) in edit.eventSeries" class="d-block">
                <b-icon icon="chevron-right" class="mr-2" />
                <label :style="{ fontSize: '1.0rem ' }">{{ s.year }} {{
                  s.name }}</label>
                <b-button pill size="sm" variant="danger" class="py-0 ml-2" @click="edit.eventSeries.splice(i, 1)"><b-icon
                    icon="x" class="mr-1" />Remove</b-button>
              </div>
            </div>
          </b-col>
        </b-form-row>
        <b-form-row>
          <b-col cols="6">
            <b-form-group label="Name">
              <b-input v-model="edit.event.name" name="event-name" />
            </b-form-group>
          </b-col>
          <b-col offset="4" cols="2">
            <b-form-group label="Year">
              <b-input v-model="edit.event.year" name="event-year" :number="true" type="number" />
            </b-form-group>
          </b-col>
        </b-form-row>
        <b-form-row>
          <b-col>
            <b-form-group label="URL">
              <b-input v-model="edit.event.url" />
            </b-form-group>
          </b-col>
        </b-form-row>
        <b-form-row>
          <b-col>
            <b-form-group label="Address">
              <b-input-group>
                <b-input :disabled="true" :value="$options.filters.formatAddress(edit.event.address || {})
                  " />
                <template #append>
                  <b-dropdown variant="outline-secondary">
                    <b-dropdown-item @click="makeNewAddress">Change</b-dropdown-item>
                    <b-dropdown-item @click="unsetAddress">Clear</b-dropdown-item>
                  </b-dropdown>
                </template>
              </b-input-group>
            </b-form-group>
          </b-col>
        </b-form-row>
        <b-form-row>
          <b-col cols="5">
            <b-form-group label="Results">
              <b-input-group>
                <b-select :options="eventDataSources" text-field="name" value-field="id"
                  v-model="edit.event.externalDataSourceID" />
                <template #append>
                  <b-button variant="secondary" @click="clearExternalDataSource" size="sm">Clear</b-button>
                </template>
              </b-input-group>
            </b-form-group>
          </b-col>
          <b-col v-if="eventDataSource" offset="1" class="bg-success-light p-3 rounded-sm border border-success">
            <strong>Import Parameters</strong>
            <b-form-group v-for="f in eventFields" :label="f.label" label-cols="3" label-class="importParams-label"
              :state="!f.required == !edit.event.importParameters[f.name]" class="my-0 py-0">
              <b-input v-model="edit.event.importParameters[f.name]" :required="f.required"
                :state="!f.required == !edit.event.importParameters[f.name]" size="sm" :number="f.type == 'integer'" />
            </b-form-group>
          </b-col>
        </b-form-row>
        <hr />
        <div>
          <strong :style="{ fontSize: '1.0rem' }">Event Activities</strong>
          <b-button size="sm" pill variant="success" class="ml-2 py-0 mt-1 px-3" @click="addEventActivity"><b-icon
              icon="plus-circle" class="mr-2" />Add</b-button>
        </div>
        <b-row class="mt-2">
          <b-col cols="3">
            <b-list-group>
              <b-list-group-item v-for="(ea, i) in edit.eventActivities" :style="{ fontSize: '0.9rem' }" class="py-1"
                button @click="selectEventActivity(i)" :active="i == selectedEventActivityIdx"><b-icon icon="x-diamond"
                  class="mr-1" /><b-icon class="float-right" icon="arrow-right-circle-fill" :scale="1.25"
                  :shift-v="-4" />{{ ea.name
                  }}</b-list-group-item>
            </b-list-group>
          </b-col>
          <b-col class="event-activity-editor bg-light border border-gray rounded-sm py-2 px-3">
            <b-form-group label="Start" label-cols="1">
              <b-input-group>
                <b-datepicker v-model="edit.eventActivities[selectedEventActivityIdx].date" />
                <template #append>
                  <b-timepicker v-model="edit.eventActivities[selectedEventActivityIdx].time" />
                </template>
              </b-input-group>
            </b-form-group>
            <b-form-row>
              <b-col cols="4">
                <b-form-group label="Name" label-cols="3"
                  :description="edit.eventActivities.length > 1 ? 'Required' : 'Optional'">
                  <b-input name="event-activity-name" v-model="edit.eventActivities[selectedEventActivityIdx].name" />
                </b-form-group>
                <b-form-group label="Type" label-cols="3">
                  <b-select :options="eventTypes" text-field="description" value-field="id"
                    v-model="edit.eventActivities[selectedEventActivityIdx].eventType.id" />
                </b-form-group>
                <b-form-group label="Distance" label-cols="3">
                  <b-input-group>
                    <b-input v-model="edit.eventActivities[selectedEventActivityIdx].distance.value" />
                    <template #append>
                      <b-select :options="distanceUnitsOfMeasure" text-field="abbreviation" value-field="id"
                        v-model="edit.eventActivities[selectedEventActivityIdx].distance.unitOfMeasureID" />
                    </template>
                  </b-input-group>
                </b-form-group>
              </b-col>
              <b-col v-if="eventDataSource" class="bg-success-light p-3 rounded-sm border border-success ml-2">
                <strong>Import Parameters</strong>
                <b-form-group v-for="f in eventActivityFields" :label="f.label" label-cols="2"
                  label-class="importParams-label"
                  :state="!f.required == !edit.eventActivities[selectedEventActivityIdx].importParameters[f.name]"
                  class="my-0 py-0">
                  <b-input v-model="edit.eventActivities[selectedEventActivityIdx].importParameters[f.name]"
                    :required="f.required"
                    :state="!f.required == !edit.eventActivities[selectedEventActivityIdx].importParameters[f.name]"
                    size="sm" :number="f.type == 'integer'" />
                </b-form-group>
              </b-col>
            </b-form-row>
            <b-button v-if="edit.eventActivities.length > 1" variant="danger" @click="deleteSelectedEventActivity"
              size="sm" pill block class="mt-2">
              <b-icon icon="trash" class="mr-2" />Delete
            </b-button>
          </b-col>
        </b-row>
      </b-col>
    </b-row>

    <b-modal id="selectEventGroup" title="Select Event Group" :ok-disabled="eventGroupSelect?.id == null"
      @show="eventGroupSelect = null" @ok="selectEventGroup">
      <EventGroupSearch type="parent" v-model="eventGroupSelect" :current="edit.eventGroup" />
    </b-modal>

    <b-modal id="selectEventSeries" title="Select Event Series" :ok-disabled="eventSeriesSelect?.id == null"
      @show="eventSeriesSelect = {}" @ok="edit.eventSeries.push(eventSeriesSelect)">
      <EventGroupSearch type="series" v-model="eventSeriesSelect" />
    </b-modal>

    <b-modal id="changeAddress" title="Edit Address" @cancel="clearAddress" @ok="saveAddress">
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
import EventGroupSearch from "@/components/event/EventGroupSearch.vue"

export default {
  name: 'EventEditor',
  mixins: [EventFilters],
  components: {
    EventGroupSearch
  },
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  data: function () {
    return {
      edit: {
        event: { name: "" },
        eventGroup: { name: "" },
        eventSeries: [],
        eventActivities: [],
      },
      newAddress: null,

      eventGroupEdit: {},
      eventGroupSelect: null,
      eventSeriesSelect: null,

      selectedEventActivityIdx: 0,
    };
  },
  props: {
    id: {
      type: String | Number,
      default: null,
    },
    event: {
      type: Object,
      default: null,
    },
    eventGroup: {
      type: Object,
      default: null
    },
    eventActivity: {
      type: Object,
      default: null
    },
  },
  created: function () {
    if (this.eventGroup)
      this.edit.eventGroup = this.eventGroup;
    this.reload();
  },
  methods: {
    nullOnBlank: function (value) {
      return value ? value : null;
    },
    reload: function () {
      if (this.isNew) {
        const y = DateTime.now().year;
        this.edit = { event: { name: "", importParameters: {} }, eventGroup: { name: "" }, eventActivities: [], eventSeries: [] }
        if (this.event) {
          this.edit.event = this.event;
          this.edit.event.year = y;
        }
        if (this.eventGroup) {
          this.edit.eventGroup = this.eventGroup
        }
        if (this.eventActivity) {
          let dt = this.eventActivity.scheduledStart.split("T");
          let d = y + dt[0].slice(4)
          let ea = this.eventActivity;
          delete (ea.id)
          this.edit.eventActivities.push({
            ...ea,
            date: d,
            time: dt[1],
          });
        } else {
          this.edit.event.year = DateTime.now().year;
          this.addEventActivity();
        }
      } else {
        this.$http.get(["events", this.id].join("/")).then(resp => {
          this.edit.event = resp.data
          this.edit.eventGroup = resp.data.eventGroup
          this.edit.eventSeries = resp.data.eventSeries;
          this.edit.eventActivities = resp.data.activities.map(a => {
            let dt = a.scheduledStart.split("T")
            return { ...a, date: dt[0], time: dt[1] }
          })
        })
      }
      this.selectEventActivity(0)
    },
    selectEventGroup: function () {
      this.edit.eventGroup = this.eventGroupSelect
      if (!this.edit.event.name) this.edit.event.name = this.edit.eventGroup.name;
    },
    clearExternalDataSource: function () {
      this.edit.event.externalDataSourceID = null;
    },
    makeNewAddress: function () {
      this.newAddress = Object.assign({}, this.edit.event.address);
      delete this.newAddress.id;
      this.$bvModal.show("changeAddress");
    },
    saveAddress: function () {
      this.edit.event.address = this.newAddress;
      this.clearAddress();
    },
    clearAddress: function () {
      this.newAddress = null;
    },
    unsetAddress: function () {
      this.edit.event.address = { id: null }
    },
    selectEventActivity: function (idx) {
      this.selectedEventActivityIdx = idx;
    },
    deleteSelectedEventActivity: function () {
      this.edit.eventActivities.splice(this.edit.eventActivities.findIndex(ea => ea.id == this.selectEventActivity.id), 1)
      this.selectEventActivity(0)
    },
    addEventActivity: function () {
      let prev = this.edit.eventActivities.slice(-1).pop();
      let ea;
      if (prev)
        ea = {
          eventType: { id: prev.eventType.id },
          name: null,
          distance: { value: '', unitOfMeasureID: 1 },
          date: prev.date,
          time: prev.time,
          importParameters: {},
        }
      else
        ea = {
          eventType: { id: null },
          name: null,
          distance: { value: '', unitOfMeasure: 1 },
          date: null,
          time: null,
          importParameters: {},
        }
      this.edit.eventActivities.push(ea);
      this.selectEventActivity(this.edit.eventActivities.length - 1)
    },
    saveEvent: function () {
      (this.isNew ? this.$http.post("events", this.apiRecord) : this.$http.patch(["events", this.edit.event.id].join("/"), this.apiRecord)).then((resp) => {
        let promises = [];
        this.edit.eventActivities.forEach((a) => {
          let eaRecord = {
            scheduledStart: [a.date, a.time].join("T"),
            name: a.name,
            eventType: { id: a.eventType.id },
            distance: { value: a.distance.value, unitOfMeasureID: a.distance.unitOfMeasureID },
            importParameters: this.blanksToNulls(a.importParameters),
          };
          promises.push(a.id == null ? this.$http.post(["events", resp.data.id, "activities"].join("/"), eaRecord) : this.$http.patch(["events", "activities", a.id].join("/"), eaRecord));
        });
        Promise.all(promises).then(() => this.$router.push({ name: "event-detail", params: { id: resp.data.id } }))
      });
    },
    blanksToNulls: function (obj) {
      let r = {};
      Object.keys(obj).forEach(k => r[k] = obj[k] ? obj[k] : null);
      return r;
    }
  },
  computed: {
    ...mapGetters("meta", {
      eventTypes: "getEventTypes",
      unitsOfMeasure: "getUnitsOfMeasure",
      externalDataSources: "getExternalDataSources",
    }),
    isNew: function () {
      return this.$route.name == 'event-create'
    },
    title: function () {
      return this.isNew ? 'Create Event' : 'Edit Event';
    },
    distanceUnitsOfMeasure: function () {
      return this.unitsOfMeasure.filter(x => x.type == 'Distance')
    },
    eventDataSource: function () {
      return this.eventDataSources.find(x => x.id == this.edit.event.externalDataSourceID)
    },
    eventDataSources: function () {
      return this.externalDataSources.filter((x) => x.type == "Event");
    },
    apiRecord: function () {
      let r = { eventGroup: {}, ...this.edit.event, eventSeries: this.edit.eventSeries };
      delete r.id;
      delete r.activities;
      r.importParameters = this.blanksToNulls(r.importParameters);
      if (this.eventGroup) r.eventGroup.id = this.eventGroup.id;
      return r;
    },
    eventFields: function () {
      return this.eventDataSource.fields.filter(f => !f.activity).sort((a, b) => a.label.localeCompare(b.label));
    },
    eventActivityFields: function () {
      return this.eventDataSource.fields.filter(f => f.activity).sort((a, b) => a.label.localeCompare(b.label));
    }
  },
  watch: {
    '$route.name': function () {
      this.reload()
    }
  }
};
</script>

<style>
.importParams-label {
  font-size: 0.875rem;
}

.collapse-header {
  cursor: row-resize
}

.bg-success-light {
  background-color: #c1f0cd !important;
}

.bg-primary-light {
  background-color: #9eccfd !important;
}

.event-editor legend {
  font-size: 0.75rem;
  font-weight: bold;
}
</style>
