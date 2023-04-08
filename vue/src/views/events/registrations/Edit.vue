<template>
  <b-container>
    <b-row>
      <b-col cols="6" offset="3">
        <div class="mt-3" v-if="event">
          <h2 class="float-right">{{ event.year }}</h2>
          <h2>{{ event.name }}</h2>
          <h6 class="float-right">{{
            eventActivity.scheduledStart | luxon({ input: { zone: "local" }, output: "short" })
          }}</h6>
          <h3 v-if="event.activities.length == 1">{{ eventActivity.name }}</h3>
        </div>
        <hr :style="{ clear: 'both' }" />
      </b-col>
    </b-row>

    <b-form class="mt-2">
      <b-form-row v-if="event.activities.length > 1">
        <b-col cols="6" offset="3">
          <b-form-group label="Activity">
            <b-select :options="event.activities" text-field="name" value-field="id" v-model="selectedEventActivity" />
          </b-form-group>
        </b-col>
      </b-form-row>
      <b-form-row>
        <b-col cols="6" offset="3">
          <b-form-group label="Registration Date">
            <b-datepicker v-model="userActivity.dateRegistered" />
          </b-form-group>
        </b-col>
      </b-form-row>
      <b-form-row>
        <b-col cols="3" offset="3">
          <b-form-group label="Registration/Bib #">
            <b-input v-model="registration.registrationNumber" />
          </b-form-group>
        </b-col>
        <b-col cols="3">
          <b-form-group label="Visibility">
            <b-select :options="getVisibilityTypes" v-model="userActivity.visibilityTypeID" value-field="id"
              text-field="description" />
          </b-form-group>
        </b-col>
      </b-form-row>
      <b-form-row>
        <b-col cols="3" offset="3">
          <b-form-group label="Registration Total">
            <b-input-group>
              <template #prepend>
                <b-button :disabled="true" variant="secondary">$</b-button>
              </template>
              <b-input v-model="userActivity.registrationFee" number />
            </b-input-group>
          </b-form-group>
        </b-col>
        <b-col cols="3">
          <b-form-group label="Fundraising Minimum">
            <b-input-group>
              <template #prepend>
                <b-button :disabled="true" variant="secondary">$</b-button>
              </template>
              <b-input :disabled="!hasFundraisingRequirement" v-model.trim="userActivity.fundraising.minimum" number />
              <template #append>
                <div class="rounded-right border border-control pl-1">
                  <b-checkbox class="mt-1 ml-1" v-model="hasFundraisingRequirement" />
                </div>
              </template>
            </b-input-group>
          </b-form-group>
        </b-col>
      </b-form-row>

      <b-form-row>
        <b-col cols="6" offset="3">
          <hr />
          <b-button variant="secondary" @click="cancel">Cancel</b-button>
          <b-button class="float-right" @click="save" variant="success">Save</b-button>
        </b-col>
      </b-form-row>
    </b-form>
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
        this.event = this.eventActivity.event;
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
    }
  },
  methods: {
    cancel: function () {
      this.$router.back();
    },
    save: function () {
      let p;
      let ua = { ...this.registration, ...this.userActivity };
      if (this.isEdit)
        p = this.$http.patch(["user", "events", this.id].join("/"), ua);
      else {
        delete (ua.id);
        p = this.$http.post(["user", "events"].join("/"), ua)
      }
      p.then(resp => this.$router.push({ name: "registration-detail", params: { id: resp.data.id } }));
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