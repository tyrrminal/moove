import Vue from "vue";
import Router from "vue-router";
Vue.use(Router);

import Home from "@/views/Home.vue";
import Login from "@/components/auth/Login.vue";

import UserSummary from "@/views/user/Summary.vue";

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
import EventDetail from "@/views/events/Detail.vue";
import EventEdit from "@/views/events/Edit.vue";
import EventSearch from "@/views/events/Search";
import Registrations from "@/views/events/registrations/Base.vue";
import RegistrationList from "@/views/events/registrations/List.vue";
import RegistrationDetail from "@/views/events/registrations/Detail.vue";
import RegistrationEdit from "@/views/events/registrations/Edit.vue";
import RegistrationSeries from "@/views/events/registrations/Series.vue";

import Goals from "@/views/goals/Base.vue";
import GoalList from "@/views/goals/List.vue";
import Goal from "@/views/goals/Detail.vue";

import ErrorNotFound from "@/error/NotFound.vue";

let router = new Router({
  mode: "history",
  base: process.env.BASE_URL,
  routes: [
    { path: "/", name: "home", component: Home },
    { path: "/login", name: "login", component: Login },
    { path: "/summary/:username", name: "user", component: UserSummary },
    {
      path: "/workouts", component: Workouts, children: [
        { path: "", name: "workouts", component: WorkoutList },
        { path: "new", name: "create-workout", component: WorkoutEdit, props: false },
        { path: 'edit/:id', name: 'edit-workout', component: WorkoutEdit, props: true },
        { path: ":id", name: "workout", component: Workout, props: true },
      ]
    },
    {
      path: "/activities", component: Activities, children: [
        { path: "", name: "activities", component: ActivityList, props: true, },
        { path: "new", name: "create-activity", component: ActivityEdit, props: true },
        { path: "edit/:id", name: "edit-activity", component: ActivityEdit, props: true },
        { path: "summary", name: "activitiesSummary", component: ActivitySummary },
        { path: "slice", name: "activitiesSlice", component: ActivitySlice },
        { path: "import", name: "importActivities", component: ActivityImport, },
        { path: ":id", name: "activity", component: Activity, props: true },
      ]
    },
    {
      path: "/events", name: "events", component: Events, children: [
        { path: "search", name: "event-search", component: EventSearch, props: false },
        { path: "new", name: "event-create", component: EventEdit, props: true },
        { path: "edit/:id", name: "event-edit", component: EventEdit, props: true },
        { path: ":id", name: 'event-detail', component: EventDetail, props: true, },
      ]
    },
    {
      path: "/user/events", component: Registrations, children: [
        { path: "", name: 'registrations', component: RegistrationList, props: true },
        { path: "new", name: "registration-new", component: RegistrationEdit, props: true },
        { path: "edit/:id", name: "registration-edit", component: RegistrationEdit, props: true },
        { path: "series/:id", name: "registration-series", component: RegistrationSeries, props: true },
        { path: ":id", name: "registration-detail", component: RegistrationDetail, props: true },
      ]
    },
    {
      path: "/goals", component: Goals, children: [
        { path: "", name: "goals", component: GoalList, props: true },
        { path: ":id", name: "goal", component: Goal },
      ]
    },
    { path: "*", name: "errorNotFound", component: ErrorNotFound }
  ]
});

export default router;
