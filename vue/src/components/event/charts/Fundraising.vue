<template>
  <div :style="{ height: height }">
    <BarChartGenerator id="fundraising-chart" :options="options" :data="chartData" />
  </div>
</template>

<script>
import { Bar as BarChartGenerator } from 'vue-chartjs';

import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  BarElement,
  CategoryScale,
  LinearScale
} from 'chart.js'
ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale)


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
  components: {
    BarChartGenerator
  },
  computed: {
    options: function () {
      let self = this;
      return {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          dollar: {
            ticks: {
              callback: function (value, index, ticks) {
                return self.$options.filters.currency(value)
              }
            }
          },
          percentage: {
            grid: {
              display: false
            },
            position: 'right',
            ticks: {
              callback: function (value, index, ticks) {
                return self.$options.filters.percent(value)
              }
            }
          }
        },
        plugins: {
          tooltip: {
            callbacks: {
              title: function () {
                return null
              },
              label: function (context) {
                console.log(context);
                return context.raw.tooltip
              }
            }
          }
        }
      }
    },
    chartData: function () {
      let labels = this.data.map(e => e.year);
      labels.sort();
      return {
        labels: labels,
        datasets: [
          { label: 'Raised', data: this.data.map(e => ({ x: e.year, y: e.received, tooltip: this.$options.filters.currency(e.received) })), backgroundColor: '#a757e8', yAxisID: 'dollar' },
          { label: '% of Goal', data: this.data.map(e => ({ x: e.year, y: e.received / e.minimum, tooltip: this.$options.filters.percent(e.received / e.minimum) })), backgroundColor: '#5592d8', yAxisID: 'percentage', barThickness: 8, }
        ]
      }
    }
  }
}
</script>