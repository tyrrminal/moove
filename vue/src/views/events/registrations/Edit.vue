<template>
  <b-container fluid>
    <b-row>
      <b-col cols="2" class="min-vh-100 bg-dark pt-3">
        <b-button block variant="primary" @click="save"><b-icon icon="save" class="mr-2" />Save</b-button>
        <b-button block variant="secondary" @click="$router.back()">Cancel</b-button>
      </b-col>
      <b-col>
        <div class="mt-3" v-if="event">
          <h2 class="float-right">{{ event.year }}</h2>
          <h2>{{ event.name }}</h2>
          <h6 class="float-right">{{
            eventActivity.scheduledStart | luxon({ input: { zone: "local" }, output: "short" })
          }}</h6>
          <h3 v-if="event.activities && event.activities.length == 1">{{ eventActivity.name }}</h3>
        </div>
        <hr :style="{ clear: 'both' }" />

        <b-form class="mt-2">
          <b-form-group v-if="event.activities && event.activities.length > 1" label="Activity" label-cols="2">
            <b-select :options="event.activities" text-field="name" value-field="id" v-model="selectedEventActivity" />
          </b-form-group>
          <b-form-group label="Registered On" label-cols="2" content-cols="4">
            <b-datepicker v-model="userActivity.dateRegistered" />
          </b-form-group>
          <b-form-group label="Registration/Bib #" label-cols="2" content-cols="1">
            <b-input v-model="registration.registrationNumber" />
          </b-form-group>
          <b-form-group label="Registration Total" label-cols="2" content-cols="2">
            <b-input-group>
              <template #prepend>
                <b-button :disabled="true" variant="secondary">$</b-button>
              </template>
              <b-input v-model="userActivity.registrationFee" number />
            </b-input-group>
          </b-form-group>
          <b-form-group label="Fundraising Minimum" label-cols="2" content-cols="2">
            <b-input-group>
              <template #prepend>
                <div class="rounded-left border border-control pl-1">
                  <b-checkbox class="mt-1 ml-1" v-model="hasFundraisingRequirement" />
                </div>
                <b-button :disabled="true" variant="secondary">$</b-button>
              </template>
              <b-input :disabled="!hasFundraisingRequirement" v-model.trim="userActivity.fundraising.minimum" number />
            </b-input-group>
          </b-form-group>
          <b-form-group label="Visibility" label-cols="2" content-cols="2">
            <b-select :options="getVisibilityTypes" v-model="userActivity.visibilityTypeID" value-field="id"
              text-field="description" />
          </b-form-group>
        </b-form>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import Branding from "@/mixins/Branding.js";
import { DateTime } from "luxon";
import { mapGetters } from "vuex";

export default {
  name: "EditRegistration",
  mixins: [Branding],
  metaInfo: function () {
    return {
      title: this.title,
    };
  },
  props: {
    id: {
      type: [Number, String],
      default: null,
    },
    eventActivityID: {
      type: Number,
      default: null
    }
  },
  data: function () {
    return {
      event: {},
      eventActivity: {},
      registration: {
        registrationNumber: null,
      },
      userActivity: {
        id: null,
        eventActivityID: null,
        visibilityTypeID: 3,
        dateRegistered: DateTime.local().toISODate(),
        registrationFee: 0,
        fundraising: { minimum: null },
      },
      hasFundraisingRequirement: false
    };
  },
  created: function () {
    if (this.id) {
      this.$http.get(["user", "events", this.id].join("/")).then(resp => {
        this.registration = {
          registrationNumber: resp.data.registrationNumber
        };
        this.userActivity = {
          id: resp.data.id,
          eventActivityID: resp.data.eventActivity.id,
          visibilityTypeID: resp.data.visibilityTypeID,
          dateRegistered: resp.data.dateRegistered,
          registrationFee: resp.data.registrationFee,
          fundraising: { minimum: null, ...resp.data.fundraising }
        }
        this.hasFundraisingRequirement = this.userActivity.fundraising.minimum != null
        this.event = resp.data.eventActivity.event;
        this.eventActivity = resp.data.eventActivity;
        delete (this.eventActivity.event);
        this.$http.get(["events", this.event.id].join("/")).then(resp => this.event = resp.data)
      })
    } else if (this.eventActivityID) {
      this.userActivity.eventActivityID = this.eventActivityID;
      this.$http.get(["events", "activities", this.eventActivityID].join("/")).then(resp => {
        this.eventActivity = resp.data;
        this.$http.get(["events", this.eventActivity.event.id].join("/")).then(resp => this.event = resp.data)
        delete (this.eventActivity.event)
      })
    }
  },
  computed: {
    ...mapGetters("meta", ["getVisibilityTypes"]),
    title: function () {
      return `${this.applicationName} / ${this.isEdit ? "Edit Registration" : "Register to Event"
        }`;
    },
    isEdit: function () {
      return this.id != null;
    },
    selectedEventActivity: {
      get() {
        return this.userActivity.eventActivityID
      },
      set(newValue) {
        this.userActivity.eventActivityID = newValue
      }
    },
    apiRecord: function () {
      let r = { ...this.registration, ...this.userActivity };
      r.eventActivity = { id: r.eventActivityID }
      delete (r.id);
      delete (r.eventActivityID)
      return r;
    }
  },
  methods: {
    save: function () {
      (this.isEdit ? this.$http.patch(["user", "events", this.id].join("/"), this.apiRecord) : this.$http.post(["user", "events"].join("/"), this.apiRecord))
        .then(resp => this.$router.push({ name: "registration-detail", params: { id: resp.data.id } }));
    }
  },
  watch: {
    hasFundraisingRequirement: function (newVal) {
      if (!newVal)
        this.userActivity.fundraising.minimum = null
      else if (this.userActivity.fundraising.minimum == null)
        this.userActivity.fundraising.minimum = 0
    }
  }
};
</script>

<style scoped>
.border-control {
  border-color: var(--vs-colors--lightest) !important;
}
</style>