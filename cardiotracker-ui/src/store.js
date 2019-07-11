import Vue from "vue";
import Vuex from "vuex";

Vue.use(Vuex);

import axios from './services/axios';
import qs from 'qs';

let guest = { id: 0, username: 'guest', person: { first_name: 'Guest', last_name: '' } };

export default new Vuex.Store({
  state: {
    status: '',
    auth_user: guest
  },
  actions: {
    login({ commit }, user) {
      return new Promise((resolve, reject) => {
        commit('auth_request');
        axios
          .post('/auth/login', qs.stringify(user), { headers: { "Content-Type": "application/x-www-form-urlencoded" } })
          .then(resp => {
            const user = resp.data;
            commit('auth_success', user);
            resolve(resp);
          })
          .catch(err => {
            commit('auth_error');
            reject(err);
          })
      })
    },
    login_check({ commit }) {
      return new Promise((resolve, reject) => {
        commit('auth_request');
        axios
          .get('/auth/status')
          .then(resp => {
            const user = resp.data;
            commit('auth_success', user);
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
  },
  mutations: {
    auth_request(state) {
      state.status = 'loading';
    },
    auth_success(state, user) {
      state.status = 'success';
      state.auth_user = user;
    },
    auth_error(state) {
      state.status = 'error';
      state.auth_user = guest;
    },
    logout(state) {
      state.status = '';
      state.auth_user = guest;
    }
  },
  getters: {
    currentUser: state => state.auth_user,
    isLoggedIn: state => state.auth_user.id > 0,
    authStatus: state => state.status
  }
});
