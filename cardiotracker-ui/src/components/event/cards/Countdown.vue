<template>
  <b-card title="Countdown">
    <b-list-group flush>
      <b-list-group-item>{{ event.countdown.days }} days</b-list-group-item>
      <b-list-group-item>{{ event.countdown.weeks }} weeks</b-list-group-item>
      <b-list-group-item>{{ event.countdown.months }} months</b-list-group-item>
    </b-list-group>
  </b-card>
</template>

<script>
export default {
  props: {
    event: Object
  }
}
</script>

<style>

</style>
