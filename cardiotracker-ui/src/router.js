import Vue from "vue";
import Router from "vue-router";
import Home from "./views/Home.vue";
import Login from "@/components/auth/Login.vue";

import Event from "./views/Event.vue";

import LegacySummary from "./views/Legacy/Summary.vue";
import LegacyEvents from "./views/Legacy/Events.vue";
import LegacyActivities from "./views/Legacy/Activities.vue";

Vue.use(Router);

let router = new Router({
  mode: "history",
  base: process.env.BASE_URL,
  routes: [
    {
      path: '/login',
      name: 'login',
      component: Login
    },
    {
      path: "/",
      name: "home",
      component: Home
    },
    {
      path: "/event/:id",
      name: "event",
      component: Event
    },
    {
      path: "/legacy/summary",
      name: "legacy_summary",
      component: LegacySummary
    },
    {
      path: "/legacy/events",
      name: "legacy_events",
      component: LegacyEvents
    },
    {
      path: "/legacy/activities",
      name: "legacy_activities",
      component: LegacyActivities
    }
  ]
});

export default router;
