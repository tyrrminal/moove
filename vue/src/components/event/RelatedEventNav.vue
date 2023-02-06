<template>
  <div>
    <b-button size="sm" :disabled="prev == null" variant="none" class="mr-1" :to="
      prev
        ? { name: 'registration-detail', params: { id: prev.id } }
        : null
    ">
      <b-icon variant="primary" icon="caret-left-fill" />
    </b-button>
    <b-link :to="{
      name: 'registration-series',
      params: {
        id: series.id,
        username: series.username,
      },
    }"><span v-if="series.year">{{ series.year }} </span>{{ series.name }}</b-link>
    <b-button v-if="next != null" size="sm" variant="none" class="ml-1"
      :to="{ name: 'registration-detail', params: { id: next.id } }">
      <b-icon variant="primary" icon="caret-right-fill" />
    </b-button>
    <b-link class="ml-3" v-else-if="createEventParams" :to="{
      name: 'event-create',
      params: createEventParams
    }">
      <b-icon icon="plus" :scale="1.5" />
    </b-link>
  </div>
</template>

<script>
export default {
  props: {
    next: {
      type: Object,
      required: false
    },
    series: {
      type: Object,
      required: true
    },
    prev: {
      type: Object,
      required: false
    },
    createEventParams: {
      type: Object,
      required: false
    }
  }
}
</script>

<style scoped>

</style>