<template>
  <b-dropdown :variant="variant" right class="mr-1" small>
    <template #button-content><b-icon v-if="isFiltered" icon="circle-fill" :scale="0.5" class="mr-1" />Activity
      Types</template>
    <ActivityTypeSelection v-model="activityTypes" :cols="4" />
  </b-dropdown>
</template>

<script>
import ActivityTypeSelection from "@/components/ActivityTypeSelection";

export default {
  name: "ActivityTypeSelector",
  components: {
    ActivityTypeSelection
  },
  props: {
    value: {
      type: Object,
      required: true
    }
  },
  computed: {
    activityTypes: {
      get: function () { return this.value },
      set: function (newVal) { this.$emit('input', newVal) }
    },
    variant: function () {
      return this.isFiltered ? 'primary' : 'secondary'
    },
    isFiltered: function () {
      return Object.keys(this.value).reduce((a, c) => this.value[a] === true || c, false)
    }
  },
}
</script>
