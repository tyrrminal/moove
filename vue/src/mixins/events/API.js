export default {
  methods: {
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
