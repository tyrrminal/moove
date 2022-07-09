import Vue from "vue";
import Vuex from "vuex";

//Modules
import auth from './modules/auth';
import meta from './modules/meta';

Vue.use(Vuex);

export default new Vuex.Store({
  modules: {
    auth,
    meta
  }
});
