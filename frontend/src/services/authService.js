/**
 * 认证服务
 * 提供用户注册、登录、注销和令牌管理功能
 */
import axios from 'axios';

const API_URL = 'http://localhost:5000/api/auth/';

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
 * 注册新用户
 * @param {string} username 用户名
 * @param {string} email 电子邮箱
 * @param {string} password 密码
 * @param {number} factionId 所选势力ID
 * @returns {Promise<Object>} 包含令牌和用户信息的对象
 */
const register = async (username, email, password, factionId = 1) => {
  try {
    const response = await apiClient.post('register', {
      username,
      email,
      password,
      faction_id: factionId
    });

    // 保存令牌和用户信息到localStorage
    if (response.data.access_token) {
      localStorage.setItem('user', JSON.stringify(response.data));
    }

    return response.data;
  } catch (error) {
    console.error('注册错误:', error);
    throw error;
  }
};

/**
 * 用户登录
 * @param {string} username 用户名
 * @param {string} password 密码
 * @returns {Promise<Object>} 包含令牌和用户信息的对象
 */
const login = async (username, password) => {
  try {
    const response = await apiClient.post('login', {
      username,
      password
    });

    // 保存令牌和用户信息到localStorage
    if (response.data.access_token) {
      localStorage.setItem('user', JSON.stringify(response.data));
    }

    return response.data;
  } catch (error) {
    console.error('登录错误:', error);
    throw error;
  }
};

/**
 * 用户注销
 */
const logout = () => {
  localStorage.removeItem('user');
};

/**
 * 刷新访问令牌
 * @param {string} refreshToken 刷新令牌
 * @returns {Promise<Object>} 包含新访问令牌的对象
 */
const refreshToken = async (refreshToken) => {
  try {
    const response = await axios.post(`${API_URL}refresh`, {}, {
      headers: {
        'Authorization': `Bearer ${refreshToken}`
      }
    });

    // 更新localStorage中的令牌
    const user = JSON.parse(localStorage.getItem('user'));
    if (user && response.data.access_token) {
      user.access_token = response.data.access_token;
      localStorage.setItem('user', JSON.stringify(user));
    }

    return response.data;
  } catch (error) {
    console.error('刷新令牌错误:', error);
    // 刷新令牌失败，清除用户信息
    localStorage.removeItem('user');
    throw error;
  }
};

/**
 * 获取当前用户信息
 * @returns {Object|null} 用户信息对象或null
 */
const getCurrentUser = () => {
  const user = localStorage.getItem('user');
  return user ? JSON.parse(user) : null;
};

/**
 * 获取用户个人资料
 * @returns {Promise<Object>} 用户个人资料
 */
const getUserProfile = async () => {
  try {
    const response = await apiClient.get('profile');
    
    // 更新localStorage中的用户信息
    const user = JSON.parse(localStorage.getItem('user'));
    if (user) {
      user.user = response.data;
      localStorage.setItem('user', JSON.stringify(user));
    }

    return response.data;
  } catch (error) {
    console.error('获取个人资料错误:', error);
    throw error;
  }
};

/**
 * 更新用户个人资料
 * @param {Object} profileData 要更新的个人资料数据
 * @returns {Promise<Object>} 更新后的用户个人资料
 */
const updateUserProfile = async (profileData) => {
  try {
    const response = await apiClient.put('profile', profileData);
    
    // 更新localStorage中的用户信息
    const user = JSON.parse(localStorage.getItem('user'));
    if (user) {
      user.user = response.data;
      localStorage.setItem('user', JSON.stringify(user));
    }

    return response.data;
  } catch (error) {
    console.error('更新个人资料错误:', error);
    throw error;
  }
};

/**
 * 修改密码
 * @param {string} currentPassword 当前密码
 * @param {string} newPassword 新密码
 * @returns {Promise<Object>} 操作结果
 */
const changePassword = async (currentPassword, newPassword) => {
  try {
    const response = await apiClient.put('change-password', {
      current_password: currentPassword,
      new_password: newPassword
    });

    return response.data;
  } catch (error) {
    console.error('修改密码错误:', error);
    throw error;
  }
};

// 导出认证服务
const authService = {
  register,
  login,
  logout,
  refreshToken,
  getCurrentUser,
  getUserProfile,
  updateUserProfile,
  changePassword
};

export default authService;
