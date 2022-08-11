import { mapGetters } from "vuex";

export default {
  computed: {
    ...mapGetters("meta", ["getUnitOfMeasure"])
  },
  methods: {
    fillUnits: function (d) {
      let bu;
      if (bu = this.getUnitOfMeasure(d.unitOfMeasureID))
        return { value: d.value, units: bu };
      return null;
    },
  }
};
