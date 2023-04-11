<template>
  <b-container :style="{ width: '60rem' }">
    <label class="font-weight-bold">Activity Types</label><b-button size="sm" variant="warning"
      class="ml-1 py-0 float-right" @click="clearSelection()">Reset</b-button>
    <b-row v-for="i in activityTypeRows" class="mb-2">
      <b-col v-for="c in activityTypesInRow(i)" :key="c" :cols="cols">
        <b-checkbox switch class="font-weight-bold" :checked="baseActivityIsEnabled(c)" @change="toggleBaseActivity(c)">{{
          c }}</b-checkbox>
        <div v-for="at in getActivityTypesForBase(c)" :key="at.id">
          <b-checkbox class="ml-2" :checked="activityTypes[at.id]" @change="toggleActivityType(at)">{{
            at.labels.context
          }}</b-checkbox>
        </div>
      </b-col>
    </b-row>
  </b-container>
</template>

<script>
import cloneDeep from 'clone-deep';
import { mapGetters } from 'vuex';

export default {
  name: "ActivityTypeSelection",
  props: {
    value: {
      type: Object,
      default: () => { }
    },
    cols: {
      type: Number,
      default: 3
    }
  },
  data: function () {
    return {
      activityTypes: {}
    }
  },
  computed: {
    ...mapGetters("meta", ["getBaseActivityTypes"]),
    activityTypeRows: function () {
      return [...Array(Math.ceil(this.getBaseActivityTypes.length / this.cols)).keys()]
    }
  },
  methods: {
    clearSelection: function () {
      this.activityTypes = {}
      this.$emit('input', this.activityTypes)
    },
    activityTypesInRow: function (index) {
      let max = this.getBaseActivityTypes.length;
      return this.getBaseActivityTypes.slice(index * this.cols, Math.min(index * this.cols + this.cols, max))
    },
    baseActivityIsEnabled: function (baseActivity) {
      let t = { ...this.activityTypes };
      return this.getActivityTypesForBase(baseActivity).reduce((a, v) => a && t[v.id] === true, true);
    },
    toggleBaseActivity: function (baseActivity) {
      let self = this;
      let state = !this.baseActivityIsEnabled(baseActivity);
      this.getActivityTypesForBase(baseActivity).forEach(at => self.toggleActivityType(at, state))
    },
    getActivityTypesForBase: function (baseActivity) {
      return this.$store.getters["meta/getActivityTypesForBase"](baseActivity)
    },
    toggleActivityType: function (activityType, v = null) {
      v = v == null ? !this.activityTypes[activityType.id] : v
      this.$set(this.activityTypes, activityType.id, v)
      this.$emit('input', this.activityTypes)
    }
  },
  watch: {
    value: {
      immediate: true,
      deep: true,
      handler: function (newVal) {
        this.activityTypes = cloneDeep(newVal)
      }
    },
  }
}
</script>