<template>
  <b-navbar toggleable="lg" type="dark" variant="info">
    <b-navbar-nav small>
      <b-nav-item
        v-for="(item, index) in items"
        :key="`tbitem-${index}`"
        :to="item.to"
        ><b-icon
          v-if="item.icon"
          :icon="item.icon"
          class="d-block mx-auto mb-1"
          scale="1.25"
        />{{ item.text }}</b-nav-item
      >
    </b-navbar-nav>
  </b-navbar>
</template>

<script>
export default {
  props: {
    items: Array,
  },
};
</script>

<style scope>
</style>
