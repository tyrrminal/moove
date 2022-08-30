import Vue from "vue";
import Router from "vue-router";
Vue.use(Router);

import Home from "@/views/Home.vue";
import Login from "@/components/auth/Login.vue";

import User from "@/views/User.vue";

import Workouts from "@/views/workouts/Base.vue";
import WorkoutList from "@/views/workouts/List.vue";
import Workout from "@/views/workouts/Detail.vue";
import WorkoutEdit from "@/views/workouts/Edit.vue";

import Activities from "@/views/activities/Base.vue";
import Activity from "@/views/activities/Detail.vue";
import ActivityList from "@/views/activities/List.vue";
import ActivityEdit from "@/views/activities/Edit.vue";
import ActivitySlice from "@/views/activities/Slice.vue";
import ActivitySummary from "@/views/activities/Summary.vue";
import ActivityImport from "@/views/activities/Import.vue";

import Events from "@/views/events/Base.vue";
import EventList from "@/views/events/List.vue";
import Event from "@/views/events/Detail.vue";
import EventGroup from "@/views/events/Group.vue";
import EventAdd from "@/views/events/Add.vue";
import EventEdit from "@/views/events/Edit.vue";

import Goals from "@/views/goals/Base.vue";
import GoalList from "@/views/goals/List.vue";
import Goal from "@/views/goals/Detail.vue";

import ErrorNotFound from "@/error/NotFound.vue";

let router = new Router({
  mode: "history",
  base: process.env.BASE_URL,
  routes: [
    {
      path: "/login",
      name: "login",
      component: Login
    },
    {
      path: "/",
      name: "home",
      component: Home
    },
    {
      path: "/user/:username",
      name: "user",
      component: User
    },
    {
      path: "/workouts",
      component: Workouts,
      children: [
        {
          path: "/user/:username/workouts",
          name: "workouts",
          component: WorkoutList,
        },
        {
          path: "new",
          name: "create-workout",
          component: WorkoutEdit,
          props: false
        },
        {
          path: '/edit/:id',
          name: 'edit-workout',
          component: WorkoutEdit,
          props: true,
        },
        {
          path: ":id",
          name: "workout",
          component: Workout,
          props: true
        },
      ]
    },
    {
      path: "/activities",
      component: Activities,
      children: [
        {
          path: "/user/:username/activities",
          name: "activities",
          component: ActivityList,
          props: (route) => ({ start: route.query.start, end: route.query.end, activityTypeID: route.query.activityTypeID }),
        },
        {
          path: "new",
          name: "create-activity",
          component: ActivityEdit,
          props: true
        },
        {
          path: "edit/:id",
          name: "edit-activity",
          component: ActivityEdit,
          props: true
        },
        {
          path: "/user/:username/activities/summary",
          name: "activitiesSummary",
          component: ActivitySummary
        },
        {
          path: "/user/:username/activities/slice",
          name: "activitiesSlice",
          component: ActivitySlice
        }, {
          path: "import",
          name: "importActivities",
          component: ActivityImport,
        },
        {
          path: ":id",
          name: "activity",
          component: Activity,
          props: true
        },
      ]
    },
    {
      path: "/events",
      component: GEvents,
      children: [
        {
          path: "add",
          name: "create-event",
          component: EventAdd,
          props: true
        },
        {
          path: ":id",
          name: 'event-detail',
          component: EventDetail,
          props: true,
        },
        {
          path: "edit/:id",
          name: "edit-event",
          component: EventEdit,
          props: true
        }
      ]
    },
    {
      path: "/user/events",
      component: Events,
      children: [
        {
          path: ":username",
          name: 'events',
          component: EventList,
          props: true
        },
        {
          path: ":id",
          name: "event",
          component: Event,
          props: true
        },
        {
          path: ":id/edit",
          name: "edit-registration",
          component: EditRegistration,
          props: true
        },
        {
          path: "series/:id",
          name: "event-group",
          component: EventGroup,
          props: true
        }
      ]
    },
    {
      path: "/goals",
      component: Goals,
      children: [
        {
          path: "/user/:username/goals",
          name: "goals",
          component: GoalList,
          props: true
        },
        {
          path: ":id",
          name: "goal",
          component: Goal
        },
      ]
    },
    {
      path: "*",
      name: "errorNotFound",
      component: ErrorNotFound
    }
  ]
});

export default router;
