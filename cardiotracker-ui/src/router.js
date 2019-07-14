import Vue from "vue";
import Router from "vue-router";
import store from './store.js'
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
      component: Event,
      meta: {
        requiresAuth: true
      }
    },
    {
      path: "/event/:user/:id",
      name: "event_with_user",
      component: Event,
    },
    {
      path: "/legacy/summary",
      name: "legacy_summary",
      component: LegacySummary,
      meta: {
        requiresAuth: true
      }
    },
    {
      path: "/legacy/events",
      name: "legacy_events",
      component: LegacyEvents,
      meta: {
        requiresAuth: true
      }
    },
    {
      path: "/legacy/activities",
      name: "legacy_activities",
      component: LegacyActivities,
      meta: {
        requiresAuth: true
      }
    }
  ]
});

router.beforeEach((to, from, next) => {
  let next_or_login = function() {
    if(store.getters['auth/isLoggedIn'])
      next();
    else
      next({ name: 'login', query: { from: to.path }});
  };

  if(to.matched.some(record => record.meta.requiresAuth)) {
    if(store.getters['auth/status'] === '')
      store.dispatch("auth/check").then(() => next_or_login());
    else
      next_or_login();
  } else {
    next();
  }
});

export default router;
