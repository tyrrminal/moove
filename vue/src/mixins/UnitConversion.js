import { mapGetters } from "vuex";

export default {
  computed: {
    ...mapGetters("meta", ["getUnitOfMeasure"]),
  },
  methods: {
    fillUnits: function (d) {
      if (d == null || d == "") return "";
      let bu;
      if ((bu = this.getUnitOfMeasure(d.unitOfMeasureID)))
        return { value: d.value, units: bu };
      return null;
    },
  },
};
