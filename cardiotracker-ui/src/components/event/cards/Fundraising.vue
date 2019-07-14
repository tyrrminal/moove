<template>
  <b-card title="Donations" class="fundraising">
    <b-list-group flush>
      <b-list-group-item><label>Required</label>: ${{ fundraising.minimum }}</b-list-group-item>
      <b-list-group-item><label>Raised</label>: ${{ fundraising.total }}</b-list-group-item>
      <b-list-group-item>{{ fundraising.donations.map(d => d.person.first_name + "&nbsp;" + d.person.last_name).join(", ") }}</b-list-group-item>
    </b-list-group>
  </b-card>
</template>

<script>
export default {
  props: {
    fundraising: Object
  }
}
</script>

<style>

</style>
