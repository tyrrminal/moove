<template>
  <table :class="tableClasses">
    <TreeTableHeader
      v-if="showHeader"
      :options="tableOptions"
      @update:sort="toggleSort"
    >
      <slot v-for="(_, name) in $slots" :name="name" :slot="name" />
      <template
        v-for="(_, name) in $scopedSlots"
        :slot="name"
        slot-scope="slotData"
        ><slot :name="name" v-bind="slotData"
      /></template>
    </TreeTableHeader>
    <tbody>
      <TreeTableRow
        v-for="(c, i) in visibleRows"
        :key="i"
        :item="c"
        :index="i"
        :options="tableOptions"
        @update-state="updateState"
      >
        <slot v-for="(_, name) in $slots" :name="name" :slot="name" />
        <template
          v-for="(_, name) in $scopedSlots"
          :slot="name"
          slot-scope="slotData"
          ><slot :name="name" v-bind="slotData"
        /></template>
      </TreeTableRow>
    </tbody>
    <TreeTableFooter v-if="showFooter" :options="tableOptions">
      <slot v-for="(_, name) in $slots" :name="name" :slot="name" />
      <template
        v-for="(_, name) in $scopedSlots"
        :slot="name"
        slot-scope="slotData"
        ><slot :name="name" v-bind="slotData"
      /></template>
    </TreeTableFooter>
  </table>
</template>

<script>
import TreeTableHeader from "./TreeTableHeader.vue";
import TreeTableRow from "./TreeTableRow.vue";
import TreeTableFooter from "./TreeTableFooter.vue";

export default {
  name: "TreeTable",
  components: {
    TreeTableHeader,
    TreeTableRow,
    TreeTableFooter,
  },
  data: function () {
    return {
      internal: { rows: [] },
      sort: {
        field: null,
        direction: "asc",
      },
    };
  },
  props: {
    "striped-rows": {
      type: Boolean,
      default: false,
    },
    "striped-columns": {
      type: Boolean,
      default: false,
    },
    "show-header": {
      type: Boolean,
      default: true,
    },
    "show-footer": {
      type: Boolean,
      default: false,
    },
    sortable: {
      type: Boolean,
      default: false,
    },
    initialState: {
      type: Function,
      default: (item, depth) => false,
    },
    rows: {
      type: Array,
      default: () => [],
    },
    columns: {
      type: Array,
      default: () => [],
    },
    "table-class": {
      type: [String, Array],
      default: () => ["border-top", "border-bottom"],
    },
    "head-class": {
      type: [String, Array],
      default: () => [
        "px-1",
        "text-uppercase",
        "border-top",
        "border-bottom",
        "border-secondary",
      ],
    },
    "cell-class": {
      type: [String, Array],
      default: () => ["pl-1", "pr-1", "border-bottom", "border-secondary"],
    },
    "foot-class": {
      type: [String, Array],
      default: () => [],
    },
  },
  methods: {
    getClasses: function (v) {
      if (Array.isArray(v)) return v;
      return v.split(" ");
    },
    updateState: function (o) {
      this.internal.rows.find((r) => r.id == o.id).state = o.state;
      this.updateRows();
    },
    updateRows: function () {
      let oldMap = this.internal.rows;
      this.internal.rows = [];
      this.sortedRows.forEach((r) => {
        this.internal.rows.push(...this.rowsForItem(r, oldMap));
      });
    },
    rowsForItem: function (item, itemMap, parent = null) {
      let rows = [];
      if (parent == null) parent = { visible: true, state: true, depth: -1 };
      let existing = itemMap.find((i) => i.id == item.id);
      rows[0] = {
        id: item.id,
        depth: parent.depth + 1,
        visible: parent.state && parent.visible,
        data: item,
      };
      if (Array.isArray(item.children)) {
        rows[0].state =
          existing == null
            ? this.initialState(item, rows[0].depth)
            : existing.state;
        item.children.forEach((row) =>
          rows.push(...this.rowsForItem(row, itemMap, rows[0]))
        );
      }
      return rows;
    },
    toggleSort: function (c) {
      let k = c["sort-key"] || c.key;
      if (k == this.sort.field)
        this.sort.direction = this.sort.direction == "asc" ? "desc" : "asc";
      else
        this.sort = {
          field: k,
          direction: "asc",
        };
    },
    sortRows: function (orig) {
      if (this.sort.field == null || !this.sortable) return orig;
      let arr = orig.slice().sort(this.rowCompare);
      arr.forEach((el) => {
        if (Array.isArray(el.children))
          el.children = this.sortRows(el.children);
      });
      return arr;
    },
    rowCompare: function (a, b) {
      let va = a[this.sort.field];
      let vb = b[this.sort.field];
      let v;
      if (va == null && vb == null) v = 0;
      else if (vb == null) v = 1;
      else if (va == null) v = -1;
      else if (typeof va == "number" && typeof vb == "number") v = va - vb;
      else v = va.localeCompare(vb);
      if (this.sort.direction == "desc") v *= -1;
      return v;
    },
  },
  computed: {
    sortedRows: function () {
      return this.sortRows(this.rows);
    },
    tableOptions: function () {
      return {
        columns: this.columns,
        sort: this.sort,
        sortable: this.sortable,
        initialState: this.initialState,
        classes: {
          table: this.getClasses(this.tableClass),
          th: this.getClasses(this.headClass),
          td: this.getClasses(this.cellClass),
          tf: this.getClasses(this.footClass),
        },
      };
    },
    tableClasses: function () {
      let r = ["tree-table"];
      if (this.stripedColumns) r.push("col-striped");
      if (this.stripedRows) r.push("row-striped");
      r.push(...this.tableOptions.classes.table);
      return r;
    },
    visibleRows: function () {
      return this.internal.rows
        .filter((r) => r.visible)
        .map((r) => ({
          ...r.data,
          depth: r.depth,
          state: r.state,
        }));
    },
  },
  watch: {
    rows: {
      immediate: true,
      deep: true,
      handler: function (newValue, oldValue) {
        this.updateRows();
      },
    },
    columns: {
      immediate: true,
      handler: function (newValue, oldValue) {
        this.sort.field = newValue[0]["sort-key"] || newValue[0].key;
      },
    },
    sort: {
      deep: true,
      handler: function () {
        this.updateRows();
      },
    },
  },
};
</script>

<style scoped>
table.tree-table.col-striped >>> td:nth-child(even),
table.tree-table.col-striped >>> th:nth-child(even) {
  background-color: #e9e9e9;
}

table.tree-table.row-striped >>> tr:nth-child(even) td {
  background-color: #e9e9e9;
}

table.tree-table.col-striped.row-striped
  >>> tr:nth-child(even)
  td:nth-child(even) {
  background-color: #d4d4d4;
}
</style>
