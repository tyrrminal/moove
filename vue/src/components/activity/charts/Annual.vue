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

import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, PointElement, LineElement } from 'chart.js';
ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, PointElement, LineElement);

import paceSpeed from "@/mixins/activities/paceSpeed.js"

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
      let start = Math.min(...this.data.map(a => a.year));
      let end = Math.max(...this.data.map(a => a.year));
      let legendLabels = [this.velocityType];
      let activity;
      let data = [];
      let set = [];
      for (let i = start; i <= end; i++) {
        activity = this.data.find(a => a.year == i);
        if (activity == null) {
          if (set.filter(s => s != null).length)
            data.push({ data: set, label: legendLabels.pop(), backgroundColor: this.speedChartBackgroundColor, borderColor: this.speedChartBorderColor });
          set = [];
        } else {
          let v = activity[this.velocityType.toLowerCase()].value
          set.push({ x: i, y: this.getNumericVelocity(v), v: v })
        }
      }
      if (set.filter(s => s != null).length)
        data.push({ data: set, label: legendLabels.pop(), backgroundColor: this.speedChartBackgroundColor, borderColor: this.speedChartBorderColor });
      return {
        labels: this.dataYears,
        datasets: data
      }
    },
  },
}
</script>
