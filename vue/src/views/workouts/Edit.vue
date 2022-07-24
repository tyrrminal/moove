<template>
  <b-container>New/Edit Workout</b-container>
</template>

<script>
export default ({
  data: function () {
    return {
      edit: null
    }
  },
  props: {
    workout: {
      type: Object,
      default: () => { }
    }
  },
  mounted: function () {
    this.edit = cloneDeep(this.workout);
  }
})
</script>
