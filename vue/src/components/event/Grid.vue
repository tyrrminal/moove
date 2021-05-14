<template>
  <b-table
    striped
    small
    hover
    :items="events"
    :fields="fields"
    :sort-compare="sortCompare"
    foot-clone
    no-footer-sorting
  >
    <template v-slot:table-busy>
      <div class="text-center text-info my-2">
        <b-spinner class="align-middle"></b-spinner>
        <strong>Loading...</strong>
      </div>
    </template>

    <template v-slot:thead-top="data" v-if="viewType == 1">
      <b-tr :title="data">
        <b-th colspan="4">
          <span class="sr-only">Default Fields</span>
        </b-th>
        <b-th colspan="2" class="text-center">Overall</b-th>
        <b-th colspan="2" class="text-center">Gender</b-th>
        <b-th colspan="2" class="text-center">Division</b-th>
      </b-tr>
    </template>

    <template #foot()><span></span></template>
    <template #foot(date)
      ><span v-if="viewType == 0 || viewType == 2">Total</span>
      <span v-else>Best</span></template
    >
    <template #foot(fee)>
      {{
        events.map((e) => e.fee).reduce((a, c) => a + (c || 0), 0) | currency
      }}
    </template>
    <template #foot(distance)
      ><span v-if="events.length">
        {{
          events.map((e) => fillUnits(e.eventActivity.distance))
            | distanceSum
            | formatDistance
        }}
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
    <template v-slot:cell(date)="data">{{
      data.item.eventActivity.scheduledStart | moment("M/D/YY h:mma")
    }}</template>
    <template v-slot:cell(type)="data">{{
      data.item.eventActivity.eventType.description
    }}</template>
    <template v-slot:cell(name)="data">
      <b-link
        :class="eventNameClass(data.item)"
        :to="{
          name: 'event',
          params: { id: data.item.id },
        }"
        >{{ data.item.eventActivity.event.name }}</b-link
      >
    </template>
    <template v-slot:cell(fee)="data">
      {{ data.item.fee | currency }}
    </template>
    <template v-slot:cell(speed)="data"
      ><span v-if="data.item.activity">{{
        fillUnits(eventVelocity(data.item)) | formatDistance
      }}</span>
    </template>
    <template v-slot:cell(distance)="data">{{
      fillUnits(
        data.item.activity != null
          ? data.item.activity.distance
          : data.item.eventActivity.distance
      ) | formatDistance
    }}</template>

    <template v-slot:cell(place)="data"
      ><span v-if="data.item.placements && data.item.placements.overall">{{
        data.item.placements.overall.place
      }}</span></template
    >
    <template v-slot:cell(pct)="data"
      ><span v-if="data.item.placements && data.item.placements.overall">{{
        data.item.placements.overall.percentile | percent(1)
      }}</span></template
    >
    <template v-slot:cell(placeGender)="data"
      ><span v-if="data.item.placements && data.item.placements.gender">{{
        data.item.placements.gender.place
      }}</span></template
    >
    <template v-slot:cell(pctGender)="data"
      ><span v-if="data.item.placements && data.item.placements.gender">{{
        data.item.placements.gender.percentile | percent(1)
      }}</span></template
    >
    <template v-slot:cell(placeDivision)="data"
      ><span v-if="data.item.placements && data.item.placements.division">{{
        data.item.placements.division.place
      }}</span></template
    >
    <template v-slot:cell(pctDivision)="data"
      ><span v-if="data.item.placements && data.item.placements.division"
        ><span v-if="data.item.placements.division.percentile != null">{{
          data.item.placements.division.percentile | percent(1)
        }}</span></span
      ></template
    >

    <template v-slot:cell(frMinimum)="data"
      ><span v-if="data.item.fundraising">{{
        data.item.fundraising.minimum | currency
      }}</span></template
    >
    <template v-slot:cell(frReceived)="data"
      ><span v-if="data.item.fundraising">{{
        data.item.fundraising.received | currency
      }}</span></template
    >
    <template v-slot:cell(frPct)="data"
      ><span v-if="data.item.fundraising">{{
        (data.item.fundraising.received / data.item.fundraising.minimum)
          | percent(1)
      }}</span></template
    >
  </b-table>
</template>

<script>
import UnitConversion from "@/mixins/UnitConversion.js";
import { mapGetters } from "vuex";
import EventFilters from "@/mixins/events/Filters.js";

