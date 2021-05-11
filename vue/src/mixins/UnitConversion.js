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
  }
};
