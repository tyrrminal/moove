export default {
  data: function () {
    return {
      events: []
    }
  },
  methods: {
    loadEvents: function (pageNum = 1) {
      let self = this;
      let params = Object.prototype.hasOwnProperty.call(this, 'params') ? this.params : {};
      self.$http
        .get(["user", "events"].join("/"), {
          params: { ...params, "page.number": pageNum },
        })
        .then((resp) => {
          self.events.push(
            ...resp.data.elements.map((x) => this.processEventPlacements(x))
          );
          if (self.events.length < resp.data.pagination.counts.filter)
            self.loadEvents(pageNum + 1);
        });
    },
    processEventPlacements: function (event) {
      if (event.placements != null) {
        let placements = event.placements;
        event.placements = {
          overall: { place: null, percentile: null },
          gender: { place: null, percentile: null },
          division: { place: null, percentile: null },
        };
        placements.forEach(
          (p) =>
          (event.placements[p.partitionType || "overall"] = {
            ...p,
            percentile: 1 - p.place / p.of,
          })
        );
      }
      return event;
    },
  }
}
