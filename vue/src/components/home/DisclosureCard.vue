<template>
  <div role="tablist">
    <b-card no-body class="mb-1">
      <b-card-header role="tab" header-tag="header" v-b-toggle="name" v-html="$options.filters.prefaceAngle(title)" />
      <b-collapse :id="name" role="tabpanel">
        <b-card-body>
          <b-card-text v-if="text">{{ text }}</b-card-text>
          <b-list-group v-if="items" flush>
            <b-list-group-item v-for="(i, index) in items" :key="`${name}-${index}`">{{ i }}</b-list-group-item>
          </b-list-group>
        </b-card-body>
      </b-collapse>
    </b-card>
  </div>
</template>

<script>
export default {
  props: {
    title: String,
    text: String,
    items: Array,
    name: String
  },
  filters: {
    prefaceAngle: function (t) {
      return '&rsaquo; ' + t;
    }
  }
}
</script>

<style>

</style>
