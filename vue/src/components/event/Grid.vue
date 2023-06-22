<template>
  <div>
    <h5 v-if="label">{{ label }}</h5>
    <b-table striped small hover :items="events" :fields="fields" :sort-compare="sortCompare" :foot-clone="showFooter"
      no-footer-sorting responsive show-empty :tbody-tr-class="rowClass">
      <template v-slot:table-busy>
        <div class="text-center text-info my-2">
          <b-spinner class="align-middle"></b-spinner>
          <strong>Loading...</strong>
        </div>
      </template>

      <template v-slot:empty>
        <slot name="no-data"></slot>
      </template>

      <template v-slot:thead-top="data" v-if="showResults">
        <b-tr :title="data">
          <b-th colspan="5">
            <span class="sr-only">Default Fields</span>
          </b-th>
          <b-th colspan="2" class="text-center">Overall</b-th>
          <b-th colspan="2" class="text-center">Gender</b-th>
          <b-th colspan="2" class="text-center">Division</b-th>
        </b-tr>
      </template>

      <template #foot()><span></span></template>
      <template #foot(date)><span v-if="showResults">Best</span>
        <span v-else>Total</span></template>
      <template #foot(registrationFee)>
        {{
          events.map((e) => e.registrationFee).reduce((a, c) => a + (c || 0), 0)
          | currency
        }}
      </template>
      <template #foot(distance)><span v-if="events.length">
          {{ eventDistance | formatDistance }}
        </span>
      </template>
      <template #foot(place)>{{
        Math.min(
          ...events
            .filter((e) => e.placements)
            .map((e) => e.placements.overall.place)
            .filter((p) => p != null)
        )
      }}</template>
      <template #foot(pct)>{{
        Math.max(
          ...events
            .filter((e) => e.placements)
            .map((e) => e.placements.overall.percentile)
        ) | percent(1)
      }}</template>
      <template #foot(placeGender)>{{
        Math.min(
          ...events
            .filter((e) => e.placements && e.placements.gender)
            .map((e) => e.placements.gender.place)
            .filter((p) => p != null)
        )
      }}</template>
      <template #foot(pctGender)>{{
        Math.max(
          ...events
            .filter((e) => e.placements && e.placements.gender)
            .map((e) => e.placements.gender.percentile)
        ) | percent(1)
      }}</template>
      <template #foot(placeDivision)>{{
        Math.min(
          ...events
            .filter((e) => e.placements && e.placements.division)
            .map((e) => e.placements.division.place)
            .filter((p) => p != null)
        )
      }}</template>
      <template #foot(pctDivision)>{{
        Math.max(
          ...events
            .filter((e) => e.placements && e.placements.division)
            .map((e) => e.placements.division.percentile)
        ) | percent(1)
      }}</template>
      <template #foot(frMinimum)>
        {{
          events
            .filter((e) => e.fundraising != null)
            .map((e) => e.fundraising.minimum)
            .reduce((a, c) => a + c, 0) | currency
        }}
      </template>
      <template #foot(frReceived)>
        {{
          events
            .filter((e) => e.fundraising != null)
            .map((e) => e.fundraising.received)
            .reduce((a, c) => a + c, 0) | currency
        }}
      </template>
      <template #foot(frPct)>
        {{ frPctAvg | percent(1) }}
      </template>

      <template v-slot:cell(index)="data">{{ data.index + 1 }}</template>
      <template #cell(year)="data">{{ data.item.eventActivity.scheduledStart.substr(0, 4) }}</template>
      <template v-slot:cell(date)="data">{{
        data.item.eventActivity.scheduledStart | luxon({ output: { format: dateFormat } })
      }}</template>
      <template #cell(countdown)="data">
        <Countdown :to="data.item.eventActivity.scheduledStart" />
      </template>
      <template v-slot:cell(type)="data">{{
        data.item.eventActivity.eventType.description
      }}</template>
      <template v-slot:cell(name)="data">
        <b-link :to="{
          name: 'registration-detail',
          params: { id: data.item.id },
        }" class="text-muted">{{ data.item.eventActivity.event.name }}</b-link>
      </template>
      <template v-slot:cell(registrationFee)="data">
        {{ data.value | currency }}
      </template>
      <template v-slot:cell(speed)="data">{{ fillUnits(eventVelocity(data.item)) | formatDistance }}
      </template>
      <template v-slot:cell(distance)="data">{{
        fillUnits(data.item.eventActivity.distance) | formatDistanceTrim
      }}</template>

      <template v-slot:cell(entrants)="data"><span v-if="data.item.placements && data.item.placements.overall">{{
        data.item.placements.overall.of }}</span></template>
      <template v-slot:cell(place)="data"><span v-if="data.item.placements && data.item.placements.overall">{{
        data.item.placements.overall.place
      }}<span v-if="data.item.placements.overall.of" class="placement-partition-size">
            / {{ data.item.placements.overall.of }}</span></span></template>
      <template v-slot:cell(pct)="data"><span v-if="data.item.placements && data.item.placements.overall">{{
        data.item.placements.overall.percentile | percent(1)
      }}</span></template>
      <template v-slot:cell(placeGender)="data"><span v-if="data.item.placements && data.item.placements.gender">{{
        data.item.placements.gender.place
      }}<span v-if="data.item.placements.gender.of" class="placement-partition-size">
            / {{ data.item.placements.gender.of }}</span></span></template>
      <template v-slot:cell(pctGender)="data"><span v-if="data.item.placements &&
        data.item.placements.gender &&
        data.item.placements.gender.percentile != null
        ">{{ data.item.placements.gender.percentile | percent(1) }}</span></template>
      <template v-slot:cell(placeDivision)="data"><span v-if="data.item.placements && data.item.placements.division">{{
        data.item.placements.division.place
      }}<span v-if="data.item.placements.division.of" class="placement-partition-size">
            / {{ data.item.placements.division.of }}</span></span></template>
      <template v-slot:cell(pctDivision)="data"><span v-if="data.item.placements &&
        data.item.placements.division &&
        data.item.placements.division.percentile != null
        ">{{ data.item.placements.division.percentile | percent(1) }}</span></template>

      <template v-slot:cell(frMinimum)="data"><span v-if="data.item.fundraising">{{
        data.item.fundraising.minimum | currency
      }}</span></template>
      <template v-slot:cell(frReceived)="data"><span v-if="data.item.fundraising">{{
        data.item.fundraising.received | currency
      }}</span></template>
      <template v-slot:cell(frPct)="data"><span v-if="data.item.fundraising">{{
        (data.item.fundraising.received / data.item.fundraising.minimum)
        | percent(1)
      }}</span></template>
    </b-table>
  </div>
