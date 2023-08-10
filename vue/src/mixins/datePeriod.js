import { DateTime } from "luxon";

export default {
  methods: {
    cacheKey: function (startDate = this.date, period = this.period) {
      if (!period) return 'overall';
      return `${startDate}/${period}`
    },
    periodStart: function (period) {
      if (!period) return null;
      const basis = DateTime.fromISO(this.date);
      let psd;
      if (period == 'week') {
        psd = basis
          .startOf('week')
          .plus({ week: basis.weekdayShort === 'Sun' ? 1 : 0 })
          .minus({ day: 1 })
      } else
        psd = basis.startOf(period);
      return psd.toISODate()
    },
    periodEnd: function (period) {
      let psd = DateTime.fromISO(this.periodStart(period));
      let nextPeriod = {};
      nextPeriod[`${period}s`] = 1;
      let ped = psd.plus(nextPeriod).minus({ days: 1 })
      return ped.toISODate();
    }
  }

}
