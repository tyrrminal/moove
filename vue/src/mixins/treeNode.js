export default {
  beforeCreate() {
    this.$options.filters.treeDataFormatter = this.$options.filters.treeDataFormatter.bind(
      this
    );
  },
  filters: {
    treeDataFormatter: function (value, key) {
      if (value == null) return "-";
      if (key.includes("count")) return value;
      if (typeof value === "number")
        return this.$options.filters.number(value, "0.00");
      return value;
    },
  },
};
