<template>
  <b-row class="text-center">
    <template v-if="registration.bib_no">
      <b-col>
        <h4 class="bib_no">{{ participantName }} #{{ registration.bib_no }}</h4>
      </b-col>
    </template>
    
    <template v-else-if="isInFuture && registration.hasOwnProperty('registered')">
      <b-col>
        <h5 v-if="registration.registered" class="registered"><font-awesome-icon icon="check" /> Registered</h5>
        <h5 v-else class="notregistered"><font-awesome-icon icon="times" /> Registered</h5>
      </b-col>
    </template>
  </b-row>
</template>

<script>
export default {
  props: {
    registration: Object,
    isInFuture: Boolean
  },
  computed: {
    participantName: function() {
      return this.registration.user.person.first_name + " " + this.registration.user.person.last_name;
    }
  }
}
</script>

<style scoped>
.registered {
  color: green;
  font-weight: bold;
}
.notregistered {
  color: red;
  font-weight: bold
}
</style>
