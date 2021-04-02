import Vue from "vue";
import Router from "vue-router";
import store from "@/store";
import Home from "@/views/Home.vue";
import Login from "@/components/auth/Login.vue";

import User from "@/views/User.vue";

import Workouts from "@/views/workouts/Base.vue";
import WorkoutList from "@/views/workouts/List.vue";
import WorkoutEdit from "@/views/workouts/Edit.vue";
import Workout from "@/views/workouts/Detail.vue";

import Activities from "@/views/activities/Base.vue";
import Activity from "@/views/activities/Detail.vue";
import ActivityList from "@/views/activities/List.vue";
import ActivitySummary from "@/views/activities/Summary.vue";

import Events from "@/views/events/Base.vue";
import EventList from "@/views/events/List.vue";
import Event from "@/views/events/Detail.vue";

import Goals from "@/views/goals/Base.vue";
import GoalList from "@/views/goals/List.vue";
import Goal from "@/views/goals/Detail.vue";

import ErrorNotFound from "@/error/NotFound.vue";

Vue.use(Router);
Vue.use(require("vue-moment"));

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
      path: "/user/:user",
      name: "user",
      component: User
    },
    {
      path: "/workouts",
      component: Workouts,
      children: [
        {
          path: "",
          name: "workouts",
          component: WorkoutList,
        },
        {
          path: "create",
          name: "createWorkout",
          component: WorkoutEdit,
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
          path: "",
          name: "activities",
          component: ActivityList,
          props: true,
        },
        {
          path: "summary",
          name: "activitiesSummary",
          component: ActivitySummary
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
      component: Events,
      children: [
        {
          path: "",
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
      ]
    },
    {
      path: "/goals",
      component: Goals,
      children: [
        {
          path: "",
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
      name: "error_not_found",
      component: ErrorNotFound
    }
  ]
});

router.beforeEach((to, from, next) => {
  let exp = store.getters["auth/expiration"];
  if (exp.diff(Vue.moment()) < 0) {
    store.dispatch("auth/logout").then(() => next());
  }

  if (store.getters["auth/status"] === "")
    store.dispatch("auth/check").then(() => next());
  else next();
});

router.beforeEach((to, from, next) => {
  if (!store.getters["meta/isLoaded"])
    store.dispatch("meta/initialize");
  next();
});

export default router;
