<template>
  <b-jumbotron class="event-details py-2" border-variant="secondary">
    <h4 v-if="isLoaded">
      <b-link v-if="linkToActivity" :to="{ name: 'activity', params: { id: activity.id } }">{{ cardTitle }}
      </b-link>
      <b-link v-else-if="isEventActivity"
        :to="{ name: 'registration-detail', params: { id: activity.userEventActivity.id } }">{{ cardTitle }}</b-link>
      <span v-else>{{ cardTitle }}</span>
    </h4>
    <ActivityResultSingle v-if="singleActivity" :activity="activity" :eventResult="activity2">
      <template v-for="(_, slot) of $scopedSlots" v-slot:[slot]="scope">
        <slot :name="slot" v-bind="scope" />
      </template>
    </ActivityResultSingle>
    <ActivityResultMulti v-else :activity="activity">
      <template v-for="(_, slot) of $scopedSlots" v-slot:[slot]="scope">
        <slot :name="slot" v-bind="scope" />
      </template>
    </ActivityResultMulti>
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
    title: {
      type: String,
      default: null,
    },
    activity: {
      type: Object,
      required: true,
    },
    activity2: {
      type: Object,
      required: false
    },
    linkToActivity: {
      type: Boolean,
      default: true,
    },
  },
  computed: {
    ...mapGetters("meta", ["isLoaded", "getActivityType"]),
    cardTitle: function () {
      if (this.title != null) return this.title;
      if (this.isEventActivity) return this.activity.userEventActivity.name
      return this.activityType.description;
    },
    isEventActivity: function () {
      return this.activity.userEventActivity != null
    },
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
