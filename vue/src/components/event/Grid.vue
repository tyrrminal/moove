<template>
  <div>
    <h5 v-if="label">{{ label }}</h5>
    <b-table striped small hover :items="events" :fields="fields" :sort-compare="sortCompare" :foot-clone="showFooter"
      no-footer-sorting responsive show-empty :tbody-tr-class="rowClass" :style="{ fontSize: '9pt' }">
      <template #table-busy>
        <div class="text-center text-info my-2">
          <b-spinner class="align-middle"></b-spinner>
          <strong>Loading...</strong>
        </div>
      </template>

      <template #empty>
        <slot name="no-data"></slot>
      </template>

      <template #thead-top="data" v-if="showResults">
        <b-tr :title="data">
          <b-th :colspan="resultsFieldOffset">
            <span class="sr-only">Default Fields</span>
          </b-th>
          <b-th colspan="2" class="text-center">Overall</b-th>
          <b-th colspan="2" class="text-center">Gender</b-th>
          <b-th colspan="2" class="text-center">Division</b-th>
        </b-tr>
      </template>

      <template #foot()><span></span></template>
      <template #foot(date)>Total</template>
      <template #foot(registrationFee)>{{ totals.registrationFee | currency }}</template>
      <template #foot(distance)><span v-if="events.length">{{ totals.distance | formatDistance }}</span></template>
      <template #foot(frMinimum)>{{ totals.frMinimum | currency }}</template>
      <template #foot(frReceived)>{{ totals.frReceived | currency }}</template>
      <template #foot(frPct)>{{ averages.frPct | percent(1) }}</template>

      <template #cell(index)="data">{{ data.index + 1 }}</template>
      <template #cell(year)="data">{{ data.item.eventActivity.scheduledStart.substr(0, 4) }}</template>
      <template #cell(date)="data">{{
        data.item.eventActivity.scheduledStart | luxon({ output: { format: dateFormat } })
      }}</template>
      <template #cell(countdown)="data">
        <Countdown :to="data.item.eventActivity.scheduledStart" />
      </template>
      <template #cell(type)="data">{{
        data.item.eventActivity.eventType.description
      }}</template>
      <template #cell(name)="data">
        <b-link :to="{
          name: 'registration-detail',
          params: { id: data.item.id },
        }" class="text-muted">{{ data.item.eventActivity.event.name }}</b-link>
      </template>
      <template #cell(registrationNumber)="data"><span v-if="data.value">#{{ data.value }}</span></template>
      <template #cell(registrationFee)="data"><span
          :class="prHighlightClass(data.value, 'registrationFee', 'text-danger')">{{ data.value | currency
          }}</span></template>
      <template #cell(speed)="data">{{ fillUnits(eventVelocity(data.item)) | formatDistance }}</template>
      <template #cell(distance)="data">{{ fillUnits(eventDistance(data.item)) | formatDistanceTrim
      }}</template>

      <template #cell(entrants)="data"><span v-if="data.item.placements && data.item.placements.overall">{{
        data.item.placements.overall.of }}</span></template>
      <template #cell(place)="data"><span v-if="data.item.placements && data.item.placements.overall">
          <span :class="prHighlightClass(data.item.placements.overall.place, 'place')">{{
            data.item.placements.overall.place }} </span>
          <span v-if="data.item.placements.overall.of" class="placement-partition-size">
            / {{ data.item.placements.overall.of }}</span></span></template>
      <template #cell(pct)="data"><span v-if="data.item.placements && data.item.placements.overall"
          :class="prHighlightClass(data.item.placements.overall.percentile, 'pct')">{{
            data.item.placements.overall.percentile | percent(1)
          }}</span></template>
      <template #cell(placeGender)="data"><span v-if="data.item.placements && data.item.placements.gender">
          <span :class="prHighlightClass(data.item.placements.gender.place, 'placeGender')">{{
            data.item.placements.gender.place }}</span>
          <span v-if="data.item.placements.gender.of" class="placement-partition-size">
            / {{ data.item.placements.gender.of }}</span></span></template>
      <template #cell(pctGender)="data"><span v-if="data.item.placements &&
        data.item.placements.gender &&
        data.item.placements.gender.percentile != null
        " :class="prHighlightClass(data.item.placements.gender.percentile, 'pctGender')">{{
    data.item.placements.gender.percentile | percent(1) }}</span></template>
      <template #cell(placeDivision)="data"><span v-if="data.item.placements && data.item.placements.division">
          <span :class="prHighlightClass(data.item.placements.division.place, 'placeDivision')">{{
            data.item.placements.division.place }}</span>
          <span v-if="data.item.placements.division.of" class="placement-partition-size">
            / {{ data.item.placements.division.of }}</span></span></template>
      <template #cell(pctDivision)="data"><span v-if="data.item.placements &&
        data.item.placements.division &&
        data.item.placements.division.percentile != null
        " :class="prHighlightClass(data.item.placements.division.percentile, 'pctDivision')">{{
    data.item.placements.division.percentile | percent(1) }}</span></template>

      <template #cell(frMinimum)="data"><span v-if="data.item.fundraising"
          :class="prHighlightClass(data.item.fundraising.minimum, 'frMinimum')">{{
            data.item.fundraising.minimum | currency
          }}</span></template>
      <template #cell(frReceived)="data"><span v-if="data.item.fundraising"
          :class="prHighlightClass(data.item.fundraising.received, 'frReceived')">{{
            data.item.fundraising.received | currency
          }}</span></template>
      <template #cell(frPct)="data"><span v-if="data.item.fundraising"
          :class="prHighlightClass(data.item.fundraising.received / data.item.fundraising.minimum, 'frPct')">{{
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
import EventUtils from "@/mixins/events/Util.js";
import { activityRate, convertUnitValue } from "@/utils/unitConversion.js";

import Countdown from "@/components/Countdown.vue";

export default {
  mixins: [UnitConversion, EventFilters, EventUtils],
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
    },
    showActivityDistance: {
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
      if (key == "registrationNumber") {
        t = "num";
        a = a.registrationNumber || 0;
        b = b.registrationNumber || 0;
      }
      if (key == "registrationFee") {
        t = "num";
        a = a.registrationFee || 0;
        b = b.registrationFee || 0;
      }
      if (key == "distance") {
        t = "num";
        let aa = this.eventDistance(a);
        a = convertUnitValue(
          aa.value,
          this.getUnitOfMeasure(aa.unitOfMeasureID)
        );
        let ba = this.eventDistance(b);
        b = convertUnitValue(
          ba.value,
          this.getUnitOfMeasure(ba.unitOfMeasureID)
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
    eventDistance: function (e) {
      if (this.showActivityDistance && e.activity) return e.activity.distance
      return (e.eventActivity ?? e.activity).distance
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
    prHighlightClass: function (v, label, variant = 'text-success') {
      if (v == this.personalRecords[label]) return ["font-weight-bold", variant];
      return [];
    }
  },
  computed: {
    ...mapGetters("meta", ["getUnitOfMeasure", "getUnitsOfMeasure"]),

    showFooter: function () {
      return this.events.length > 1;
    },
    eventYears: function () {
      return [...new Set(this.events.map(e => DateTime.fromISO(e.eventActivity.scheduledStart).year))]
    },
    personalRecords: function () {
      let events = this.events;
      let pr = {};
      pr.place = Math.min(
        ...events
          .filter((e) => e.placements)
          .map((e) => e.placements.overall.place)
          .filter((p) => p != null));
      pr.pct = Math.max(
        ...events
          .filter((e) => e.placements)
          .map((e) => e.placements.overall.percentile));
      pr.placeGender = Math.min(
        ...events
          .filter((e) => e.placements && e.placements.gender)
          .map((e) => e.placements.gender.place)
          .filter((p) => p != null));
      pr.pctGender = Math.max(
        ...events
          .filter((e) => e.placements && e.placements.gender)
          .map((e) => e.placements.gender.percentile));
      pr.placeDivision = Math.min(
        ...events
          .filter((e) => e.placements && e.placements.division)
          .map((e) => e.placements.division.place)
          .filter((p) => p != null))
      pr.pctDivision = Math.max(
        ...events
          .filter((e) => e.placements && e.placements.division)
          .map((e) => e.placements.division.percentile))
      pr.registrationFee = Math.max(
        ...events
          .map((e) => e.registrationFee)
      )
      pr.frMinimum = Math.max(
        ...events
          .filter((e) => e.fundraising != null)
          .map((e) => e.fundraising.minimum)
      )
      pr.frReceived = Math.max(
        ...events
          .filter((e) => e.fundraising != null)
          .map((e) => e.fundraising.received)
      )
      pr.frPct = Math.max(
        ...events
          .filter((e) => e.fundraising != null)
          .map((e) => e.fundraising.received / e.fundraising.minimum)
      )
      return pr;
    },
    totals: function () {
      let events = this.events;
      let t = {};

      t.distance = {
        value: events.map((e) => this.eventDistance(e))
          .reduce((a, c) => a + convertUnitValue(c.value, this.getUnitOfMeasure(c.unitOfMeasureID)), 0),
        units: this.getUnitsOfMeasure.find(
          (u) => u.normalUnitID == null && u.type == "Distance"
        ),
      }
      t.registrationFee = events
        .map((e) => e.registrationFee)
        .reduce((a, c) => a + (c || 0), 0)
      t.frMinimum = events
        .filter((e) => e.fundraising != null)
        .map((e) => e.fundraising.minimum)
        .reduce((a, c) => a + c, 0)
      t.frReceived = events
        .filter((e) => e.fundraising != null)
        .map((e) => e.fundraising.received)
        .reduce((a, c) => a + c, 0);
      return t;
    },
    averages: function () {
      let events = this.events;
      let avg = {};

      let fr = events.filter((e) => e.fundraising != null);
      avg.frPct = fr.map((e) => e.fundraising.received / e.fundraising.minimum).reduce((a, c) => a + c, 0) / fr.length;

      return avg;
    },
    resultsFieldOffset: function () {
      return this.fields.findIndex(f => f.key == 'place');
    },
    fields: function () {
      let self = this;
      let baseFields = [
        { key: "index", label: "", predicate: () => self.events.length > 3 },
        { key: "year", sortable: false, predicate: () => self.eventYears.length > 1 && self.separateYear },
        { key: "date", sortable: true },
        { key: "countdown", sortable: false, tdClass: "text-right pr-3", thClass: "text-right", predicate: () => Math.min(...self.events.map(e => DateTime.fromISO(e.eventActivity.scheduledStart))) > DateTime.now() },
        { key: "registrationNumber", label: "Bib #", sortable: true, predicate: () => self.events.some(e => e.registrationNumber) && !self.showFundraising },
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
