import axios from "@/services/axios";

const state = {
  activityTypes: [],
  eventTypes: [],
  unitsOfMeasure: [],
  externalDataSources: [],
  visibilityTypes: [],
};

const getters = {
  isLoaded: (state) => {
    return
    state.activityTypes.length &&
      state.eventTypes.length &&
      state.unitsOfMeasure.length &&
      state.externalDataSources.length &&
      state.visibilityTypes.length
  },

  getActivityTypes: (state) => { return state.activityTypes },
  getEventTypes: (state) => { return state.eventTypes },
  getUnitsOfMeasure: (state) => { return state.unitsOfMeasure },
  getExternalDataSources: (state) => { return state.externalDataSources },
  getVisibilityTypes: (state) => { return state.visibilityTypes },
};

const actions = {
  initialize({ commit }) {
    return new Promise((resolve, reject) => {
      axios.get("meta/values", { params: { all: true } })
        .then(resp => {
          commit('loadActivityTypes', resp.data.activityTypes)
          commit('loadEventTypes', resp.data.eventTypes)
          commit('loadUnitsOfMeasure', resp.data.unitOfMeasure)
          commit('loadExternalDataSources', resp.data.externalDataSource)
          commit('loadVisibilityTypes', resp.data.visibilityTypes)
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
  },
  loadEventTypes(state, d) {
    state.eventTypes = d;
  },
  loadUnitsOfMeasure(state, d) {
    state.unitsOfMeasure = d;
  },
  loadExternalDataSources(state, d) {
    state.externalDataSources = d;
  },
  loadVisibilityTypes(state, d) {
    state.visibilityTypes = d;
  }
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
};
