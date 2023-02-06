<template>
  <div>
    <b-input-group>
      <b-input v-model="datetime" :debounce="1000" :size="size"></b-input>
      <b-input-group-append>
        <b-datepicker v-model="date" button-only dropright today-button :size="size" :button-variant="buttonVariant">
        </b-datepicker>
        <b-timepicker v-model="time" button-only now-button no-close-button :size="size"
          :button-variant="buttonVariant">
        </b-timepicker>
      </b-input-group-append>
    </b-input-group>
  </div>
</template>

<script>
import { DateTime } from "luxon";

export default {
  props: {
    value: {
      type: String,
      default: ""
    },
    size: {
      type: String,
      default: 'md'
    },
    buttonVariant: {
      type: String,
      default: "primary"
    },
  },
  data: function () {
    return {
      stringValue: null
    }
  },
  methods: {
    parse: function (str) {
      let v = DateTime.fromFormat(str, "L/dd/yyyy, h:mm a");
      return v;
    },
    update: function (v) {
      this.stringValue = v.toISO();
      this.$emit('input', this.stringValue);
    }
  },
  computed: {
    dt: function () {
      return DateTime.fromISO(this.stringValue)
    },
    datetime: {
      get: function () {
        return this.dt.toLocaleString(DateTime.DATETIME_SHORT);
      },
      set: function (newValue) {
        this.update(this.parse(newValue));
      }
    },
    date: {
      get: function () {
        return this.dt.toISODate()
      },
      set: function (newValue) {
        let [yr, mn, dy] = newValue.split("-");
        let dt = this.dt;
        if (dt.invalid) dt = DateTime.now().startOf('day')
        this.update(dt.set({ year: yr, month: mn, day: dy }));
      }
    },
    time: {
      get: function () {
        return this.dt.toFormat('TT');
      },
      set: function (newValue) {
        let [hr, min, sec] = newValue.split(":");
        let dt = this.dt
        if (dt.invalid) dt = DateTime.now()
        this.update(dt.set({ hour: hr, minute: min, second: sec }));
      }
    }
  },
  watch: {
    value: {
      immediate: true,
      handler: function (newValue) {
        this.stringValue = DateTime.fromISO(newValue).toISO();
      }
    }
  }
}
</script>

<style scoped>

</style> 