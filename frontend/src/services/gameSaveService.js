/**
 * 游戏存档服务
 * 提供创建、获取、加载、更新和删除游戏存档功能
 */
import axios from 'axios';

const API_URL = 'http://localhost:5000/api/';

// 创建axios实例
const apiClient = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

// 请求拦截器
apiClient.interceptors.request.use(
  config => {
    const user = JSON.parse(localStorage.getItem('user'));
    if (user && user.access_token) {
      config.headers.Authorization = `Bearer ${user.access_token}`;
    }
    return config;
  },
  error => {
    return Promise.reject(error);
  }
);

/**
 * 获取所有游戏存档
 * @returns {Promise<Array>} 存档列表
 */
const getGameSaves = async () => {
  try {
    const response = await apiClient.get('game-saves');
    return response.data.game_saves;
  } catch (error) {
    console.error('获取游戏存档失败:', error);
    throw error;
  }
};

/**
 * 创建新游戏存档
 * @param {string} saveName 存档名称
 * @returns {Promise<Object>} 创建的存档对象
 */
const createGameSave = async (saveName) => {
  try {
    const response = await apiClient.post('game-saves', { save_name: saveName });
    return response.data.game_save;
  } catch (error) {
    console.error('创建游戏存档失败:', error);
    throw error;
  }
};

/**
 * 获取特定游戏存档详情
 * @param {number} gameId 存档ID
 * @returns {Promise<Object>} 存档详情
 */
const getGameSave = async (gameId) => {
  try {
    const response = await apiClient.get(`game-saves/${gameId}`);
    return response.data.game_save;
  } catch (error) {
    console.error(`获取存档#${gameId}详情失败:`, error);
    throw error;
  }
};

/**
 * 加载游戏存档
 * @param {number} gameId 存档ID
 * @returns {Promise<Object>} 加载的存档和初始游戏状态
 */
const loadGameSave = async (gameId) => {
  try {
    const response = await apiClient.post(`game-saves/${gameId}/load`);
    return response.data;
  } catch (error) {
    console.error(`加载存档#${gameId}失败:`, error);
    throw error;
  }
};

/**
 * 更新游戏存档信息
 * @param {number} gameId 存档ID
 * @param {Object} updateData 要更新的数据
 * @returns {Promise<Object>} 更新后的存档对象
 */
const updateGameSave = async (gameId, updateData) => {
  try {
    const response = await apiClient.put(`game-saves/${gameId}`, updateData);
    return response.data.game_save;
  } catch (error) {
    console.error(`更新存档#${gameId}失败:`, error);
    throw error;
  }
};

/**
 * 删除游戏存档
 * @param {number} gameId 存档ID
 * @returns {Promise<Object>} 操作结果
 */
const deleteGameSave = async (gameId) => {
  try {
    const response = await apiClient.delete(`game-saves/${gameId}`);
    return response.data;
  } catch (error) {
    console.error(`删除存档#${gameId}失败:`, error);
    throw error;
  }
};

// 导出游戏存档服务
const gameSaveService = {
  getGameSaves,
  createGameSave,
  getGameSave,
  loadGameSave,
  updateGameSave,
  deleteGameSave
};

export default gameSaveService;
