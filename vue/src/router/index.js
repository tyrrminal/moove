import Vue from "vue";
import Router from "vue-router";
import store from "@/store";
import Home from "@/views/Home.vue";
import Login from "@/components/auth/Login.vue";

import User from "@/views/User.vue";
import Goals from "@/views/Goals.vue";
import Goal from "@/views/Goal.vue";
import Event from "@/views/Event.vue";
import Events from "@/views/Events.vue";

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
      path: "/user/:user/goals",
      name: "goals",
      component: Goals
    },
    {
      path: "/user/:user/goal/:id",
      name: "goal",
      component: Goal
    },
    {
      path: "/user/:user/event/:id",
      name: "event",
      component: Event
    },

    {
      path: "/user/:user/events",
      name: 'events',
      component: Events
    },
    {
      path: "/user/:user/event/sequence/:sequence_id",
      name: 'sequence',
      component: Events
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

export default router;
