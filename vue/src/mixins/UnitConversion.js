import { mapGetters } from "vuex";

export default {
  computed: {
    ...mapGetters("meta", ["getUnitOfMeasure"])
  },
  methods: {
    fillUnits: function (d) {
      let bu = this.getUnitOfMeasure(d.unitOfMeasureID);
      if (bu == null) return null;
      let nu = this.getUnitOfMeasure(bu.normalUnitID) || bu;
      return {
        quantity: { value: d.value, units: bu },
        normalizedQuantity: {
          value: d.value * bu.normalizationFactor,
          units: nu,
        },
      };
    },
    paceToSpeed: function (p) {
      let multipliers = [0, 1, 60, 60, 24];
      let bits = p.split(':').reverse();
      let m = 1;
      return (multipliers[2] * multipliers[3]) / bits.reduce((a, c) => { return a + multipliers[m++] * c }, 0)
    },
    activitySpeed: function (a) {
      if (a) {
        if (a.speed) return a.speed.value;
        if (a.pace) return this.paceToSpeed(a.pace.value);
      }
      return null;
    }
  }
};