</template>

<script>
import { DateTime } from "luxon";
import UnitConversion from "@/mixins/UnitConversion.js";
import { mapGetters } from "vuex";
import EventFilters from "@/mixins/events/Filters.js";
import { activityRate, convertUnitValue } from "@/utils/unitConversion.js";

import Countdown from "@/components/Countdown.vue";

export default {
  mixins: [UnitConversion, EventFilters],
  components: {
    Countdown
  },
  props: {
    events: {
      type: Array,
      required: true,
    },
    label: {
      type: String,
      default: null
    },
    dateFormat: {
      type: String,
      default: "ccc LLL d"
    },
    separateYear: {
      type: Boolean,
      default: true
    },
    showFees: {
      type: Boolean,
      default: true
    },
    showSpeed: {
      type: Boolean,
      default: true
    },
    showResults: {
      type: Boolean,
      default: false
    },
    showFundraising: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    sortCompare: function (a, b, key, sortDesc, formatterFn, options, locale) {
      if (!this.fields.find((f) => f.key == key)) key = "date";
      var t = "str";
      if (key == "name") {
        a = a.eventActivity.event.name;
        b = b.eventActivity.event.name;
      }
      if (key == "type") {
        a = a.eventActivity.eventType.description;
        b = b.eventActivity.eventType.description;
      }
      if (key == "date") {
        a = a.eventActivity.scheduledStart;
        b = b.eventActivity.scheduledStart;
      }
      if (key == "registrationFee") {
        t = "num";
        a = a.registrationFee || 0;
        b = b.registrationFee || 0;
      }
      if (key == "distance") {
        t = "num";
        let aa = a.eventActivity ?? a.activity;
        a = convertUnitValue(
          aa.distance.value,
          this.getUnitOfMeasure(aa.distance.unitOfMeasureID)
        );
        let ba = b.eventActivity ?? b.activity;
        b = convertUnitValue(
          ba.distance.value,
          this.getUnitOfMeasure(ba.distance.unitOfMeasureID)
        );
      }
      if (key == "speed") {
        t = "num";
        let ar = activityRate(a.eventResult || a.activity);
        let br = activityRate(b.eventResult || b.activity);
        a =
          ar == null
            ? 0
            : convertUnitValue(
              ar.value,
              this.getUnitOfMeasure(ar.unitOfMeasureID)
            );
        b =
          br == null
            ? 0
            : convertUnitValue(
              br.value,
              this.getUnitOfMeasure(br.unitOfMeasureID)
            );
      }
      if (key == "entrants") {
        t = "num";
        a = a.placements.overall.of;
        b = b.placements.overall.of;
      }
      var m;
      if ((m = key.match(/(place|pct)(Division|Gender)?/))) {
        t = "num";
        let f = m[1] == "pct" ? "percentile" : m[1];
        let nv = f == "percentile" ? 0 : Number.MAX_SAFE_INTEGER;
        let g = m[2] == null ? "overall" : m[2].toLowerCase();
        a = a.placements[g][f] || nv;
        b = b.placements[g][f] || nv;
      }
      if (key == "frMinimum") {
        t = "num";
        a = a.fundraising.minimum;
        b = b.fundraising.minimum;
      }
      if (key == "frReceived") {
        t = "num";
        a = a.fundraising.received;
        b = b.fundraising.received;
      }
      if (key == "frPct") {
        t = "num";
        a = a.fundraising.received / a.fundraising.minimum;
        b = b.fundraising.received / b.fundraising.minimum;
      }
      if (t == "str") return a.localeCompare(b, locale, options);
      return a - b;
    },
    eventVelocity: function (e) {
      let values = [];
      ["eventResult", "activity"].filter(k => Object.hasOwn(e, k)).splice(0, 1).forEach(k => {
        values.push(...[e[k].pace, e[k].speed].filter(x => !!x))
      });
      if (this.$store.getters["meta/getActivityType"](e.activity.activityTypeID).hasSpeed) values.reverse();
      return values[0];
    },
    getResultsGroup: function (results, partitionType) {
      let g = results[partitionType];
      if (g == null) return { percentile: null, place: null };
      g.percentile = (100 * g.place) / g.of;
      return g;
    },
    rowClass: function (item) {
      let r = ["text-muted"];
      if (item != null && item.visibilityTypeID == 1) r.push('event-private')
      return r
    },
  },
  computed: {
    ...mapGetters("meta", ["getUnitOfMeasure", "getUnitsOfMeasure"]),

    showFooter: function () {
      return this.events.length > 1;
    },
    eventDistance: function () {
      let activities = this.events.map((e) => e.activity ?? e.eventActivity);
      let v = activities.reduce(
        (a, c) =>
          a +
          convertUnitValue(
            c.distance.value,
            this.getUnitOfMeasure(c.distance.unitOfMeasureID)
          ),
        0
      );
      return {
        value: v,
        units: this.getUnitsOfMeasure.find(
          (u) => u.normalUnitID == null && u.type == "Distance"
        ),
      };
    },
    frPctAvg: function () {
      let fr = this.events.filter((e) => e.fundraising != null);
      return (
        fr
          .map((e) => e.fundraising.received / e.fundraising.minimum)
          .reduce((a, c) => a + c, 0) / fr.length
      );
    },
    eventYears: function () {
      return [...new Set(this.events.map(e => DateTime.fromISO(e.eventActivity.scheduledStart).year))]
    },
    fields: function () {
      let self = this;
      let baseFields = [
        { key: "year", sortable: false, predicate: () => self.eventYears.length > 1 && self.separateYear },
        { key: "date", sortable: true },
        { key: "countdown", sortable: false, tdClass: "text-right pr-3", thClass: "text-right", predicate: () => Math.min(...self.events.map(e => DateTime.fromISO(e.eventActivity.scheduledStart))) > DateTime.now() },
        { key: "name", sortable: true, thClass: "text-center" },
        { key: "type", sortable: true },
        { key: "distance", sortable: true },
        { key: "speed", sortable: true, predicate: () => self.events.some(e => !!e.activity) && self.showSpeed },
        { key: "registrationFee", label: "Fee", sortable: true, predicate: () => self.showFees },
        { key: 'entrants', sortable: true, label: "Field", predicate: () => self.showResults },
        { key: "place", sortable: true, label: "Place", predicate: () => self.showResults },
        { key: "pct", sortable: true, label: "%", predicate: () => self.showResults },
        { key: "placeGender", sortable: true, label: "Place", predicate: () => self.showResults },
        { key: "pctGender", sortable: true, label: "%", predicate: () => self.showResults },
        { key: "placeDivision", sortable: true, label: "Place", predicate: () => self.showResults },
        { key: "pctDivision", sortable: true, label: "%", predicate: () => self.showResults },
        {
          key: "frMinimum", sortable: true, label: "Minimum", predicate: () => self.showFundraising,
          tdClass: "text-right pr-2", thClass: "ncol",
        },
        {
          key: "frReceived", sortable: true, label: "Recieved", predicate: () => self.showFundraising,
          tdClass: "text-right pr-2", thClass: "ncol",
        },
        {
          key: "frPct", sortable: true, label: "%", predicate: () => self.showFundraising,
          tdClass: "text-right pr-2", thClass: "ncol",
        },
      ];
      return baseFields.filter(f => Object.hasOwn(f, 'predicate') ? f.predicate() : true);
    },
  },
};
</script>

<style>
tfoot .ncol {
  text-align: right;
  padding-right: 0.5rem;
}

.placement-partition-size {
  font-size: 0.66rem;
  color: grey;
  vertical-align: top;
}

.event-private {
  background-color: rgb(255, 215, 215) !important;
}

.event-private:hover {
  background-color: rgb(255, 197, 197) !important;
}
</style>
