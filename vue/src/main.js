import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";

// Axios (Networking)
import VueAxios from "vue-axios";
import axios from './services/axios';
Vue.use(VueAxios, axios);

import Meta from "vue-meta";
Vue.use(Meta);

// Luxon (Date formatting)
import VueLuxon from "vue-luxon"
Vue.use(VueLuxon);

//String Formatting
import VuePluralize from 'vue-pluralize';
Vue.use(VuePluralize);

//Number Formatting
import vueNumeralFilterInstaller from 'vue-numeral-filter';
Vue.use(vueNumeralFilterInstaller);
import Vue2Filters from 'vue2-filters'
Vue.use(Vue2Filters)

import VueTimeago from 'vue-timeago'
Vue.use(VueTimeago, {
  name: 'Timeago',
  locale: 'en'
});

// Layout and design
import { BootstrapVue, IconsPlugin } from "bootstrap-vue";
Vue.use(BootstrapVue);
Vue.use(IconsPlugin);
import "bootstrap/dist/css/bootstrap.css";
import "bootstrap-vue/dist/bootstrap-vue.css";
import "bootstrap/dist/js/bootstrap.min.js";

import vSelect from 'vue-select';
Vue.component('v-select', vSelect);
import 'vue-select/dist/vue-select.css';

import Vuelidate from 'vuelidate';
Vue.use(Vuelidate);

import OhVueIcon from "oh-vue-icons";
import {
  GiRun, GiWalk, GiWeightLiftingUp, GiBodyBalance, CoSwimming, CoRowing, CoBike
} from "oh-vue-icons/icons";
OhVueIcon.add(GiRun, GiWalk, GiWeightLiftingUp, GiBodyBalance, CoBike, CoSwimming, CoRowing);
Vue.component("v-icon", OhVueIcon);

// Vue
Vue.config.productionTip = false;
new Vue({
  router,
  store,
  render: h => h(App)
}).$mount("#app");
