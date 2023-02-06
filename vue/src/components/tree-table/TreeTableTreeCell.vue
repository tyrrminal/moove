<template>
  <td :class="cellClasses">
    <div :style="cellIndent">
      <b-button v-if="toggleable" size="sm" variant="outline" :pressed="item.state"
        @click="$emit('update-state', !item.state)" class="p-0 m-0">
        <b-icon v-if="item.state" variant="secondary" icon="caret-down"></b-icon>
        <b-icon v-else variant="secondary" icon="caret-right-fill"></b-icon>
      </b-button>
      <slot :name="'cell(' + column.key + ')'" v-bind:column="column" v-bind:item="item"
        v-bind:value="item[column.key]">
        <slot name="cell" v-bind:column="column" v-bind:item="item" v-bind:value="item[column.key]">{{
          item[column.key]
        }}</slot>
      </slot>
    </div>
  </td>
</template>

<script>
import CellMixin from "./mixins/Cell.js";

export default {
  name: "TreeTableTreeCell",
  mixins: [CellMixin],
  props: {
    toggleable: {
      type: Boolean,
      default: false,
    },
    column: {
      type: Object,
      required: true,
    },
    item: {
      type: Object,
      required: true,
    },
    depth: {
      type: Number,
      required: true,
    },
    options: {
      type: Object,
      required: true,
    },
  },
  computed: {
    cellIndent: function () {
      return {
        "padding-left": this.leftPadding + "px",
      };
    },
    leftPadding: function () {
      return 18 * this.depth;
    },
  },
};
</script>
