import Vue from "vue";
import Router from "vue-router";
import store from "@/store";
import Home from "@/views/Home.vue";
import Login from "@/components/auth/Login.vue";

import User from "@/views/User.vue";

import Workouts from "@/views/Workouts.vue";
import WorkoutList from "@/views/workouts/List.vue";
import WorkoutEdit from "@/views/workouts/Edit.vue";
import Workout from "@/views/Workout.vue";
import Activities from "@/views/Activities.vue";
import Activity from "@/views/Activity.vue";
import ActivityList from "@/views/activities/List.vue";
import ActivitySummary from "@/views/activities/Summary.vue";

import Events from "@/views/Events.vue";
import Event from "@/views/Event.vue";
import Goals from "@/views/Goals.vue";
import Goal from "@/views/Goal.vue";

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
      path: "/user/:user/events",
      name: 'events',
      component: Events,
      props: true
    },
    {
      path: "/user/:user/event/sequence/:sequence_id",
      name: 'sequence',
      component: Events
    },
    {
      path: "/user/:user/event/:id",
      name: "event",
      component: Event
    },
    {
      path: "/user/:user/goals",
      name: "goals",
      component: Goals,
      props: true
    },
    {
      path: "/user/:user/goal/:id",
      name: "goal",
      component: Goal
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
