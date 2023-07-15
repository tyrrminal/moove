<template>
  <div :style="{ height: height }">
    <LineChartGenerator id="fundraising-chart" :options="options" :data="chartData" />
  </div>
</template>

<script>
import { Line as LineChartGenerator } from 'vue-chartjs';
import annotationPlugin from 'chartjs-plugin-annotation';
import 'chartjs-adapter-luxon';

import { Chart as ChartJS, Title, Tooltip, Legend, TimeScale, PointElement, LineElement, Filler } from 'chart.js';
import { DateTime } from 'luxon';
ChartJS.register(Title, Tooltip, Legend, TimeScale, PointElement, LineElement, Filler, annotationPlugin);

export default {
  props: {
    data: {
      type: Object,
      required: true
    },
    height: {
      type: String,
      default: '16em'
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
        onClick: function (evt, elements) {
          if (elements.length > 0)
            self.$emit('selectDonor', elements[0].element.$context.raw.context.person)
        },
        datasets: {
          line: {
            stepped: 'before'
          }
        },
        scales: {
          x: {
            type: 'time',
            suggestedMin: self.data.from,
            max: self.data.to,
            ticks: {
              autoSkip: true,
              maxTicksLimit: 20
            },
            time: {
              unit: 'day',
              unitStepSize: 1,
              displayFormats: {
                'day': 'MM/d/yyyy'
              },
              tooltipFormat: "MMM d, yyyy"
            }
          },
          y: {
            ticks: {
              callback: function (value, index, ticks) {
                return self.$options.filters.currency(value)
              }
            }
          }
        },
        plugins: {
          legend: false,
          tooltip: {
            callbacks: {
              title: function (ctx) {
                return ctx[0].label
              },
              beforeBody: function (ctx) {
                return ctx[0].raw.context.person.firstname + " " + ctx[0].raw.context.person.lastname
              },
              label: function (ctx) {
                return self.$options.filters.currency(ctx.raw.context.amount)
              },
              footer: function (ctx) {
                return 'TTD: ' + self.$options.filters.currency(ctx[0].parsed.y)
              }
            }
          },
          annotation: {
            annotations: {
              line: {
                type: 'line',
                yMin: this.data.minimum,
                yMax: this.data.minimum,
                borderWidth: 1,
                borderColor: 'green'
              }
            }
          }
        }
      }
    },
    chartData: function () {
      let sum = 0;
      let donations = this.data.donations;
      donations.sort((a, b) => a.date.localeCompare(b.date))

      let data = [...this.data.donations];
      data.push({ amount: 0, date: DateTime.fromISO(this.data.to).plus({ years: 1 }).toISODate(), person: { id: 0, firstname: '', lastname: '' } });

      data = data.map(a => ({ x: a.date, y: sum += a.amount, context: { person: a.person, amount: a.amount } }));


      return {
        datasets: [
          { fill: 'start', data: data, backgroundColor: 'rgba(218, 131, 44, 0.5)', datalabels: { display: false }, datalabels: { display: false } },
        ]
      }
    },
  },
}
</script>

<style>
</style>
