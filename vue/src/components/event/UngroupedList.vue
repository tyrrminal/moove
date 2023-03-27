<template>
  <div>
    <Grid :events="events" date-format="DATE_MED" :separate-year="false" v-bind="gridOptions" />
  </div>
</template>

<script>
import Grid from "@/components/event/Grid"

export default {
  name: "UngroupedList",
  components: {
    Grid
  },
  props: {
    events: {
      type: Array,
      required: true
    },
    loaded: {
      type: Boolean,
      default: true
    },
    gridOptions: {
      type: Object,
      default: () => { }
    }
  }
}
</script>
