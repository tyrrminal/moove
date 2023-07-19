<template>
  <b-container>
    <b-card class="mt-2" no-body>
      <b-card-header @click="collapse.eventGroup = !collapse.eventGroup" class="collapse-header"><strong>Event
          Group</strong></b-card-header>
      <b-card-body v-if="!collapse.eventGroup">
        <b-button pill size="sm" variant="success" class="px-3 mr-2" v-b-modal.selectEventGroup><b-icon icon="list-ul"
            class="mr-2" />Select
          Group</b-button>
        <b-row class="mt-2">
          <b-col cols="6">
            <b-form-group label="Name" label-cols="2">
              <b-input :disabled="edit.eventGroup.id != null" :value="edit.eventGroup.name" />
            </b-form-group>
          </b-col>
        </b-row>
        <b-row>
          <b-col>
            <b-form-group label="URL" label-cols="1">
              <b-input :disabled="edit.eventGroup.id != null" :value="edit.eventGroup.url" />
            </b-form-group>
          </b-col>
        </b-row>
        <b-button pill size="sm" variant="secondary" class="px-3" @click="showEventGroupEditor"
          v-show="edit.eventGroup.id != null"><b-icon icon="pencil" class="mr-2" />Modify</b-button>
      </b-card-body>
    </b-card>

    <b-card class="mt-2 mb-4" no-body>
      <b-card-header @click="collapse.event = !collapse.event"
        class="collapse-header"><strong>Event</strong></b-card-header>
      <b-card-body v-if="!collapse.event">
        <b-row>
          <b-col cols="6">
            <b-form-group label="Name" label-cols="2">
              <b-input v-model="edit.event.name" />
            </b-form-group>
          </b-col>
          <b-col offset="2" cols="4">
            <b-form-group label="Year" label-cols="2">
              <b-input v-model="edit.event.year" />
            </b-form-group>
          </b-col>
        </b-row>
        <b-row>
          <b-col>
            <b-form-group label="URL" label-cols="1">
              <b-input v-model="edit.event.url" />
            </b-form-group>
            <b-form-group label="Address" label-cols="1">
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
        </b-row>
        <b-row>
          <b-col cols="4">
            <b-form-group label="Results" label-cols="3" content-cols="9">
              <b-input-group>
                <b-select :options="eventDataSources" text-field="name" value-field="id"
                  v-model="edit.event.externalDataSourceID" />
                <template #append>
                  <b-button variant="outline-danger" @click="clearExternalDataSource">
                    <b-icon icon="x" />
                  </b-button>
                </template>
              </b-input-group>
            </b-form-group>
          </b-col>
        </b-row>
        <b-row>
          <b-col>
            <div v-if="eventDataSource">
              <strong>{{ eventDataSource.name }} Event Parameters</strong>
              <b-form-group v-for="f in eventFields" :label="f.label" label-cols="2" content-cols="4"
                label-class="importParams-label" :state="!f.required == !edit.event.importParameters[f.name]"
                class="my-0 py-0">
                <b-input v-model="edit.event.importParameters[f.name]" :required="f.required"
                  :state="!f.required == !edit.event.importParameters[f.name]" size="sm" :number="f.type == 'integer'" />
              </b-form-group>
            </div>
          </b-col>
        </b-row>
      </b-card-body>
    </b-card>

    <b-card class="mt-2 mb-4" no-body>
      <b-card-header @click="collapse.eventActivities = !collapse.eventActivities" class="collapse-header"><strong>Event
          Activities</strong></b-card-header>
      <b-card-body v-if="!collapse.eventActivities">
        <div v-for="( a, i ) in  edit.eventActivities " :key="i"
          class="border-left border-success mb-2 pl-2 pb-1 bg-light">
          <div v-if="edit.eventActivities.length > 1 && !a.id" class="float-right">
            <b-button variant="danger" @click="edit.eventActivities.splice(i, 1)" size="sm">
              <b-icon icon="x" />
            </b-button>
          </div>
          <b-row :style="{ clear: 'both' }" class="pt-2">
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
                    <b-select :options="distanceUnitsOfMeasure" text-field="abbreviation" value-field="id"
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
          <div v-if="eventDataSource">
            <strong>{{ eventDataSource.name }} Event Activity Parameters</strong>
            <b-form-group v-for="f in eventActivityFields" :label="f.label" label-cols="2" content-cols="4"
              label-class="importParams-label" :state="!f.required == !a.importParameters[f.name]" class="my-0 py-0">
              <b-input v-model="a.importParameters[f.name]" :required="f.required"
                :state="!f.required == !a.importParameters[f.name]" size="sm" :number="f.type == 'integer'" />
            </b-form-group>
          </div>
        </div>
        <b-button variant="success" @click="addEventActivity" pill size="sm">
          <b-icon icon="plus-circle" class="mr-1" />Add an Activity
        </b-button>
      </b-card-body>
    </b-card>

    <b-card class="mt-2 mb-4" no-body>
      <b-card-header @click="collapse.eventSeries = !collapse.eventSeries" class="collapse-header"><strong>Event
          Series</strong></b-card-header>
      <b-card-body v-if="!collapse.eventSeries">
      </b-card-body>
    </b-card>

    <b-row align-h="between">
      <b-col cols=1>
        <b-button @click="$router.back()" class="mb-4 float-right" variant="secondary">Cancel</b-button>
      </b-col>
      <b-col cols=1>
        <b-button @click="saveEvent" class="mb-4 float-right" variant="primary">Save</b-button>
      </b-col>
    </b-row>

    <b-modal id="selectEventGroup" title="Select Event Group" @ok="selectEventGroup"
      :ok-disabled="eventGroupSearch.selection == null">
      <b-button variant="secondary" block pill size="sm" @click="newEventGroup"><b-icon icon="plus-circle"
          class="mr-2" />Create New Event
        Group</b-button>
      <hr />
      <b-form @submit.prevent="searchEventGroups">
        <b-input-group>
          <b-input v-model="eventGroupSearch.name" placeholder="Search" />
          <template #append>
            <b-button type="submit" variant="success" @click="searchEventGroups">Search</b-button>
          </template>
        </b-input-group>
      </b-form>

      <div v-if="eventGroupSearch.results.length > 0">
        <hr class="my-2" />

        <b-button v-for="r in eventGroupSearch.results " @click="eventGroupSearch.selection = r"
          :variant="eventGroupSearch.selection == null || eventGroupSearch.selection.id != r.id ? 'outline-primary' : 'primary'"
          class="my-1" block size="sm">
          {{ r.name }}
        </b-button>
      </div>
    </b-modal>

    <b-modal id="modifyEventGroup" title="Modify Event Group" @ok="saveEventGroup">
      <b-form-group label="Name" label-cols="3">
        <b-input v-model="eventGroupEdit.name" />
      </b-form-group>

      <b-form-group label="URL" label-cols="3">
        <b-input v-model="eventGroupEdit.url" />
      </b-form-group>
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

