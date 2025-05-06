/**
 * 星系服务 - 处理与宇宙相关的API请求
 */
import axios from 'axios';
import store from '@/store';

// 创建axios实例
const universeApi = axios.create({
  baseURL: 'http://localhost:5000/api/universe',
  headers: {
    'Content-Type': 'application/json'
  }
});

// 请求拦截器 - 添加授权头
universeApi.interceptors.request.use(
  config => {
    const token = store.getters['auth/accessToken'];
    if (token) {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    return config;
  },
  error => {
    return Promise.reject(error);
  }
);

// 响应拦截器 - 处理令牌过期
universeApi.interceptors.response.use(
  response => response,
  async error => {
    const originalRequest = error.config;
    
    // 如果是401错误且不是刷新令牌请求
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      
      try {
        // 尝试刷新令牌
        await store.dispatch('auth/refreshToken');
        
        // 重新设置授权头
        const newToken = store.getters['auth/accessToken'];
        originalRequest.headers['Authorization'] = `Bearer ${newToken}`;
        
        // 重试原始请求
        return universeApi(originalRequest);
      } catch (refreshError) {
        // 刷新失败，需要重新登录
        store.dispatch('auth/logout');
        return Promise.reject(refreshError);
      }
    }
    
    return Promise.reject(error);
  }
);

/**
 * 星系服务对象
 */
const universeService = {
  /**
   * 获取所有星系
   * @param {Object} options 可选参数
   * @param {Boolean} options.showAll 是否显示所有星系，包括未发现的
   * @param {String} options.type 可选的星系类型过滤
   * @returns {Promise} 返回星系数据
   */
  getAllSystems(options = {}) {
    const params = new URLSearchParams();
    
    if (options.showAll) {
      params.append('show_all', 'true');
    }
    
    if (options.type) {
      params.append('type', options.type);
    }
    
    return universeApi.get(`/systems${params.toString() ? '?' + params.toString() : ''}`)
      .then(response => {
        if (response.data.success) {
          return response.data.systems;
        } else {
          throw new Error(response.data.error || '获取星系数据失败');
        }
      });
  },
  
  /**
   * 获取特定星系的详细信息
   * @param {Number} systemId 星系ID
   * @returns {Promise} 返回星系详细数据
   */
  async getSystemDetails(systemId) {
    try {
      const response = await universeApi.get(`/systems/${systemId}`);
      return response.data;
    } catch (error) {
      console.error(`获取星系#${systemId}详情失败:`, error);
      throw error;
    }
  },
  
  /**
   * 获取所有空间站
   * @param {Number} systemId 可选，指定星系ID
   * @returns {Promise} 返回空间站数据
   */
  async getStations(systemId = null) {
    try {
      const params = systemId ? { system_id: systemId } : {};
      const response = await universeApi.get('/stations', { params });
      return response.data;
    } catch (error) {
      console.error('获取空间站数据失败:', error);
      throw error;
    }
  },
  
  /**
   * 获取特定空间站的详细信息
   * @param {Number} stationId 空间站ID
   * @returns {Promise} 返回空间站详细数据
   */
  async getStationDetails(stationId) {
    try {
      const response = await universeApi.get(`/stations/${stationId}`);
      return response.data;
    } catch (error) {
      console.error(`获取空间站#${stationId}详情失败:`, error);
      throw error;
    }
  },
  
  /**
   * 获取所有跳跃点
   * @param {Number} systemId 可选，指定星系ID
   * @returns {Promise} 返回跳跃点数据
   */
  async getJumpGates(systemId = null) {
    try {
      const params = systemId ? { system_id: systemId } : {};
      const response = await universeApi.get('/jumpgates', { params });
      return response.data;
    } catch (error) {
      console.error('获取跳跃点数据失败:', error);
      throw error;
    }
  },
  
  /**
   * 获取所有势力
   * @returns {Promise} 返回势力数据
   */
  async getFactions() {
    try {
      const response = await universeApi.get('/factions');
      return response.data;
    } catch (error) {
      console.error('获取势力数据失败:', error);
      throw error;
    }
  }
};

export default universeService;
