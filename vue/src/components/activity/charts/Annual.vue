<template>
  <div :style="{ height: height }">
    <LineChartGenerator id="activity-chart" :options="options" :data="chartData" />
  </div>
</template>

<script>
/*
activityType: {
  id
  description
  hasDistance
  hasDuration
  hasMap
  hasRepeats
  hasSpeed
  labels: {
    base
    context
  }
}
unitOfMeasure: {
  id
  abbreviation
  name
  inverted
  normalUnitID
  normalizationFactor
  type
}
activity: {
  startTime
  distance: {
    unitOfMeasureID
    value
  }
  duration
  hasMap
  heartRate
  netTime
  pace: {
    unitOfMeasureID
    value
  }
  temperature
  weight
  year
}
*/

import { Line as LineChartGenerator } from 'vue-chartjs';

import 'chartjs-adapter-luxon';
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, TimeScale, LinearScale, PointElement, LineElement } from 'chart.js';
ChartJS.register(Title, Tooltip, Legend, BarElement, TimeScale, LinearScale, PointElement, LineElement);

import paceSpeed from "@/mixins/activities/paceSpeed.js"
import { DateTime } from 'luxon';

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
  computed: {
    dataValues: function () {
      return this.data.map(activity => this.getNumericVelocity(activity[this.velocityType.toLowerCase()].value))
    },
    suggestedMax: function () {
      let min = Math.min(...this.dataValues);
      let max = Math.max(...this.dataValues)
      if (this.velocityType.toLocaleLowerCase() == 'speed') {
        if (max - min <= 1.5) return max + 2;
      }
      else null;
    },
    suggestedMin: function () {
      let min = Math.min(...this.dataValues);
      let max = Math.max(...this.dataValues)
      if (this.velocityType.toLocaleLowerCase() == 'speed') {
        if (max - min <= 1.5) return max - 1;
      }
      else null;
    },
    options: function () {
      let self = this;
      return {
        responsive: true,
        maintainAspectRatio: false,
        parsing: {
          // yAxisKey: 'y'
        },
        scales: {
          x: {
            type: 'time',
            time: {
              unit: 'year',
              unitStepSize: 1,
              displayFormats: {
                'year': 'yyyy'
              },
              tooltipFormat: "MMM d, yyyy"
            }
          },
          y: {
            suggestedMax: this.suggestedMax,
            suggestedMin: this.suggestedMin,
            reverse: this.velocityType.toLocaleLowerCase() == 'pace',
            ticks: {
              callback: function (value, index, ticks) {
                return self.formatSpeedTicks(value)
              }
            }
          }
        },
        plugins: {
          datalabels: { display: false },
          legend: {
            labels: {
              filter: function (item, chart) {
                return !!item.text;
              }
            }
          },
          tooltip: {
            callbacks: {
              label: function (context) {
                return self.formatSpeedTooltips(context)
              }
            }
          }
        }
      }
    },
    chartData: function () {
      return {
        labels: this.dataYears,
        datasets: [{
          data: this.dataYears.map(d => {
            let e = this.data.find(e => DateTime.fromISO(e.startTime).year == DateTime.fromISO(d).year);
            let v = e ? e[this.velocityType.toLowerCase()].value : null;
            return { x: d, y: this.getNumericVelocity(v), v: v };
          }), spanGaps: true, label: this.velocityType, backgroundColor: this.speedChartBackgroundColor, borderColor: this.speedChartBorderColor,
          segment: {
            borderColor: ctx => ctx.p0.parsed.y == null || ctx.p1.parsed.y == null ? 'gray' : undefined,
            borderDash: ctx => ctx.p0.parsed.y == null || ctx.p1.parsed.y == null ? [6, 6] : undefined,
            borderWidth: ctx => ctx.p0.parsed.y == null || ctx.p1.parsed.y == null ? 2 : undefined,
          }
        }]
      }
    },
  },
}
</script>
