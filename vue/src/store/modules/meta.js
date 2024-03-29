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
    return state.activityTypes.length > 0 &&
      state.eventTypes.length > 0 &&
      state.unitsOfMeasure.length > 0 &&
      state.externalDataSources.length > 0 &&
      state.visibilityTypes.length > 0
  },

  getActivityTypes: (state) => { return state.activityTypes },
  getActivityType: (state) => id => { return state.activityTypes.filter(x => x.id == id).shift() },
  getBaseActivityTypes: (state) => [...new Set(state.activityTypes.map(at => at.labels.base))],
  getActivityTypesForBase: (state) => base => { return state.activityTypes.filter(x => x.labels.base == base) },
  getActivityTypeContexts: (state) => [...new Set(state.activityTypes.map(at => at.labels.context))],
  getActivityTypesForContext: (state) => context => { return state.activityTypes.filter(x => x.labels.context == context) },
  getEventTypes: (state) => { return state.eventTypes },
  getEventType: (state) => id => { return state.eventTypes.filter(x => x.id == id).shift() },
  getUnitsOfMeasure: (state) => { return state.unitsOfMeasure },
  getUnitOfMeasure: (state) => id => { return state.unitsOfMeasure.filter(x => x.id == id).shift() },
  getExternalDataSources: (state) => { return state.externalDataSources },
  getExternalDataSource: (state) => id => { return state.externalDataSources.filter(x => x.id == id).shift() },
  getVisibilityTypes: (state) => { return state.visibilityTypes },
  getVisibilityType: (state) => id => { return state.visibilityTypes.filter(x => x.id == id).shift() },
};

const actions = {
  initialize({ commit }) {
    return new Promise((resolve, reject) => {
      axios.get("meta/values", { params: { all: true } })
        .then(resp => {
          commit('loadActivityTypes', resp.data.activityTypes)
          commit('loadEventTypes', resp.data.eventTypes)
          commit('loadUnitsOfMeasure', resp.data.unitOfMeasure)
          commit('loadExternalDataSources', resp.data.externalDataSources)
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
