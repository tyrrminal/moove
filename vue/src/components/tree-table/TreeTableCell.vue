<template>
  <td :class="cellClasses">
    <slot
      :name="'cell(' + column.key + ')'"
      v-bind:column="column"
      v-bind:item="item"
      v-bind:value="item[column.key]"
      ><slot
        name="cell"
        v-bind:column="column"
        v-bind:item="item"
        v-bind:value="item[column.key]"
        >{{ item[column.key] }}</slot
      ></slot
    >
  </td>
</template>

<script>
import CellMixin from "./mixins/Cell.js";

export default {
  name: "TreeTableCell",
  mixins: [CellMixin],
  props: {
    column: {
      type: Object,
      required: true,
    },
    item: {
      type: Object,
      required: true,
    },
    options: {
      type: Object,
      required: true,
    },
  },
};

// <td v-for="(c, i) in columns" :key="c.key" :class="c.tdClass">
//   <div :style="cellIndent(i)">
//     <TreeTableBranchToggle v-if="i == 0" :state.sync="localState">
//       <slot v-for="(_, name) in $slots" :name="name" :slot="name" />
//       <template
//         v-for="(_, name) in $scopedSlots"
//         :slot="name"
//         slot-scope="slotData"
//         ><slot :name="name" v-bind="slotData"
//       /></template>
//     </TreeTableBranchToggle>
//     <slot
//       :name="'cell(' + c.key + ')'"
//       v-bind:column="c"
//       v-bind:item="item"
//       v-bind:value="item[c.key]"
//       ><slot
//         name="cell"
//         v-bind:column="c"
//         v-bind:item="item"
//         v-bind:value="item[c.key]"
//         >{{ item[c.key] }}</slot
//       ></slot
//     >
//   </div>
// </td>
</script>


