import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";

var VueCookie = require('vue-cookie');
Vue.use(VueCookie);

import VueAxios from "vue-axios";
import axios from './services/axios';

Vue.use(VueAxios, axios);

import BootstrapVue from "bootstrap-vue";

Vue.use(BootstrapVue);
Vue.use(require('vue-moment'));

import "bootstrap/dist/css/bootstrap.css";
import "bootstrap-vue/dist/bootstrap-vue.css";

Vue.config.productionTip = false;

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount("#app");
