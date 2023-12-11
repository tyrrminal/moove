<template>
  <div>
    <b-row align-h="between">
      <b-col cols="2">
        <b-button-group class="mr-2 bg-white" size="sm">
          <b-button variant="outline-primary" @click="ordinalMode = true" :pressed="ordinalMode">Ordinal</b-button>
          <b-button variant="outline-primary" @click="ordinalMode = false" :pressed="!ordinalMode">Percentile</b-button>
        </b-button-group>
      </b-col>

      <b-col cols="4">
        <b-checkbox switch v-model="show.overall" size="sm" class="d-inline-block mr-2">Overall</b-checkbox>
        <b-checkbox switch v-model="show.gender" size="sm" class="d-inline-block mr-2">Gender</b-checkbox>
        <b-checkbox switch v-model="show.division" size="sm" class="d-inline-block">Division</b-checkbox>
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
import { DateTime } from 'luxon';
import 'chartjs-adapter-luxon';
import zoomPlugin from 'chartjs-plugin-zoom';
ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, TimeScale, PointElement, LineElement, Filler, zoomPlugin);

import paceSpeed from "@/mixins/activities/paceSpeed.js";
import timeCharts from "@/mixins/activities/timeCharts.js";

export default {
  name: "EventResultsChart",
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
  mixins: [paceSpeed, timeCharts],
  components: {
    LineChartGenerator
  },
  data: function () {
    return {
      ordinalMode: true,
      additionalDataSelection: 'speed',
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
        // { text: 'Field Size', value: 'field' },
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
            ...self.timeScaleRange,
            time: {
              unit: self.timeScaleUnit,
              unitStepSize: 1,
              displayFormats: self.timeScaleFormat,
              tooltipFormat: 'yyyy-mm-dd'
            },
          },
          ...primaryAxis,
          ...additionalAxis,
        },
        plugins: {
          zoom: {
            limits: {
              y: { min: this.ordinalMode ? 1 : null }
            },
            pan: {
              enabled: true,
              mode: 'xy',
            },
            zoom: {
              wheel: {
                enabled: true,
              },
              pinch: {
                enabled: true
              },
              mode: 'xy',
            }
          },
          datalabels: { display: false },
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
    bgColors: function () {
      return {
        pace: this.speedChartBackgroundColor,
        overall: null,
        gender: 'rgba(212, 38, 209, 0.66)',
        division: 'rgba(1, 184, 71, 0.66)',
      }
    },
    borderColors: function () {
      return {
        pace: this.speedChartBorderColor,
        overall: null,
        gender: 'rgba(255, 185, 246, 0.66)',
        division: 'rgba(171, 215, 172, 0.9)',
      }
    },
    chartData: function () {
      let gapConfig = {
        spanGaps: true,
        segment: { borderDash: ctx => { return ctx.p0.skip || ctx.p1.skip ? [6, 6] : undefined } }
      };
      let labels = this.sortedData.map(e => e.year);
      labels.sort();
      let data = [];
      let stacks = ['-1', '-1', 'end'];
      let t = this.velocityType.toLocaleLowerCase();
      // if (this.additionalDataSelection == 'field') {
      //   if (this.show.overall) data.push({ label: "Overall Field", type: 'bar', data: this.sortedData.map(e => ({ x: DateTime.fromISO(e.startTime), y: e.overall.of })), yAxisID: 'field' });
      //   if (this.show.gender) data.push({ label: "Gender Field", type: 'bar', data: this.sortedData.map(e => ({ x: DateTime.fromISO(e.startTime), y: e.gender.of })), yAxisID: 'field', backgroundColor: 'rgba(212, 38, 209, 0.45)' });
      //   if (this.show.division) data.push({ label: "Division Field", type: 'bar', data: this.sortedData.map(e => ({ x: DateTime.fromISO(e.startTime), y: e.division.of })), yAxisID: 'field', backgroundColor: 'rgba(1, 184, 71, 0.45)' });
      // } else if (this.additionalDataSelection == 'speed') {
      data.push({ label: this.velocityType, data: this.sortedData.map(e => ({ x: DateTime.fromISO(e.startTime), y: this.getNumericVelocity(e[t].value), v: e[t].value })), yAxisID: 'speed', backgroundColor: this.speedChartBackgroundColor, borderColor: this.speedChartBorderColor, ...gapConfig })
      // }

      if (this.ordinalMode) {
        if (this.show.overall) data.push({ label: 'Overall', data: this.sortedData.map(e => ({ x: DateTime.fromISO(e.startTime), y: e.overall.place })), yAxisID: 'placement', fill: stacks.pop(), spanGaps: true, ...gapConfig });
        if (this.show.gender) data.push({ label: 'Gender', data: this.sortedData.map(e => ({ x: DateTime.fromISO(e.startTime), y: e.gender.place })), yAxisID: 'placement', borderColor: this.borderColors.gender, backgroundColor: this.bgColors.gender, fill: stacks.pop(), spanGaps: true, ...gapConfig });
        if (this.show.division) data.push({ label: 'Division', data: this.sortedData.map(e => ({ x: DateTime.fromISO(e.startTime), y: e.division.place })), yAxisID: 'placement', borderColor: this.borderColors.division, backgroundColor: this.bgColors.division, fill: stacks.pop(), spanGaps: true, ...gapConfig });
      } else {
        if (this.show.overall) data.push({ label: 'Overall', data: this.sortedData.map(e => ({ x: DateTime.fromISO(e.startTime), y: e.overall.percentile })), yAxisID: 'percentage', fill: false, spanGaps: true, ...gapConfig })
        if (this.show.gender) data.push({ label: 'Gender', data: this.sortedData.map(e => ({ x: DateTime.fromISO(e.startTime), y: e.gender.percentile })), yAxisID: 'percentage', borderColor: this.borderColors.gender, backgroundColor: this.bgColors.gender, fill: false, spanGaps: true, ...gapConfig })
        if (this.show.division) data.push({ label: 'Division', data: this.sortedData.map(e => ({ x: DateTime.fromISO(e.startTime), y: e.division.percentile })), yAxisID: 'percentage', borderColor: this.borderColors.division, backgroundColor: this.bgColors.division, fill: false, spanGaps: true, ...gapConfig })
      }

      data.forEach(ds => {
        ds.data = this.addYearGaps(ds.data);
      });
      return {
        labels: labels,
        datasets: data
      }
    }
  },
}
</script>
