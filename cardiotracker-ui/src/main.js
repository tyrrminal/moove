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

import { library } from '@fortawesome/fontawesome-svg-core'
import { faAngleRight } from '@fortawesome/free-solid-svg-icons'
import { faAngleLeft } from '@fortawesome/free-solid-svg-icons'
import { faAngleDoubleRight } from '@fortawesome/free-solid-svg-icons'
import { faAngleDoubleLeft } from '@fortawesome/free-solid-svg-icons'
import { faExternalLinkAlt } from '@fortawesome/free-solid-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

library.add(faAngleRight, faAngleLeft, faAngleDoubleRight, faAngleDoubleLeft, faExternalLinkAlt )
Vue.component('font-awesome-icon', FontAwesomeIcon)

Vue.config.productionTip = false;

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount("#app");
