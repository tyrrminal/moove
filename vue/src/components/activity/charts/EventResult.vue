<template>
  <div :style="{ height: height }">
    <LineChartGenerator id="event-result-chart" :options="options" :data="chartData" />
  </div>
</template>

<script>
import { Line as LineChartGenerator } from 'vue-chartjs';

import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, TimeScale, PointElement, LineElement, Filler } from 'chart.js';
import ChartDataLabels from 'chartjs-plugin-datalabels';
import 'chartjs-adapter-luxon';
ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, TimeScale, PointElement, LineElement, Filler, ChartDataLabels);

let pattern = require('patternomaly');

export default {
  props: {
    data: {
      type: Array,
      required: true
    },
    height: {
      type: String,
      default: '16rem'
    }
  },
  components: {
    LineChartGenerator
  },
  computed: {
    options: function () {
      let self = this;
      return {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          count: {
            grid: {
              display: false
            }
          },
          percent: {
            max: 1,
            position: 'right',
            grid: {
              display: true
            },
            ticks: {
              callback: function (value, index, ticks) {
                return self.$options.filters.percent(value)
              }
            }
          }
        },
        plugins: {
          legend: false,
          tooltip: {
            callbacks: {
              footer: function (ctx) {
                if (ctx[0].dataset.yAxisID == 'percent') {
                  return `Place: ${ctx[0].raw.place} / ${ctx[0].raw.of}`
                }
              }
            }
          }
        }
      }
    },
    chartData: function () {
      let self = this;
      let cfl = this.capitalizeFirstLetter;
      let mkLabel = function (p) {
        let str = p.description;
        if (p.partitionType) str = `By ${cfl(p.partitionType)} (${str})`
        return str;
      };
      return {
        labels: this.data.map(p => mkLabel(p)),
        datasets: [
          { label: 'Field', data: this.data.map(p => p.of), type: 'bar', barPercentage: 0.2, backgroundColor: 'rgb(145, 32, 160)', yAxisID: 'count', datalabels: { display: false } },
          {
            label: 'Placement', data: this.data.map(p => ({ x: mkLabel(p), y: (1 - ((p.place - 1) / (p.of - 1))), ...p })), type: 'bar',
            borderWidth: 1,
            backgroundColor: this.data.map(p => this.barColor(p.place, p.of)),
            borderColor: this.data.map(p => this.borderColor(p.place, p.of)),
            yAxisID: 'percent',
            tooltip: {
              callbacks: {
                label: function (ctx) {
                  return self.$options.filters.percent(ctx.parsed.y, 1)
                },
              }
            },
            datalabels: {
              font: { weight: 'bold' },
              color: this.data.map(p => this.barLabelColor(p.place, p.of)),
              formatter: function (value, context) {
                return self.$options.filters.percent(value.y, 1)
              }
            }
          }

        ]
      }
    }
  },
  methods: {
    capitalizeFirstLetter: function (string) {
      return string.charAt(0).toUpperCase() + string.slice(1);
    },
    barLabelColor: function (place, of) {
      if (place <= 3) return 'white';
      return 'black'
    },
    barColor: function (place, of) {
      let pct = place / of;
      if (place <= 3) return pattern.draw('diagonal-right-left', 'rgba(0, 175, 6, 0.75)', 'rgba(17, 129, 8, 0.75)')
      if (pct < 0.2) return 'rgba(0, 175, 6, 0.75)';
      if (pct < 0.5) return 'rgba(255, 237, 74, 0.75)';
      return 'rgba(238, 166, 166, 0.75)'
    },
    borderColor: function (place, of) {
      let pct = place / of;
      if (pct < 0.2) return 'rgba(0, 175, 6, 1)';
      if (pct < 0.5) return 'rgba(255, 237, 74, 1)';
      return 'rgba(255, 162, 162, 1)'
    }
  }
}
</script>