export default {
  mixins: [UnitConversion, EventFilters],
  props: {
    events: {
      type: Array,
      required: true,
    },
    viewType: {
      type: Number,
      default: 0,
    },
  },
  data: function () {
    return {
      baseFields: [
        { key: "index", label: "" },
        { key: "date", sortable: true },
        { key: "name", sortable: true },
        { key: "type", sortable: true },
        {
          key: "fee",
          sortable: true,
          show: { performance: true, fundraising: true },
        },
        { key: "distance", sortable: true, show: { performance: true } },
        { key: "speed", sortable: true, show: { performance: true } },
        {
          key: "place",
          sortable: true,
          label: "Place",
          show: { results: true },
        },
        { key: "pct", sortable: true, label: "%", show: { results: true } },
        {
          key: "placeGender",
          sortable: true,
          label: "Place",
          show: { results: true },
        },
        {
          key: "pctGender",
          sortable: true,
          label: "%",
          show: { results: true },
        },
        {
          key: "placeDivision",
          sortable: true,
          label: "Place",
          show: { results: true },
        },
        {
          key: "pctDivision",
          sortable: true,
          label: "%",
          show: { results: true },
        },
        {
          key: "frMinimum",
          sortable: true,
          label: "Minimum",
          tdClass: "text-right pr-2",
          thClass: "ncol",
          show: { fundraising: true },
        },
        {
          key: "frReceived",
          sortable: true,
          label: "Recieved",
          tdClass: "text-right pr-2",
          thClass: "ncol",
          show: { fundraising: true },
        },
        {
          key: "frPct",
          sortable: true,
          label: "%",
          tdClass: "text-right pr-2",
          thClass: "ncol",
          show: { fundraising: true },
        },
        ,
      ],
    };
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
      if (key == "fee") {
        t = "num";
        a = a.fee || 0;
        b = b.fee || 0;
      }
      if (key == "distance") {
        t = "num";
        a =
          a.activity != null
            ? this.fillUnits(a.activity.distance).normalizedQuantity.value
            : this.fillUnits(a.eventActivity.distance).normalizedQuantity.value;
        b =
          b.activity != null
            ? this.fillUnits(b.activity.distance).normalizedQuantity.value
            : this.fillUnits(b.eventActivity.distance).normalizedQuantity.value;
      }
      if (key == "speed") {
        t = "num";
        a = this.activitySpeed(a.activity) || 0;
        b = this.activitySpeed(b.activity) || 0;
      }
      var m;
      if ((m = key.match(/(place|pct)(Division|Gender)?/))) {
        t = "num";
        // let f = m[1] == "pct" ? "percentile" : m[1];
        // let g = m[2] == null ? "overall" : m[2].toLowerCase();
        a = m; //a.placements[g][f] || Number.MAX_SAFE_INTEGER;
        b = -1; //b.placements[g][f] || Number.MAX_SAFE_INTEGER;
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
      if (e.hasOwnProperty("activity")) {
        return e.activity.pace || e.activity.speed;
      }
      return "";
    },
    eventNameClass: function (e) {
      if (e.visibilityTypeID == 1) return ["text-danger"];
      return [];
    },
    getResultsGroup: function (results, partitionType) {
      let g = results[partitionType];
      if (g == null) return { percentile: null, place: null };
      g.percentile = (100 * g.place) / g.of;
      return g;
    },
  },
  filters: {
    distanceSum: function (arr) {
      if (arr == null || arr.length == 0) return "";
      let u = arr[0].normalizedQuantity.units;
      let v = arr.reduce((a, c) => a + c.normalizedQuantity.value, 0);
      return {
        quantity: { value: v, units: u },
      };
    },
  },
  computed: {
    ...mapGetters("meta", ["getUnitOfMeasure"]),
    frPctAvg: function () {
      let fr = this.events.filter((e) => e.fundraising != null);
      return (
        fr
          .map((e) => e.fundraising.received / e.fundraising.minimum)
          .reduce((a, c) => a + c, 0) / fr.length
      );
    },
    fields: function () {
      let fields = this.baseFields.filter((f) => !f.hasOwnProperty("show"));
      if (this.viewType == 0) {
        fields.push(
          ...this.baseFields.filter((f) => f.show && f.show.performance)
        );
      }
      if (this.viewType == 1) {
        fields.push(...this.baseFields.filter((f) => f.show && f.show.results));
      }
      if (this.viewType == 2) {
        fields.push(
          ...this.baseFields.filter((f) => f.show && f.show.fundraising)
        );
      }
      return fields;
    },
  },
};
</script>

<style>
tfoot .ncol {
  text-align: right;
  padding-right: 0.5rem;
}
</style>