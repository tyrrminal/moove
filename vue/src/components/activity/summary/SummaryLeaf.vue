<template>
  <div class="row">
    <div
      class="cell"
      :style="{
        'padding-left': leftPadding + 'px',
        'margin-right': '-' + leftPadding + 'px',
      }"
    >
      {{ rowData[firstColumn] }}
    </div>
    <div v-for="key in regularColumns" :key="key" class="cell">
      {{ rowData[key] | treeDataFormatter(key) }}
    </div>
  </div>
</template>

<script>
import TreeNode from "@/mixins/treeNode.js";

export default {
  name: "SummaryLeaf",
  mixins: [TreeNode],
  props: {
    rowData: {
      type: Object,
      default: () => {
        return {};
      },
    },
    defaultOrder: {
      type: Array,
      default: () => {
        return [];
      },
    },
    depth: {
      type: Number,
      default: 0,
    },
  },
  computed: {
    firstColumn: function () {
      return this.defaultOrder[0];
    },
    regularColumns: function () {
      return this.defaultOrder.slice(1);
    },
    leftPadding: function () {
      return this.depth * 16;
    },
  },
};
</script>
