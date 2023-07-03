<template>
  <div>
    <b-row>
      <b-col cols="2">
        <b-button-group class="mr-2 bg-white" size="sm">
          <b-button variant="outline-primary" @click="ordinalMode = true" :pressed="ordinalMode">Ordinal</b-button>
          <b-button variant="outline-primary" @click="ordinalMode = false" :pressed="!ordinalMode">Percentile</b-button>
        </b-button-group>
      </b-col>

      <b-col cols="3">
        <div>Placements:</div>
        <b-checkbox v-model="show.overall" size="sm" class="d-inline-block mr-2">Overall</b-checkbox>
        <b-checkbox v-model="show.gender" size="sm" class="d-inline-block mr-2">Gender</b-checkbox>
        <b-checkbox v-model="show.division" size="sm" class="d-inline-block">Division</b-checkbox>
      </b-col>

      <b-col>
        <div>Compare:</div>
        <b-radio-group size="sm" :options="additionalDataOptions" v-model="additionalDataSelection" />
      </b-col>
    </b-row>
    <hr />
    <div :style="{ height: height }" class="mx-1">
      <LineChartGenerator id="results-chart" :options="options" :data="chartData" />
    </div>
  </div>
</template>

<script>
import { Line as LineChartGenerator } from 'vue-chartjs';

import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, TimeScale, PointElement, LineElement, Filler } from 'chart.js';
import 'chartjs-adapter-luxon';
ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, TimeScale, PointElement, LineElement, Filler);

import paceSpeed from "@/mixins/activities/paceSpeed.js";

export default {
  props: {
    data: {
      type: Array,
      required: true
    },
    height: {
      type: String,
      default: '16em'
    }
  },
  mixins: [paceSpeed],
  components: {
    LineChartGenerator
  },
  data: function () {
    return {
      ordinalMode: true,
      additionalDataSelection: 'field',
      show: {
        overall: true,
        gender: true,
        division: true
      }
    }
  },
  computed: {
    additionalDataOptions: function () {
      return [
        { text: 'None', value: false },
        { text: 'Field Size', value: 'field' },
        { text: this.velocityType, value: 'speed' }
      ]
    },
    options: function () {
      let self = this;

      let primaryAxis = {};
      let additionalAxis = {};

      if (this.ordinalMode)
        primaryAxis = {
          placement: {
            reverse: true,
            min: 1,
            ticks: {
              precision: 0
            },
          }
        };
      else
        primaryAxis = {
          percentage: {
            stacked: false,
            max: 1,
            ticks: {
              callback: function (value, index, ticks) {
                return self.$options.filters.percent(value)
              }
            }
          }
        };

      if (this.additionalDataSelection == 'field')
        additionalAxis = {
          field: {
            grid: {
              display: false
            },
            position: 'right',
          }
        };
      else if (this.additionalDataSelection == 'speed')
        additionalAxis = {
          speed: {
            position: 'right',
            grid: {
              display: false
            },
            reverse: this.velocityType.toLocaleLowerCase() == 'pace',
            ticks: {
              callback: function (value, index, ticks) {
                return self.formatSpeedTicks(value)
              }
            }
          }
        };

      return {
        responsive: true,
        maintainAspectRatio: false,
        parsing: {

        },
        scales: {
          x: {
            type: 'time',
            time: {
              tooltipFormat: 'yyyy'
            },
            ticks: {
              callback: function (value, index, ticks) {
                return value;
              }
            },
          },
          ...primaryAxis,
          ...additionalAxis,
        },
        plugins: {
          tooltip: {
            callbacks: {
              title: function () { return null },
              label: function (context) {
                if (context.dataset.yAxisID == 'percentage') {
                  return `${context.dataset.label} percentile: ${self.$options.filters.percent(context.formattedValue, 1)}`
                }
                if (context.dataset.yAxisID == 'speed')
                  return self.formatSpeedTooltips(context)
              }
            }
          },
          legend: {
            labels: {
              filter: function (item, chart) {
                return !item.text.match(/Field/);
              }
            }
          },
        }
      }
    },
    chartData: function () {
      let labels = this.data.map(e => e.year);
      labels.sort();
      let data = [];
      let stacks = ['-1', '-1', 'end'];
      let t = this.velocityType.toLocaleLowerCase();
      if (this.additionalDataSelection == 'field') {
        if (this.show.overall) data.push({ label: "Overall Field", type: 'bar', data: this.data.map(e => ({ x: e.year, y: e.overall.of })), yAxisID: 'field' });
        if (this.show.gender) data.push({ label: "Gender Field", type: 'bar', data: this.data.map(e => ({ x: e.year, y: e.gender.of })), yAxisID: 'field', backgroundColor: 'rgba(212, 38, 209, 0.45)' });
        if (this.show.division) data.push({ label: "Division Field", type: 'bar', data: this.data.map(e => ({ x: e.year, y: e.division.of })), yAxisID: 'field', backgroundColor: 'rgba(1, 184, 71, 0.45)' });
      } else if (this.additionalDataSelection == 'speed') {
        data.push({ label: this.velocityType, data: this.data.map(e => ({ x: e.year, y: this.getNumericVelocity(e[t].value), v: e[t].value })), yAxisID: 'speed', backgroundColor: this.speedChartBackgroundColor, borderColor: this.speedChartBorderColor })
      }

      if (this.ordinalMode) {
        if (this.show.division) data.push({ label: 'Division', data: this.data.map(e => ({ x: e.year, y: e.division.place })), yAxisID: 'placement', borderColor: 'rgba(171, 255, 172, 0.66)', backgroundColor: 'rgba(1, 184, 71, 0.66)', fill: stacks.pop() });
        if (this.show.gender) data.push({ label: 'Gender', data: this.data.map(e => ({ x: e.year, y: e.gender.place })), yAxisID: 'placement', borderColor: 'rgba(255, 185, 246, 0.66)', backgroundColor: 'rgba(212, 38, 209, 0.66)', fill: stacks.pop() });
        if (this.show.overall) data.push({ label: 'Overall', data: this.data.map(e => ({ x: e.year, y: e.overall.place })), yAxisID: 'placement', fill: stacks.pop() });
      } else {
        if (this.show.overall) data.push({ label: 'Overall', data: this.data.map(e => ({ x: e.year, y: e.overall.percentile })), yAxisID: 'percentage', fill: false })
        if (this.show.gender) data.push({ label: 'Gender', data: this.data.map(e => ({ x: e.year, y: e.gender.percentile })), yAxisID: 'percentage', orderColor: 'rgba(255, 185, 246, 0.66)', backgroundColor: 'rgba(212, 38, 209, 0.66)', fill: false })
        if (this.show.division) data.push({ label: 'Division', data: this.data.map(e => ({ x: e.year, y: e.division.percentile })), yAxisID: 'percentage', borderColor: 'rgba(171, 255, 172, 0.66)', backgroundColor: 'rgba(1, 184, 71, 0.66)', fill: false })
      }
      return {
        labels: labels,
        datasets: data
      }
    }
  }
}
</script>
