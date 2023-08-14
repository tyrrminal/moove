<template>
  <b-navbar toggleable="lg" type="dark" variant="info">
    <b-navbar-nav small v-if="start.length">
      <b-nav-item v-for="(item, index) in start" :key="`tbitems-${index}`" :to="item.to"
        :active="$route.name == item.to.name"><b-icon v-if="item.icon" :icon="item.icon" class="d-block mx-auto mb-1"
          scale="1.25" />{{ item.text }}</b-nav-item>
    </b-navbar-nav>
    <b-navbar-nav small class="mx-auto" v-if="middle.length">
      <b-nav-item v-for="(item, index) in middle" :key="`tbitemm-${index}`" :to="item.to"
        :active="$route.name == item.to.name"><b-icon v-if="item.icon" :icon="item.icon" class="d-block mx-auto mb-1"
          scale="1.25" />{{ item.text }}</b-nav-item>
    </b-navbar-nav>
    <b-navbar-nav small class="ml-auto" v-if="end.length">
      <b-nav-item v-for="(item, index) in end" :key="`tbiteme-${index}`" :to="item.to"
        :active="$route.name == item.to.name"><b-icon v-if="item.icon" :icon="item.icon" class="d-block mx-auto mb-1"
          scale="1.25" />{{ item.text }}</b-nav-item>
    </b-navbar-nav>
  </b-navbar>
</template>

<script>
export default {
  props: {
    items: Array,
  },
  computed: {
    start: function () {
      return this.items.filter(x => x.section == null || x.section == 'start')
    },
    middle: function () {
      return this.items.filter(x => x.section == 'middle')
    },
    end: function () {
      return this.items.filter(x => x.section == 'end')
    }
  }
};
</script>

<style scope></style>
