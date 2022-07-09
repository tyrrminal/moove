<template>
  <tr>
    <TreeTableTreeCell
      :toggleable="hasChildren"
      :item="item"
      :depth="item.depth"
      :column="treeColumn"
      :options="options"
      @update-state="updateState"
    >
      <slot v-for="(_, name) in $slots" :name="name" :slot="name" />
      <template
        v-for="(_, name) in $scopedSlots"
        :slot="name"
        slot-scope="slotData"
        ><slot :name="name" v-bind="slotData" /></template
    ></TreeTableTreeCell>
    <TreeTableCell
      v-for="c in remainingColumns"
      :key="c.key"
      :column="c"
      :item="item"
      :options="options"
    >
      <slot v-for="(_, name) in $slots" :name="name" :slot="name" />
      <template
        v-for="(_, name) in $scopedSlots"
        :slot="name"
        slot-scope="slotData"
        ><slot :name="name" v-bind="slotData"
      /></template>
    </TreeTableCell>
  </tr>
</template>

<script>
import TreeTableCell from "./TreeTableCell.vue";
import TreeTableTreeCell from "./TreeTableTreeCell.vue";

export default {
  name: "TreeTableRow",
  data: function () {
    return {
      local: { state: false },
    };
  },
  components: {
    TreeTableCell,
    TreeTableTreeCell,
  },
  props: {
    item: {
      type: Object,
      required: true,
    },
    index: {
      type: Number,
      required: true,
    },
    options: {
      type: Object,
      required: true,
    },
  },
  computed: {
    hasChildren: function () {
      return this.item.children != null && Array.isArray(this.item.children);
    },
    treeColumn: function () {
      return this.options.columns[0];
    },
    remainingColumns: function () {
      return this.options.columns.slice(1);
    },
  },
  methods: {
    updateState: function (v) {
      this.$emit("update-state", { id: this.item.id, state: v });
    },
  },
};
</script>
