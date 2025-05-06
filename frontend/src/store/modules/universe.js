/**
 * 宇宙数据 Vuex 模块
 * 管理星系、空间站、跳跃点等数据
 */
import universeService from '@/services/universeService';

const state = {
  systems: [],
  currentSystem: null,
  stations: [],
  jumpGates: [],
  factions: [],
  isLoading: false,
  error: null
};

const getters = {
  allSystems: state => state.systems,
  currentSystem: state => state.currentSystem,
  stationsInCurrentSystem: state => state.stations.filter(station => 
    state.currentSystem && station.system_id === state.currentSystem.system_id
  ),
  jumpGatesInCurrentSystem: state => state.jumpGates.filter(gate => 
    state.currentSystem && gate.source_system_id === state.currentSystem.system_id
  ),
  allFactions: state => state.factions,
  systemById: state => id => state.systems.find(system => system.system_id === id),
  isLoading: state => state.isLoading,
  error: state => state.error
};

const mutations = {
  SET_SYSTEMS(state, systems) {
    state.systems = systems;
  },
  SET_CURRENT_SYSTEM(state, system) {
    state.currentSystem = system;
  },
  SET_STATIONS(state, stations) {
    state.stations = stations;
  },
  SET_JUMP_GATES(state, jumpGates) {
    state.jumpGates = jumpGates;
  },
  SET_FACTIONS(state, factions) {
    state.factions = factions;
  },
  SET_LOADING(state, isLoading) {
    state.isLoading = isLoading;
  },
  SET_ERROR(state, error) {
    state.error = error;
  }
};

const actions = {
  /**
   * 加载所有星系数据
   */
  async fetchAllSystems({ commit }) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      // 使用showAll=true确保获取所有星系，包括未发现的边缘和未知区域
      const systems = await universeService.getAllSystems({ showAll: true });
      commit('SET_SYSTEMS', systems);
      return systems;
    } catch (error) {
      commit('SET_ERROR', error.response?.data?.error || '无法加载星系数据');
      console.error('加载星系数据失败:', error);
      throw error;
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  /**
   * 加载特定星系的详细数据
   * @param {Object} context Vuex 上下文
   * @param {Number} systemId 星系ID
   */
  async fetchSystemDetails({ commit }, systemId) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      const response = await universeService.getSystemDetails(systemId);
      commit('SET_CURRENT_SYSTEM', response.system);
      return response.system;
    } catch (error) {
      commit('SET_ERROR', error.response?.data?.error || '无法加载星系详情');
      console.error(`加载星系#${systemId}详情失败:`, error);
      throw error;
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  /**
   * 加载空间站数据
   * @param {Object} context Vuex 上下文
   * @param {Number|Object} systemIdOrOptions 可选，星系ID或选项对象
   */
  async fetchStations({ commit }, systemIdOrOptions = null) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      // 如果只是传入了systemId，转换为对象格式
      const options = typeof systemIdOrOptions === 'number' 
        ? { systemId: systemIdOrOptions, showAll: true } 
        : { ...systemIdOrOptions, showAll: true };
      
      console.log('调用空间站服务，options:', options);
      const response = await universeService.getStations(options);
      console.log('空间站服务返回数据:', response);
      commit('SET_STATIONS', response);  
      return response;
    } catch (error) {
      commit('SET_ERROR', error.response?.data?.error || '无法加载空间站数据');
      console.error('加载空间站数据失败:', error);
      throw error;
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  /**
   * 加载跳跃点数据
   * @param {Object} context Vuex 上下文
   * @param {Number|Object} systemIdOrOptions 可选，星系ID或选项对象
   */
  async fetchJumpGates({ commit }, systemIdOrOptions = null) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      // 如果只是传入了systemId，转换为对象格式
      const options = typeof systemIdOrOptions === 'number' 
        ? { systemId: systemIdOrOptions, showAll: true } 
        : { ...systemIdOrOptions, showAll: true };
      
      console.log('调用跳跃点服务，options:', options);
      const response = await universeService.getJumpGates(options);
      console.log('跳跃点服务返回数据:', response);
      commit('SET_JUMP_GATES', response);  
      return response;
    } catch (error) {
      commit('SET_ERROR', error.response?.data?.error || '无法加载跳跃点数据');
      console.error('加载跳跃点数据失败:', error);
      throw error;
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  /**
   * 加载势力数据
   */
  async fetchFactions({ commit }) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      const response = await universeService.getFactions();
      commit('SET_FACTIONS', response.factions);
      return response.factions;
    } catch (error) {
      commit('SET_ERROR', error.response?.data?.error || '无法加载势力数据');
      console.error('加载势力数据失败:', error);
      throw error;
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  /**
   * 初始化宇宙数据
   * 加载基本的星系和势力数据
   */
  async initUniverseData({ dispatch }) {
    try {
      await Promise.all([
        dispatch('fetchAllSystems'),
        dispatch('fetchFactions')
      ]);
      return true;
    } catch (error) {
      console.error('初始化宇宙数据失败:', error);
      return false;
    }
  },
  
  /**
   * 切换当前星系
   * @param {Object} context Vuex 上下文
   * @param {Number} systemId 星系ID
   */
  async changeCurrentSystem({ dispatch }, systemId) {
    try {
      // 加载星系详情
      const systemDetails = await dispatch('fetchSystemDetails', systemId);
      
      // 加载该星系的空间站和跳跃点
      await Promise.all([
        dispatch('fetchStations', systemId),
        dispatch('fetchJumpGates', systemId)
      ]);
      
      return systemDetails;
    } catch (error) {
      console.error(`切换到星系#${systemId}失败:`, error);
      throw error;
    }
  }
};

export default {
  namespaced: true,
  state,
  getters,
  mutations,
  actions
};
