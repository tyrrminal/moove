<template>
  <b-list-group>
    <b-list-group-item v-for="(l,index) in relevant" :key="`link-${index}`">
      <router-link :to="{ name: links[l].route_name, params: links[l].params }" :title="links[l].text"><font-awesome-icon :icon="iconMap[l]" /></router-link>
    </b-list-group-item>
  </b-list-group>
</template>

<script>
export default {
  data() {
    return {
      iconMap: {
        'next': 'angle-right',
        'prev': 'angle-left',
        'sequence_next': 'angle-double-right',
        'sequence_prev': 'angle-double-left'
      }
    }
  },
  props: {
    links: Object,
    direction: String
  },
  computed: {
    relevant: function() {
      var l = new Array();
      for (var p in this.links) {
        if(p.match(new RegExp(this.direction))) {
          l.push(p);
        }
      }
      return l;
    }
  }
}
</script>

<style scoped>

</style>
