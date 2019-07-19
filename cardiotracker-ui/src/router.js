import Vue from "vue";
import Router from "vue-router";
import store from './store.js'
import Home from "./views/Home.vue";
import Login from "@/components/auth/Login.vue";

import User from '@/views/User.vue';
import Event from "./views/Event.vue";

import LegacySummary from "./views/Legacy/Summary.vue";
import LegacyEvents from "./views/Legacy/Events.vue";
import LegacyActivities from "./views/Legacy/Activities.vue";

import ErrorNotFound from '@/error/NotFound.vue';

Vue.use(Router);
Vue.use(require('vue-moment'));

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
      path: "/user/:id",
      name: "user",
      component: User
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
    },
    {
      path: '*',
      name: 'error_not_found',
      component: ErrorNotFound
    }
  ]
});

router.beforeEach((to, from, next) => {
  let exp = store.getters['auth/expiration'];
  if(exp.diff(Vue.moment()) < 0) {
    store.dispatch('auth/logout').then(() => next());
  }

  if(store.getters['auth/status'] === '')
    store.dispatch('auth/check').then(() => next());
  else
    next();
});

export default router;
