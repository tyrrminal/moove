<template>
  <div>
    <b-button v-for="(l,index) in relevant" :key="`link-${index}`" @click="$router.push({name: 'event_with_user', params: {id: links[l].id, user: user }})" variant="dark" size="md" block :title="event_title(l, links[l].name)">
      <font-awesome-icon :icon="iconMap[l]" />
    </b-button>
  </div>
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
      },
      tooltipMap: {
        'next': "Next",
        'prev': "Previous",
        'sequence_next': "Next in Sequence",
        'sequence_prev': "Previous in Sequence"
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
  },
  methods: {
    event_title: function(type, title) {
      return this.tooltipMap[type] + ": " + title;
    }
  }
}
</script>

<style scoped>

</style>
