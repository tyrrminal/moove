<template>
  <b-container>
    <b-jumbotron border-variant="info" class="mt-5">
      <vue-headful title="Moo've" />
      <template #header>Moo've</template>

      <template #lead>{{ byLine }}</template>

      <hr />

      <p>{{ featureBlurb }}</p>
      <DisclosureCard v-for="f in features" :key="f.name" 
        :title="f.title" 
        :items="f.items"
        :name="f.name"
      />
    </b-jumbotron>
  </b-container>
</template>

<script>
import DisclosureCard from '@/components/home/DisclosureCard.vue';

export default {
  components: {
    DisclosureCard
  },
  data() {
    return {
      byLine: "A cardio activity tracker from Digital Cow Software",
      featureBlurb: "Moo've provides standard activity tracking capabilities, but then takes it further by adding:",
      features: [
        {
          title: 'Event Scheduling',
          items: [
            'See countdowns for upcoming activities',
            'Get reminders for registration',
            'Report on annual registration expenses'
          ],
          name: 'event-tracking'
        }, {
          title: 'Performance Metrics', 
          items: [
            'Configurable PR tracking (distances, pace, milage over days/weeks/months)',
            'Time since last PR',
            'Official vs unofficial PRs'
          ], 
          name: "performance-metrics"
        },{
          title: 'Event Placement Metrics',
          items: [
            'Compare Race results to previous races (absolute and relative placements)',
            'Translate results into other hypothetical divisions'
          ],
          name: 'event-metrics'
        }, {
          title: 'Training Plans',
          items: [
            'Build and subscribe to training plans',
            'Monitor conformance'
          ],
          name: 'training-plans'
        }, {
          title: 'Calendar',
          items: [
            'See completed activities',
            'See past and future registered events',
            'See training plan schedules in a grid or list calendar'
          ],
          name: 'scheduling-calendar'
        }, {
          title: 'Fundraising & Donor/Donation Tracking',
          items: [
            'View fundraising progress for active campaigns',
            'See lifetime charity contribution',
            'Analyze historical donor activity'
          ],
          name: 'fundraising-donations'
        }
      ]
    }
  }
};
</script>
