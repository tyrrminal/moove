<template>
  <b-jumbotron class="event-details py-2" border-variant="secondary">
    <h4>
      <b-link
        v-if="linkToActivity"
        :to="{ name: 'activity', params: { id: activity.id } }"
        >{{ activityType.description }}
      </b-link>
      <span v-else>{{ activityType.description }}</span>
    </h4>
    <ActivityResultSingle
      v-if="singleActivity"
      :activity="activity"
      :editable="editable"
    />
    <ActivityResultMulti v-else :activity="activity" :editable="editable" />
  </b-jumbotron>
</template>

<script>
import { mapGetters } from "vuex";
import ActivityResultSingle from "@/components/activity/cards/Result/Single";
import ActivityResultMulti from "@/components/activity/cards/Result/Multiple";

export default {
  components: {
    ActivityResultSingle,
    ActivityResultMulti,
  },
  props: {
    activity: {
      type: Object,
      required: true,
    },
    linkToActivity: {
      type: Boolean,
      default: true,
    },
    editable: {
      type: Boolean,
      default: true,
    },
  },
  computed: {
    ...mapGetters("meta", ["getActivityType"]),
    sets: function () {
      if (this.activity.sets) return this.activity.sets;
      else return [this.activity];
    },
    singleActivity: function () {
      return this.sets.length == 1;
    },
    activityType: function () {
      return this.getActivityType(
        this.activity.activityTypeID || this.activity.activityType.id
      );
    },
  },
};
</script>

<style scoped></style>