export default {
  name: 'EventEditor',
  mixins: [EventFilters],
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  data: function () {
    return {
      collapse: {
        eventGroup: false,
        event: false,
        eventActivities: false,
        eventSeries: false
      },

      edit: {
        event: { name: "" },
        eventGroup: { name: "" },
        eventActivities: [],
      },
      newAddress: null,
      eventGroupEdit: {},

      eventGroupSearch: {
        name: "",
        results: [],
        selection: null
      }
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
  mounted: function () {
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
        this.edit = { event: { name: "" }, eventGroup: { name: "" }, eventActivities: [] }
        if (this.event) {
          this.edit.event = this.event;
          this.edit.event.year = y;
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
        }
      } else {
        this.$http.get(["events", this.id].join("/")).then(resp => {
          this.edit.event = resp.data
          this.edit.eventGroup = resp.data.eventGroup
          this.edit.eventActivities = resp.data.activities.map(a => {
            let dt = a.scheduledStart.split("T")
            return { ...a, date: dt[0], time: dt[1] }
          })
        })
      }
    },
    clearExternalDataSource: function () {
      this.edit.event.externalDataSourceID = null;
      this.edit.event.externalIdentifier = null
    },
    searchEventGroups: function () {
      this.$http.get("eventgroups", { params: { type: 'parent', name: this.eventGroupSearch.name } })
        .then(resp => this.eventGroupSearch.results = resp.data)
    },
    selectEventGroup: function () {
      this.edit.eventGroup = { ...this.eventGroupSearch.selection }
    },
    newEventGroup: function () {
      this.edit.eventGroup = { name: "", url: "" }
      this.$bvModal.hide('selectEventGroup')
    },
    showEventGroupEditor: function () {
      this.eventGroupEdit = { ...this.edit.eventGroup }
      this.$bvModal.show('modifyEventGroup')
    },
    saveEventGroup: function () {
      let self = this;
      let eg = this.eventGroupEdit;
      let eventGroupID = eg.id;
      delete eg.id;

      let p;
      if (eventGroupID == null) {
        p = this.$http.post("eventgroups", eg);
      } else {
        p = this.$http.patch(`eventgroups/${eventGroupID}`, eg)
      }
      p.then(resp => {
        self.edit.eventGroup = { ...resp.data }
      })
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
    addEventActivity: function () {
      let prev = this.edit.eventActivities.slice(-1).pop();
      if (prev)
        this.edit.eventActivities.push({
          eventType: { id: prev.eventType.id },
          name: null,
          distance: { value: '', unitOfMeasureID: 1 },
          date: prev.date,
          time: prev.time,
          importParameters: {},
        })
      else
        this.edit.eventActivities.push({
          eventType: { id: null },
          name: null,
          distance: { value: '', unitOfMeasure: 1 },
          date: null,
          time: null,
          importParameters: {},
        })
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
      let r = { eventGroup: {}, ...this.edit.event };
      delete r.id;
      delete r.eventSeries;
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
</style>
