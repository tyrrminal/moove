<template>
  <layout-default>
    <template #sidebar>
      <SideBar :items="sidebarOps" />
    </template>

    <vue-headful title="Moo've / Events[Legacy]" />

    <h3>Upcoming</h3>
    <table class="table table-striped table-bordered">
      <thead>
      <tr>
        <th>Name</th>
        <th>Type</th>
        <th>Date</th>
        <th>Distance</th>
        <th>Days Until</th>
        <th>Weeks Until</th>
        <th>Months Until</th>
        <th>Registered</th>
        <th>Fee</th>
        <th>Fundraising</th>
      </tr>
      </thead>
      <tbody>
        <tr v-for="e in sortedFutureEvents" :key="e.event.id" :class="(e.registration.hasOwnProperty('registered') && !e.registration.registered) ? 'table-warning' : '' ">
          <td><router-link :to="{ name: 'event', params: { id: e.event.id, user: effective_user.username }}">{{ e.event.name }}</router-link></td>
          <td>{{ e.event.event_type.description }}</td>
          <td>{{ e.event.scheduled_start | moment("M/D/YY h:mma") }}</td>
          <td class="right">{{ e.event.distance | format_distance }}</td>
          <td>{{ e.event.countdown.days}}</td>
          <td>{{ e.event.countdown.weeks }}</td>
          <td>{{ e.event.countdown.months }}</td>
          <td><template v-if="e.registration.hasOwnProperty('registered')">{{ e.registration.registered ? 'Y' : 'N' }}</template></td>
          <td><template v-if="e.registration.fee !== null">{{ e.registration.fee | currency }}</template></td>
          <td><template v-if="e.registration.hasOwnProperty('fundraising')">{{ e.registration.fundraising.total | currency }}/{{ e.registration.fundraising.minimum | currency }}</template></td>
        </tr>
      </tbody>
    </table>
    <hr />
    <h3>Past</h3>
    <table class="past table table-striped table-bordered table-sm">
      <thead>
        <tr>
          <th>Name</th>
          <th>Type</th>
          <th>Date</th>
          <th>Distance (Rated)</th>
          <th>Distance (Actual)</th>
          <th>Time</th>
          <th>Pace</th>
          <th>Speed</th>
          <th>Fee</th>
          <th>Fundraising</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="e in pastEvents" class="" :key="e.event.id">
          <td><router-link :to="{ name: 'event', params: { id: e.event.id, user: effective_user.username }}">{{ e.event.name }}</router-link></td>
          <td>{{ e.event.event_type.description }}</td>
          <td>{{ e.event.scheduled_start | moment("M/D/YY h:mma") }}</td>
          <td class="right">{{ e.event.distance | format_distance }}</td>
          <template v-if="e.hasOwnProperty('activity')">
            <template v-if="e.activity.hasOwnProperty('result')">
              <td class="right">{{ e.activity.distance | format_distance }}</td>
              <td>{{ e.activity.result.net_time }}</td>
              <td><template v-if="e.activity.activity_type.description === 'Run'">{{ e.activity.result.pace }}</template></td>
              <td><template v-if="e.activity.activity_type.description !== 'Run'">{{ e.activity.result.speed | format_distance }}</template></td>
            </template>
            <template v-else>
              <td class="dnf table-danger" colspan="4"></td>
            </template>
          </template>
          <template v-else>
            <td class="dns table-warning" colspan="4"></td>
          </template>
          <td><template v-if="e.registration.fee !== null">{{ e.registration.fee | currency }}</template></td>
          <td><template v-if="e.registration.hasOwnProperty('fundraising')">{{ e.registration.fundraising.total | currency }}/{{ e.registration.fundraising.minimum | currency }}</template></td>
        </tr>
      </tbody>
    </table>
  </layout-default>
</template>

<script>
const moment = require('moment');
import LayoutDefault from '@/layouts/LayoutDefault.vue';
import SideBar from '@/components/SideBar.vue';
import '@/filters/event_filters.js';

export default {
  components: {
    LayoutDefault,
    SideBar
  },
  data() {
    return {
      user: null,
      futureEvents: [],
      pastEvents: [],
      sidebarOps: [
        { text: 'Add Event', to: { name: 'event_add' } }
      ]
    }
  },
  created() {
    let self = this;
    let now = moment();
    this.$http.get("events/" + this.effective_user.id).then(response => {
      self.futureEvents = response.data.filter(e => moment(e.event.scheduled_start).diff(now) >  0);
      self.pastEvents   = response.data.filter(e => moment(e.event.scheduled_start).diff(now) <= 0);
    });
  },
  computed: {
    effective_user: function() {
      if(this.user)
        return this.user;
      return this.$store.getters['auth/currentUser'];
    },
    sortedFutureEvents: function() {
      return this.futureEvents.slice().reverse();
    }
  }
}
</script>

<style scoped>
.dns {
  font-weight: bold;
  text-align: center;
}
.dnf {
  font-weight: bold;
  text-align: center;
}
.dns::after {
  content: "Did Not Start"
}
.dnf::after {
  content: "Did Not Finish"
}
th,td {
  white-space: nowrap;
  font-size: small;
}
td:nth-child(1),td:nth-child(2) {
  text-align: left
}
.right {
  text-align: right;
}
</style>
