<template>
  <b-dropdown :variant="variant" left>
    <template #button-content>
      <b-icon v-if="isFiltered" icon="circle-fill" :scale="0.5" class="mr-1" />Event Types
    </template>
    <b-container :style="{ width: '40rem' }">
      <label class="font-weight-bold">Event Types</label><b-button size="sm" variant="warning"
        class="ml-1 py-0 float-right" @click="clearSelection()">Reset</b-button>
      <b-checkbox switch class="mb-2" @change="toggleVirtual($event)">Non-virtual only</b-checkbox>
      <b-row>
        <b-col v-for="at in activityTypes">
          <b-checkbox switch class="font-weight-bold" :checked="activityTypeIsEnabled(at)"
            @change="toggleActivityType(at)">{{ at.labels.base }}</b-checkbox>
          <b-checkbox v-for=" et in getEventTypesForActivityType(at)" :key="et.id" :checked="eventTypes[et.id]"
            @change="toggleEventType(et)">{{
              et.description }}</b-checkbox>
        </b-col>
      </b-row>
    </b-container>
  </b-dropdown>
</template>

<script>
import cloneDeep from 'clone-deep';
import { mapGetters } from 'vuex'

export default {
  name: "EventTypeSelector",
  props: {
    value: {
      type: Object,
      required: true
    },
    cols: {
      type: Number,
      default: 3
    }
  },
  data: function () {
    return {
      eventTypes: {}
    }
  },
  computed: {
    ...mapGetters("meta", ["getEventTypes"]),
    variant: function () {
      return this.isFiltered ? 'primary' : 'secondary'
    },
    isFiltered: function () {
      return Object.keys(this.value).reduce((a, c) => this.value[a] === true || c, false)
    },
    eventTypeRows: function () {
      return [...Array(Math.ceil(this.activityTypes.length / this.cols)).keys()]
    },
    activityTypes: function () {
      let ats = new Map();
      this.getEventTypes.map(et => et.activityType).forEach(at => ats.set(at.id, at))
      return [...ats.values()];
    },
  },
  methods: {
    toggleVirtual: function (v) {
      if (v)
        this.getEventTypes.forEach(et => {
          if (et.virtual) delete (this.eventTypes[et.id])
          else this.toggleEventType(et, true)
        })
      else this.clearSelection();
    },
    clearSelection: function () {
      this.eventTypes = {}
      this.$emit('input', this.eventTypes)
    },
    eventTypesInRow: function (index) {
      let max = this.activityTypes.length
      return this.activityTypes.slice(index * this.cols, Math.min(index + this.cols + this.cols, max))
    },
    activityTypeIsEnabled: function (activityType) {
      let t = { ...this.eventTypes }
      return this.getEventTypesForActivityType(activityType).reduce((a, v) => a && t[v.id] === true, true)
    },
    toggleActivityType: function (activityType) {
      let self = this
      let state = !this.activityTypeIsEnabled(activityType)
      this.getEventTypesForActivityType(activityType).forEach(et => self.toggleEventType(et, state))
    },
    getEventTypesForActivityType: function (activityType) {
      return this.getEventTypes.filter(et => et.activityType.id == activityType.id)
    },
    toggleEventType: function (eventType, v = null) {
      v = v == null ? !this.eventTypes[eventType.id] : v
      if (v)
        this.$set(this.eventTypes, eventType.id, true);
      else
        delete (this.eventTypes[eventType.id]);
      this.$emit('input', this.eventTypes)
    }
  },
  watch: {
    value: {
      immediate: true,
      deep: true,
      handler: function (newVal) {
        this.eventTypes = cloneDeep(newVal)
      }
    }
  }
}
</script>