<template>
  <div>
    <b-table sticky-header="500px" :items="donations" :fields="fields" :sort-compare="sortCompare" sort-by="date">
      <template #cell(date)="data">{{ data.value | luxon({ input: { zone: "local" }, output: "DD" }) }}</template>
      <template #cell(amount)="data">{{ data.value | currency }}</template>
      <template #cell(event)="data"><b-link @click="$emit('selectEvent', data.value)">{{ data.value | eventName
      }}</b-link></template>
      <template #cell(person)="data"><b-link @click="$emit('selectDonor', data.value)">{{ data.value | personName
      }}</b-link></template>
    </b-table>
    <legend class="text-right pr-2">Total: {{ total | currency }}</legend>
  </div>
</template>

<script>
export default {
  props: {
    donations: {
      type: Array,
      required: true
    },
    contextKey: {
      type: String,
      default: "event"
    }
  },
  filters: {
    eventName: function (v) {
      let str = `${v.eventYear} ${v.eventName}`
      if (v.eventActivityName)
        str += ` (${v.eventActivityName})`;
      return str;
    },
    personName: function (v, fl = true) {
      if (fl) return `${v.firstname} ${v.lastname}`
      return `${v.lastname}, ${v.firstname}`
    },
  },
  computed: {
    fields: function () {
      return [{ key: "date", sortable: true }, { key: this.contextKey, sortable: true }, { key: "amount", sortable: true }]
    },
    total: function () {
      return this.donations.reduce((a, c) => a + Number.parseFloat(c.amount), 0)
    },

  },
  methods: {
    sortCompare: function (a, b, key, sortDesc, formatterFn, options, locale) {
      switch (key) {
        case 'amount': console.log(key); return a[key] - b[key];
        case 'event': return this.$options.filters.eventName(a[key]).localeCompare(this.$options.filters.eventName(b[key]), locale, options);
        case 'person': return this.$options.filters.personName(a[key], false).localeCompare(this.$options.filters.personName(b[key], false), locale, options)
        default: return a[key].localeCompare(b[key], locale, options)
      }
    }
  }
}
</script>

<style></style>