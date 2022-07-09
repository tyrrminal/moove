<template>
  <b-container>
    <b-form-group label="Event Name">
      <b-input v-model="event.name" />
    </b-form-group>
    <b-form-group label="Year">
      <b-input v-model="event.year" />
    </b-form-group>
  </b-container>
</template>

<script>
import Branding from "@/mixins/Branding.js";
import { DateTime } from "luxon";

export default {
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
  },
  data: function () {
    return {
      event: {
        id: this.id,
        name: "",
        year: DateTime.local().year,
        url: "",
        address: {
          id: null,
          street1: "",
          street2: "",
          city: "",
          state: "",
          zip: "",
          phone: "",
        },
        group: {
          id: null,
          url: "",
          name: "",
          year: null,
        },
        series: [],
        externalDataSource: {
          id: null,
          name: "",
          baseURL: "",
        },
        activities: [],
      },
      activity: {
        id: null,
        name: "",
        scheduledStart: DateTime.local(),
        entrants: null,
        distance: {
          id: null,
          value: 0,
          unitOfMeasureID: 1,
        },
        eventType: null,
      },
      registration: {
        id: null,
        registrationNumber: null,
      },
      userActivity: {
        id: null,
        visibilityTypeID: 1,
        dateRegistered: DateTime.local(),
        registrationFee: null,
        fundraisingRequirement: null,
      },
    };
  },
  computed: {
    title: function () {
      return `${this.applicationName} / ${
        this.isEdit ? "Edit Event" : "Create Event"
      }`;
    },
    isEdit: function () {
      return this.id != null;
    },
  },
};
</script>

<style>
</style>