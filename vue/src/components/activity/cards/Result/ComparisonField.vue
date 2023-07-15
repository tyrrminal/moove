<template>
  <div>
    <b-form-group v-if="lvalue != null || rvalue != null" :label="label">
      <template v-if="isLoaded">
        <div v-if="lvalue">{{ formatter(lvalue) }}</div>
        <div class="event-result-data" v-if="!isEqual && rvalue != null">{{ formatter(rvalue) }}</div>
      </template>
    </b-form-group>
  </div>
</template>

<script>
import EventFilters from "@/mixins/events/Filters.js";
import { mapGetters } from 'vuex';

export default {
  mixins: [EventFilters],
  props: {
    label: {
      type: String,
      default: 'Field'
    },
    lvalue: {
      required: false
    },
    rvalue: {
      required: false
    },
    comparator: {
      type: Function,
      default: (a, b) => a.localeCompare(b)
    },
    formatter: {
      type: Function,
      default: (a) => a
    }
  },
  computed: {
    ...mapGetters('meta', ['isLoaded']),
    isEqual: function () {
      if (this.lvalue != null && this.rvalue != null) return !this.comparator(this.lvalue, this.rvalue);
      return false;
    }
  }
}
</script>

<style>
.event-result-data {
  font-style: italic;
}
</style>