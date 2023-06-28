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

import { DateTime } from "luxon";

import { Line as LineChartGenerator } from 'vue-chartjs';

import { Chart as ChartJS, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, PointElement, LineElement } from 'chart.js';
ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, PointElement, LineElement);

import { hmsToHours, minutesToHms } from "@/utils/unitConversion.js";

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
    LineChartGenerator
  },
  computed: {
    velocityType: function () {
      if (!this.$store.getters["meta/isLoaded"]) return 'Speed';
      return this.data.some(a => this.getActivityType(a.activityTypeID).hasSpeed) ? 'Speed' : 'Pace'
    },
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
                if (self.velocityType.toLocaleLowerCase() == 'pace')
                  return minutesToHms(value).replace(/^00:/, '')
                else
                  return `${value} mph`
              }
            }
          }
        },
        plugins: {
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
                if (self.velocityType.toLocaleLowerCase() == 'speed') return `Speed: ${context.parsed.y.toFixed(2)} mph`;
                return `Pace: ${context.raw.v.replace(/^00:0?/, '')} /mi`;
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
      let labels = [];
      let activity;
      let data = [];
      let set = [];
      for (let i = start; i <= end; i++) {
        labels.push(i);
        activity = this.data.find(a => a.year == i);
        if (activity == null) {
          if (set.filter(s => s != null).length)
            data.push({ data: set, label: legendLabels.pop(), backgroundColor: '#bde8ff', borderColor: '#88c6ff' });
          set = [];
        } else {
          let v = activity[this.velocityType.toLowerCase()].value
          set.push({ x: i, y: this.getNumericVelocity(v), v: v })
        }
      }
      if (set.filter(s => s != null).length)
        data.push({ data: set, label: legendLabels.pop(), backgroundColor: '#bde8ff', borderColor: '#88c6ff' });
      return {
        labels: labels,
        datasets: data
      }
    },
  },
  methods: {
    getNumericVelocity: function (v) {
      if (this.velocityType.toLocaleLowerCase() == 'speed') return v;
      return hmsToHours(v) * 60;
    },
    getActivityType: function (id) {
      return this.$store.getters["meta/getActivityType"](id);
    },
  }
}
</script>