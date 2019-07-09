<template>
  <b-container v-if="event">
    <b-row>
      <b-col sm="9" md="7" lg="5" class="mx-auto">
        <b-card :title="event.event.name" :sub-title="event.event.distance.value.value + ' ' + event.event.distance.value.units.abbreviation + ' ' + event.event.event_type.description" class="mb-2" bg-variant="dark" text-variant="white">
          <h6 slot="footer">{{ event.event.scheduled_start | moment("M/D/YY h:mma") }} &mdash; {{ event.event.address.city }}, {{ event.event.address.state }}</h6>
        </b-card>
      </b-col>
    </b-row>

    <b-row v-if="event.event.countdown && event.registration.hasOwnProperty('registered')">
      <b-col>
        <h5 :class="event.registration.registered === true ? 'registered' : 'notregistered' ">Registered</h5>
      </b-col>
    </b-row>

    <b-row>
      <b-col v-if="event.event.countdown" sm="12">
        <b-card title="Countdown">
          <b-list-group flush>
            <b-list-group-item>{{ event.event.countdown.days }} days</b-list-group-item>
            <b-list-group-item>{{ event.event.countdown.weeks }} weeks</b-list-group-item>
            <b-list-group-item>{{ event.event.countdown.months }} months</b-list-group-item>
          </b-list-group>
        </b-card>
      </b-col>

      <b-col v-if="event.activity" sm="4">
        <b-card title="Activity" class="activity">
          <b-list-group flush>
            <b-list-group-item><label>Actual distance</label>: {{ event.activity.distance.value.value }} {{ event.activity.distance.value.units.abbreviation }}</b-list-group-item>
            <b-list-group-item><label>Moving Time</label>: {{ event.activity.result.net_time }}</b-list-group-item>
            <b-list-group-item v-if="event.activity.result.gross_time"><label>Total Time</label>: {{ event.activity.result.gross_time }}</b-list-group-item>
            <b-list-group-item v-if="event.activity.activity_type.description === 'Run'"><label>Pace</label>: {{ event.activity.result.pace }}</b-list-group-item>
            <b-list-group-item v-else><label>Speed</label>: {{ Number(event.activity.result.speed.value).toFixed(2) }} {{ event.activity.result.speed.units.abbreviation }}</b-list-group-item>
            <b-list-group-item v-if="event.activity.temperature"><label>Temperature</label>: {{ event.activity.temperature }}&deg;F</b-list-group-item>
          </b-list-group>
        </b-card>
      </b-col>

      <b-col v-if="event.results" sm="4">
        <b-card title="Results" class="event-results">
          <b-list-group flush>
            <b-list-group-item v-for="(r,index) in event.results" :key="`result-${index}`">
              <label>{{ r | eventResultLabel }}</label>: {{ r.place }}/{{ r.finishers }} ({{ 100-Number(r.percentile).toFixed(1) }}%)
            </b-list-group-item>
          </b-list-group>
        </b-card>
      </b-col>

      <b-col v-if="event.registration.fundraising" sm="6">
        <b-card title="Donations" class="fundraising">
          <b-list-group flush>
            <b-list-group-item><label>Required</label>: ${{ event.registration.fundraising.minimum }}</b-list-group-item>
            <b-list-group-item><label>Raised</label>: ${{ event.registration.fundraising.total }}</b-list-group-item>
            <b-list-group-item>{{ event.registration.fundraising.donations.map(d => d.person.first_name + "&nbsp;" + d.person.last_name).join(", ") }}</b-list-group-item>
          </b-list-group>
        </b-card>
      </b-col>
    </b-row>

  </b-container>
</template>

<script>
export default {
  data() {
    return {
      event: null
    }
  },
  created() {
    let self = this;
    this.$http.get("event/" + self.user.id + "/" + this.$route.params.id).then(response => {
      self.event = response.data
    });
  },  
  computed: {
    user: function() {
      var c = this.$cookie.get('cardiotracker');
      if(!c)
        return null;
      return JSON.parse(atob(c));
    }
  },
  filters: {
    eventResultLabel: function(v) {
      if(v.division)
        return v.division;
      if(v.gender)
        return v.gender;
      return 'Overall';
    }
  }
}
</script>

<style scoped>
.registered {
  color: green;
  font-weight: bold;
}
.registered::before {
  content: "\2713 ";
}
.notregistered {
  color: red;
  font-weight: bold
}
.notregistered::before {
  content: "\2716 ";
}

.activity label {
  width: 8rem;
  text-align: right;
}

.event-results label {
  width: 4rem;
  text-align: right;
}

</style>
