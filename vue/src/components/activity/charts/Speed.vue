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
import zoomPlugin from 'chartjs-plugin-zoom';
import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, TimeScale, LinearScale, PointElement, LineElement } from 'chart.js';
ChartJS.register(Title, Tooltip, Legend, BarElement, TimeScale, LinearScale, PointElement, LineElement, zoomPlugin);

import paceSpeed from "@/mixins/activities/paceSpeed.js"
import timeCharts from "@/mixins/activities/timeCharts.js";
import { DateTime } from 'luxon';

export default {
  name: "ActivityAnnualChart",
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
        scales: {
          x: {
            type: 'time',
            ...self.timeScaleRange,
            time: {
              unit: self.timeScaleUnit,
              unitStepSize: 1,
              displayFormats: self.timeScaleFormat,
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
          zoom: {
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
      let gapConfig = {
        spanGaps: true,
        segment: {
          borderColor: ctx => ctx.p0.skip || ctx.p1.skip ? 'gray' : undefined,
          borderDash: ctx => ctx.p0.skip || ctx.p1.skip ? [6, 6] : undefined,
          borderWidth: ctx => ctx.p0.skip || ctx.p1.skip ? 2 : undefined,
        },
      };
      return {
        datasets: [{
          data: this.addYearGaps(this.data.map(e => {
            let v = e ? e[this.velocityType.toLowerCase()].value : null;
            return { x: DateTime.fromISO(e.startTime), y: this.getNumericVelocity(v), v: v };
          })),
          label: this.velocityType, backgroundColor: this.speedChartBackgroundColor, borderColor: this.speedChartBorderColor, ...gapConfig,
        }]
      }
    },
  },
}
</script>
