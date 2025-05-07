import gameSaveService from '@/services/gameSaveService'

// 初始状态
const state = {
  gameSaves: [],          // 用户的所有游戏存档
  currentGameSave: null,  // 当前加载的游戏存档
  isLoading: false,       // 加载状态
  error: null            // 错误信息
}

// 获取器
const getters = {
  allGameSaves: state => state.gameSaves,
  currentGameSave: state => state.currentGameSave,
  hasGameSaves: state => state.gameSaves && state.gameSaves.length > 0,
  isGameSaveLoaded: state => !!state.currentGameSave,
  gameSavesLoading: state => state.isLoading,
  gameSaveError: state => state.error
}

// 修改器
const mutations = {
  SET_GAME_SAVES(state, gameSaves) {
    state.gameSaves = gameSaves;
  },
  SET_CURRENT_GAME_SAVE(state, gameSave) {
    state.currentGameSave = gameSave;
    // 可以保存当前游戏存档ID到localStorage，方便用户下次登录自动加载
    if (gameSave) {
      localStorage.setItem('current_game_id', gameSave.game_id);
    } else {
      localStorage.removeItem('current_game_id');
    }
  },
  ADD_GAME_SAVE(state, gameSave) {
    state.gameSaves.push(gameSave);
  },
  UPDATE_GAME_SAVE(state, updatedGameSave) {
    const index = state.gameSaves.findIndex(save => save.game_id === updatedGameSave.game_id);
    if (index !== -1) {
      state.gameSaves.splice(index, 1, updatedGameSave);
      
      // 如果更新的是当前存档，也更新当前存档对象
      if (state.currentGameSave && state.currentGameSave.game_id === updatedGameSave.game_id) {
        state.currentGameSave = updatedGameSave;
      }
    }
  },
  REMOVE_GAME_SAVE(state, gameId) {
    state.gameSaves = state.gameSaves.filter(save => save.game_id !== gameId);
    
    // 如果删除的是当前存档，清空当前存档
    if (state.currentGameSave && state.currentGameSave.game_id === gameId) {
      state.currentGameSave = null;
      localStorage.removeItem('current_game_id');
    }
  },
  SET_LOADING(state, isLoading) {
    state.isLoading = isLoading;
  },
  SET_ERROR(state, error) {
    state.error = error;
  }
}

// 动作
const actions = {
  // 获取所有游戏存档
  async fetchGameSaves({ commit }) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      const gameSaves = await gameSaveService.getGameSaves();
      commit('SET_GAME_SAVES', gameSaves);
    } catch (error) {
      commit('SET_ERROR', '获取游戏存档失败');
      console.error('获取游戏存档失败:', error);
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  // 创建新游戏存档
  async createGameSave({ commit }, saveName) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      const newGameSave = await gameSaveService.createGameSave(saveName);
      commit('ADD_GAME_SAVE', newGameSave);
      return newGameSave;
    } catch (error) {
      commit('SET_ERROR', '创建游戏存档失败');
      console.error('创建游戏存档失败:', error);
      throw error;
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  // 加载游戏存档
  async loadGameSave({ commit }, gameId) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      const gameData = await gameSaveService.loadGameSave(gameId);
      commit('SET_CURRENT_GAME_SAVE', gameData.game_save);
      
      // TODO: 加载其他游戏数据到各自的状态模块中
      // 例如: commit('player/SET_PLAYER_DATA', gameData.player, { root: true });
      
      return gameData;
    } catch (error) {
      commit('SET_ERROR', '加载游戏存档失败');
      console.error('加载游戏存档失败:', error);
      throw error;
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  // 更新游戏存档
  async updateGameSave({ commit }, { gameId, updateData }) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      const updatedGameSave = await gameSaveService.updateGameSave(gameId, updateData);
      commit('UPDATE_GAME_SAVE', updatedGameSave);
      return updatedGameSave;
    } catch (error) {
      commit('SET_ERROR', '更新游戏存档失败');
      console.error('更新游戏存档失败:', error);
      throw error;
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  // 删除游戏存档
  async deleteGameSave({ commit }, gameId) {
    commit('SET_LOADING', true);
    commit('SET_ERROR', null);
    
    try {
      await gameSaveService.deleteGameSave(gameId);
      commit('REMOVE_GAME_SAVE', gameId);
    } catch (error) {
      commit('SET_ERROR', '删除游戏存档失败');
      console.error('删除游戏存档失败:', error);
      throw error;
    } finally {
      commit('SET_LOADING', false);
    }
  },
  
  // 清除当前游戏存档（例如，返回到主菜单时）
  clearCurrentGameSave({ commit }) {
    commit('SET_CURRENT_GAME_SAVE', null);
  },
  
  // 尝试从localStorage自动加载上次的游戏存档
  async autoLoadLastGameSave({ dispatch, state }) {
    const lastGameId = localStorage.getItem('current_game_id');
    
    if (lastGameId && !state.currentGameSave) {
      try {
        await dispatch('loadGameSave', parseInt(lastGameId));
      } catch (error) {
        console.error('自动加载上次游戏存档失败:', error);
        // 如果加载失败，清除存储的ID
        localStorage.removeItem('current_game_id');
      }
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
