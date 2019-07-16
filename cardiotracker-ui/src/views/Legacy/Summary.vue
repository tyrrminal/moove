<template>
  <div class="container">
    <vue-headful title="Moo've / Summary[Legacy]" />

    <div class="row">
      <div class="col-3">
        <h4>Overall</h4>
        <h5>Since Start</h5>
        {{ summary.overall.since_start.days }} days<br />
        {{ summary.overall.since_start.years | deci }} years
        <h5>Total Distance</h5>
        {{ summary.overall.since_start.distance | deci }} miles
        <h5>Event Distance</h5>
        {{ summary.overall.since_start.event_distance | deci }} miles
        <hr />
        <h4>{{ current_year }}</h4>
        Day {{ summary.overall.ytd.days }}/{{ summary.overall.ytd.days_of }} ({{
          ((100 * summary.overall.ytd.days) / summary.overall.ytd.days_of)
            | deci
        }}%)
        <template v-for="t in activity_types">
          <h5>{{ t }}</h5>
          {{
            (summary.activities.years[current_year][t]["distance"] -
              summary.goals[t])
              | deci
              | signedNumber
          }}
          mi ({{
            (-100 +
              (100 * summary.activities.years[current_year][t]["distance"]) /
                summary.goals[t])
              | deci
          }}%)
        </template>
      </div>
      <div class="col-9">
        <vue-ads-table :columns="columns" :rows="rows"></vue-ads-table>
      </div>
    </div>
  </div>
</template>

<script>
import { VueAdsTable } from "vue-ads-table-tree";

import "vue-ads-table-tree/dist/vue-ads-table-tree.css";
import "@fortawesome/fontawesome-free/css/all.css";

export default {
  components: {
    VueAdsTable
  },
  data() {
    return {
      activity_types: ["Run", "Ride"],
      columns: [
        {
          property: "timePeriod",
          title: "Year",
          filtrable: false,
          collapseIcon: true
        },
        {
          property: "runs",
          title: "Runs"
        },
        {
          property: "runDistance",
          title: "Run Distance"
        },
        {
          property: "runAverage",
          title: "Run Avg"
        },
        {
          property: "rides",
          title: "Rides"
        },
        {
          property: "rideDistance",
          title: "Ride Distance"
        },
        {
          property: "rideAverage",
          title: "Ride Avg"
        }
      ],
      rows: [],
      classes: {},
      summary: {
        overall: {
          since_start: {},
          ytd: {}
        },
        activities: {
          years: {}
        },
        goals: {}
      }
    };
  },
  filters: {
    deci: function(value, digits = 2) {
      return Number(value).toFixed(digits);
    },
    signedNumber: function(value) {
      if (value > 0) {
        return "+" + value;
      }
      return value;
    }
  },
  computed: {
    current_year: function() {
      return new Date().getFullYear();
    }
  },
  created() {
    this.$http.get("/legacy/summary/"+"digicow").then(response => {
      this.summary = response.data;
      let activities = response.data.activities;
      for (var k in activities["years"]) {
        let row_year = k;
        let y = activities["years"][k];
        let r = {
          _id: k,
          timePeriod: k,
          runs: y.Run.count,
          runDistance: Number(y.Run.distance).toFixed(2),
          runAverage: Number(y.Run.distance / y.Run.count).toFixed(2),
          rides: y.Ride.count,
          rideDistance: Number(y.Ride.distance).toFixed(2),
          rideAverage: Number(y.Ride.distance / y.Ride.count).toFixed(2),
          _children: [],
          _showChildren: row_year == this.current_year,
          _classes: {
            row: {
              "ct-year-row": true
            }
          }
        };
        this.rows.push(r);
        for (k in y["quarters"]) {
          let q = y["quarters"][k];
          let r2 = {
            _id: k,
            timePeriod: k,
            runs: q.Run ? q.Run.count : null,
            runDistance: q.Run ? Number(q.Run.distance).toFixed(2) : null,
            runAverage: q.Run
              ? Number(q.Run.distance / q.Run.count).toFixed(2)
              : null,
            rides: q.Ride ? q.Ride.count : null,
            rideDistance: q.Ride ? Number(q.Ride.distance).toFixed(2) : null,
            rideAverage: q.Ride
              ? Number(q.Ride.distance / q.Ride.count).toFixed(2)
              : null,
            _children: [],
            _showChildren: row_year == this.current_year,
            _classes: {
              row: {
                "ct-qtr-row": true
              }
            }
          };
          r._children.push(r2);
          for (k in q["months"]) {
            let m = q["months"][k];
            let r3 = {
              _id: k,
              timePeriod: k,
              runs: m.Run ? m.Run.count : null,
              runDistance: m.Run ? Number(m.Run.distance).toFixed(2) : null,
              runAverage: m.Run
                ? Number(m.Run.distance / m.Run.count).toFixed(2)
                : null,
              rides: m.Ride ? m.Ride.count : null,
              rideDistance: m.Ride ? Number(m.Ride.distance).toFixed(2) : null,
              rideAverage: m.Ride
                ? Number(m.Ride.distance / m.Ride.count).toFixed(2)
                : null,
              _classes: {
                row: {
                  "ct-month-row": true
                }
              }
            };
            r2._children.push(r3);
          }
        }
      }
      this.rows.push({
        _id: "overall",
        timePeriod: "Overall",
        runs: activities["Run"]["count"],
        runDistance: Number(activities["Run"]["distance"]).toFixed(2),
        rides: activities["Ride"]["count"],
        rideDistance: Number(activities["Ride"]["distance"]).toFixed(2),
        _classes: {
          row: {
            "ct-summary-row": true
          }
        }
      });
    });
  }
};
</script>

<style scoped>
.ct-summary-table {
  color: blue;
}
.ct-summary-row {
  border-top: 2px solid black;
  font-weight: bold;
}
.ct-year-row {
  border-top: 2px solid black;
}
.ct-qtr-row {
  border-top: 1px solid black;
}
.ct-month-row {
  color: gray;
}
table {
  margin-bottom: 2em;
}
table td {
  font-family: "Lucida Console", Monaco, monospace !important;
  font-size: 0.7rem !important;
  line-height: 0.6;
}
</style>
