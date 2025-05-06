import { createStore } from 'vuex'
import auth from './modules/auth'
import universe from './modules/universe'

export default createStore({
  state: {
    loading: false,
    error: null
  },
  getters: {
    isLoading: state => state.loading,
    hasError: state => state.error !== null,
    errorMessage: state => state.error
  },
  mutations: {
    SET_LOADING(state, isLoading) {
      state.loading = isLoading
    },
    SET_ERROR(state, error) {
      state.error = error
    },
    CLEAR_ERROR(state) {
      state.error = null
    }
  },
  actions: {
    setLoading({ commit }, isLoading) {
      commit('SET_LOADING', isLoading)
    },
    setError({ commit }, error) {
      commit('SET_ERROR', error)
    },
    clearError({ commit }) {
      commit('CLEAR_ERROR')
    }
  },
  modules: {
    auth,
    universe
  }
})
