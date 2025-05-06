import authService from '@/services/authService'

// 初始状态
const state = {
  user: null,
  accessToken: localStorage.getItem('access_token') || null,
  refreshToken: localStorage.getItem('refresh_token') || null
}

// 获取器
const getters = {
  currentUser: state => state.user,
  isAuthenticated: state => !!state.accessToken,
  accessToken: state => state.accessToken
}

// 修改器
const mutations = {
  SET_USER(state, user) {
    state.user = user
  },
  SET_AUTH_TOKENS(state, { accessToken, refreshToken }) {
    state.accessToken = accessToken
    state.refreshToken = refreshToken
    // 将令牌存储到localStorage
    localStorage.setItem('access_token', accessToken)
    localStorage.setItem('refresh_token', refreshToken)
  },
  CLEAR_AUTH(state) {
    state.user = null
    state.accessToken = null
    state.refreshToken = null
    // 清除localStorage中的令牌
    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
  }
}

// 动作
const actions = {
  // 登录
  async login({ commit, dispatch }, { username, password }) {
    try {
      dispatch('setLoading', true, { root: true })
      
      const response = await authService.login(username, password)
      
      commit('SET_USER', response.user)
      commit('SET_AUTH_TOKENS', {
        accessToken: response.access_token,
        refreshToken: response.refresh_token
      })
      
      return response
    } catch (error) {
      dispatch('setError', error.message || '登录失败', { root: true })
      throw error
    } finally {
      dispatch('setLoading', false, { root: true })
    }
  },
  
  // 注册
  async register({ commit, dispatch }, { username, email, password, factionId }) {
    try {
      dispatch('setLoading', true, { root: true })
      
      const response = await authService.register(username, email, password, factionId)
      
      commit('SET_USER', response.user)
      commit('SET_AUTH_TOKENS', {
        accessToken: response.access_token,
        refreshToken: response.refresh_token
      })
      
      return response
    } catch (error) {
      dispatch('setError', error.message || '注册失败', { root: true })
      throw error
    } finally {
      dispatch('setLoading', false, { root: true })
    }
  },
  
  // 登出
  async logout({ commit, dispatch }) {
    try {
      dispatch('setLoading', true, { root: true })
      
      await authService.logout()
      
      commit('CLEAR_AUTH')
      
      return true
    } catch (error) {
      dispatch('setError', error.message || '登出失败', { root: true })
      throw error
    } finally {
      dispatch('setLoading', false, { root: true })
    }
  },
  
  // 刷新令牌
  async refreshToken({ commit, state, dispatch }) {
    try {
      if (!state.refreshToken) {
        throw new Error('没有可用的刷新令牌')
      }
      
      const response = await authService.refreshToken(state.refreshToken)
      
      commit('SET_AUTH_TOKENS', {
        accessToken: response.access_token,
        refreshToken: state.refreshToken
      })
      
      return response.access_token
    } catch (error) {
      dispatch('setError', error.message || '刷新令牌失败', { root: true })
      commit('CLEAR_AUTH')
      throw error
    }
  },
  
  // 获取用户信息
  async fetchUserProfile({ commit, dispatch, state }) {
    try {
      if (!state.accessToken) {
        return null
      }
      
      dispatch('setLoading', true, { root: true })
      
      const user = await authService.getUserProfile()
      
      commit('SET_USER', user)
      
      return user
    } catch (error) {
      dispatch('setError', error.message || '获取用户信息失败', { root: true })
      throw error
    } finally {
      dispatch('setLoading', false, { root: true })
    }
  },
  
  // 更新用户信息
  async updateUserProfile({ commit, dispatch }, userData) {
    try {
      dispatch('setLoading', true, { root: true })
      
      const updatedUser = await authService.updateUserProfile(userData)
      
      commit('SET_USER', updatedUser)
      
      return updatedUser
    } catch (error) {
      dispatch('setError', error.message || '更新用户信息失败', { root: true })
      throw error
    } finally {
      dispatch('setLoading', false, { root: true })
    }
  },
  
  // 修改密码
  async changePassword({ dispatch }, { currentPassword, newPassword }) {
    try {
      dispatch('setLoading', true, { root: true })
      
      await authService.changePassword(currentPassword, newPassword)
      
      return true
    } catch (error) {
      dispatch('setError', error.message || '密码修改失败', { root: true })
      throw error
    } finally {
      dispatch('setLoading', false, { root: true })
    }
  },
  
  // 初始化认证状态
  async initAuth({ commit, dispatch, state }) {
    try {
      // 检查是否有保存的令牌
      if (state.accessToken) {
        // 获取用户信息
        await dispatch('fetchUserProfile')
      }
    } catch (error) {
      // 出错时清除认证信息
      commit('CLEAR_AUTH')
    }
  }
}

export default {
  namespaced: true,
  state,
  getters,
  mutations,
  actions
}
