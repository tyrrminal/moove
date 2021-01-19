import axios from "@/services/axios";

const allLoaded = 3;

const state = {
  loaded: 0,
  activityTypes: [],
  eventTypes: [],
  unitsOfMeasure: []
};

const getters = {
  isLoaded: (state) => { return state.loaded >= allLoaded },

  getActivityTypes: (state) => { return state.activityTypes },
  getEventTypes: (state) => { return state.eventTypes },
  getUnitsOfMeasure: (state) => { return state.unitsOfMeasure },
};

const actions = {
  initialize({ commit }) {
    return new Promise((resolve, reject) => {
      axios.get("meta/values", { params: { all: true } })
        .then(resp => {
          commit('loadActivityTypes', resp.data.activityTypes)
          commit('loadEventTypes', resp.data.eventTypes)
          commit('loadUnitsOfMeasure', resp.data.unitOfMeasure)
        })
        .catch(err => {
          reject(err)
        })
    })
  }
};

const mutations = {
  loadActivityTypes(state, d) {
    state.activityTypes = d;
    state.loaded++;
  },
  loadEventTypes(state, d) {
    state.eventTypes = d;
    state.loaded++;
  },
  loadUnitsOfMeasure(state, d) {
    state.unitsOfMeasure = d;
    state.loaded++;
  }
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
};
