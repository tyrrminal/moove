<template>
  <b-list-group>
    <b-list-group-item v-for="(l,index) in relevant" :key="`link-${index}`">
      <router-link :to="{ name: 'event_with_user', params: {id: links[l].id, user: user } }" :title="links[l].name"><font-awesome-icon :icon="iconMap[l]" /></router-link>
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
    direction: String,
    user: String
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
