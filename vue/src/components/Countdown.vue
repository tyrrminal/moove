<template>
  <span v-show="isInFuture">{{ relativeDate }}</span>
</template>

<script>
import { DateTime } from 'luxon';

export default {
  props: {
    to: {
      type: String,
      required: true
    }
  },
  data: function () {
    return {
      now: DateTime.now()
    }
  },
  mounted() {
    setInterval(() => {
      this.now = DateTime.now();
    }, 1000);
  },
  computed: {
    date: function () {
      return DateTime.fromISO(this.to)
    },
    isInFuture: function () {
      return this.date > this.now;
    },
    relativeDate: function () {
      let dur = this.date.startOf('day').diff(this.now.startOf('day'), ["weeks", "days"]);
      let p = [];
      if (dur.weeks) p.push(dur.weeks + 'w');
      if (dur.days) p.push(dur.days + 'd');

      if (!p.length) {
        dur = this.date.diff(this.now, ["hours", "minutes"]);
        if (dur.hours) p.push(dur.hours + 'h')
        if (dur.minutes) p.push(Math.round(dur.minutes) + 'm')
      }
      return p.join(' ');
    }
  }
}
</script>

<style></style>