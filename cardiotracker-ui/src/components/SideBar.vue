<template>
  <b-list-group class="mt-2">
    <b-list-group-item v-for="(item, index) in items" :key="index" :to="item.to" :variant="item.variant">
      {{ item.text }}
    </b-list-group-item>
  </b-list-group>
</template>

<script>
export default {
  props: {
    items: Array
  }
}
</script>

<style scope>
.sidebar {
  background-color: #595959;
}
</style>
