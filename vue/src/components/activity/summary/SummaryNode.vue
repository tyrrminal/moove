<template>
  <div>
    <div class="row">
      <div
        class="cell"
        :style="{
          'padding-left': leftPadding + 'px',
          'margin-right': '-' + leftPadding + 'px',
        }"
      >
        <div class="open-button" @click="toggle">
          <b-icon v-if="isOpen" icon="caret-down" />
          <b-icon v-else icon="caret-right-fill" />
        </div>
        <div>
          {{ rowData[firstColumn] }}
        </div>
      </div>
      <div v-for="key in regularColumns" :key="key" class="cell">
        {{ rowData[key] | treeDataFormatter(key) }}
      </div>
    </div>
  </div>
</template>

<script>
import TreeNode from "@/mixins/treeNode.js";

export default {
  name: "SummaryNode",
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
    onToggle: {
      type: Function,
      default: () => {},
    },
    onOpen: {
      type: Function,
      default: () => {},
    },
    onClose: {
      type: Function,
      default: () => {},
    },
  },
  data: function () {
    return {
      isOpen: false,
    };
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
  methods: {
    toggle() {
      this.isOpen = !this.isOpen;
      this.onToggle();
    },
  },
};
</script>

<style scoped>
.open-button {
  float: left;
  display: inline;
  padding-right: 0.5rem;
}
</style>
