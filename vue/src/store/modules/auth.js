import { DateTime } from "luxon";

import axios from '@/services/axios';

let guest = { id: 0, username: 'Guest', person: { firstname: 'Guest', lastname: '' } };

const state = {
  status: '',
  user: guest,
  roles: [],
  expiration: null
}

const getters = {
  currentUser: state => state.user,
  status: state => state.status,
  expiration: state => DateTime.fromISO(state.expiration),

  isLoggedIn: state => state.user.id > 0,
  isAdmin: state => state.roles.includes('admin')
}

const actions = {
  login({ commit }, d) {
    return new Promise((resolve, reject) => {
      commit('authRequest');
      axios
        .post('/auth/login', {}, { auth: { username: d[0], password: d[1] } })
        .then(resp => {
          const s = resp.data;
          commit('authSuccess', s);
          resolve(resp);
        })
        .catch(err => {
          commit('authError');
          reject(err);
        })
    })
  },
  check({ commit }) {
    return new Promise((resolve, reject) => {
      commit('authRequest');
      axios
        .get('/auth/status')
        .then(resp => {
          const s = resp.data;
          commit('authSuccess', s);
          resolve(resp);
        })
        .catch(err => {
          commit('authError');
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
          commit('authError');
          reject(err);
        })
    })
  }
}

const mutations = {
  authRequest(state) {
    state.status = 'loading';
  },
  authSuccess(state, s) {
    state.status = 'success';
    state.user = s.user;
    state.roles = s.roles;
    state.expiration = s.expiration;
  },
  authError(state) {
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
