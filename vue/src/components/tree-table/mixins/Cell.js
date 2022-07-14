export default {
  computed: {
    cellClasses: function () {
      let column = this.column;
      let c = ["text-nowrap", ...this.options.classes.td];
      if (Array.isArray(column.tdClass)) c.push(...column.tdClass);
      else if (column.tdClass) c.push(...column.tdClass.split(" "));
      return c;
    },
  }
}