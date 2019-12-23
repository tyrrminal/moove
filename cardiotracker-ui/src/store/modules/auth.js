import Vue from "vue";
Vue.use(require('vue-moment'));

import axios from '@/services/axios';

let guest = { id: 0, username: 'Guest', person: { first_name: 'Guest', last_name: '' } };

const state = {
  status: '',
  user: guest,
  roles: [],
  expiration: null
}

const getters = {
  currentUser: state => state.user,
  status: state => state.status,
  expiration: state => Vue.moment(state.expiration),

  isLoggedIn: state => state.user.id > 0,
  isAdmin: state => state.roles.includes('admin')
}

const actions = {
  login({ commit }, d) {
    return new Promise((resolve, reject) => {
      commit('auth_request');
      axios
        .post('/auth/login', {}, { auth: { username: d[0], password: d[1] } })
        .then(resp => {
          const s = resp.data;
          commit('auth_success', s);
          resolve(resp);
        })
        .catch(err => {
          commit('auth_error');
          reject(err);
        })
    })
  },
  check({ commit }) {
    return new Promise((resolve, reject) => {
      commit('auth_request');
      axios
        .get('/auth/status')
        .then(resp => {
          const s = resp.data;
          commit('auth_success', s);
          resolve(resp);
        })
        .catch(err => {
          commit('auth_error');
          reject(err);
        })
    })
  },
  logout({ commit }) {
    return new Promise((resolve, reject) => {

      axios.post('/auth/logout', {}, { headers: { "Accept": "text/plain" } })
        .then(resp => {
          commit('logout');
          resolve(resp);
        })
        .catch(err => {
          commit('auth_error');
          reject(err);
        })
    })
  }
}

const mutations = {
  auth_request(state) {
    state.status = 'loading';
  },
  auth_success(state, s) {
    state.status = 'success';
    state.user = s.user;
    state.roles = s.roles;
    state.expiration = s.expiration;
  },
  auth_error(state) {
    state.status = 'error';
    state.user = guest;
    state.roles = [];
    state.expiration = null;
  },
  logout(state) {
    state.status = 'logout';
    state.user = guest;
    state.roles = [];
    state.expiration = null;
  }
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
