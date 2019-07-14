import Vue from "vue";
import Vuex from "vuex";

Vue.use(Vuex);

import axios from './services/axios';
import qs from 'qs';

let guest = { id: 0, username: 'guest', person: { first_name: 'Guest', last_name: '' } };

export default new Vuex.Store({
  modules: {
    auth: {
      namespaced: true,
      state: {
        status: '',
        user: guest
      },
      actions: {
        login({ commit }, d) {
          return new Promise((resolve, reject) => {
            commit('auth_request');
            axios
              .post('/auth/login', qs.stringify(d), { headers: { "Content-Type": "application/x-www-form-urlencoded" } })
              .then(resp => {
                const u = resp.data;
                commit('auth_success', u);
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
                const u = resp.data;
                commit('auth_success', u);
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
        auth_success(state, u) {
          state.status = 'success';
          state.user = u;
        },
        auth_error(state) {
          state.status = 'error';
          state.user = guest;
        },
        logout(state) {
          state.status = 'logout';
          state.user = guest;
        }
      },
      getters: {
        currentUser: state => state.user,
        isLoggedIn:  state => state.user.id > 0,
        status:      state => state.status
      }
    }
  }
});
