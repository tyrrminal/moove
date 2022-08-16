<template>
  <b-jumbotron class="event-details py-2" border-variant="secondary">
    <h4>
      <span v-if="noLinkToActivity">{{ getActivityType(activity.activityTypeID).description }}</span>
      <b-link v-else :to="{ name: 'activity', params: { id: activity.id } }">{{
          getActivityType(activity.activityTypeID).description
      }}
      </b-link>
    </h4>
    <ActivityResultSingle v-if="activity.sets.length == 1" :activity="activity" />
    <ActivityResultMulti v-else :activity="activity" />
  </b-jumbotron>
</template>

<script>
import { mapGetters } from 'vuex';
import ActivityResultSingle from "@/components/activity/cards/Result/Single";
import ActivityResultMulti from "@/components/activity/cards/Result/Multiple";

export default {
  components: {
    ActivityResultSingle,
    ActivityResultMulti
  },
  props: {
    activity: {
      type: Object,
      required: true
    },
    noLinkToActivity: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapGetters("meta", ["getActivityType"]),
  }
};
</script>

<style scoped>
</style>
