<template>
  <b-navbar toggleable="lg" type="dark" variant="info">
    <b-collapse is-nav>
      <b-navbar-nav small>
        <b-nav-item v-for="(item, index) in items" :key="index" :to="item.to">{{ item.text }}</b-nav-item>
      </b-navbar-nav>
    </b-collapse>
  </b-navbar>
</template>

<script>
export default {
  props: {
    items: Array
  }
};
</script>

<style scope>
</style>
