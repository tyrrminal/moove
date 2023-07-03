export default {
  methods: {
    eventVelocity: function (e) {
      let values = [];
      ["eventResult", "activity"].filter(k => Object.hasOwn(e, k)).splice(0, 1).forEach(k => {
        values.push(...[e[k].pace, e[k].speed].filter(x => !!x))
      });
      if (e.activity != null) {
        let t = this.$store.getters["meta/getActivityType"](e.activity.activityTypeID);
        if (t && t.hasSpeed)
          values.reverse();
      }
      return values[0];
    },
  }
}