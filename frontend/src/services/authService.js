/**
 * 认证服务
 * 提供用户注册、登录、注销和令牌管理功能
 */
const API_URL = 'http://localhost:5000/api/auth/';

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
    const response = await fetch(`${API_URL}register`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        username,
        email,
        password,
        faction_id: factionId
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || '注册失败');
    }

    // 保存令牌和用户信息到localStorage
    if (data.access_token) {
      localStorage.setItem('user', JSON.stringify(data));
    }

    return data;
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
    const response = await fetch(`${API_URL}login`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        username,
        password
      }),
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || '登录失败');
    }

    // 保存令牌和用户信息到localStorage
    if (data.access_token) {
      localStorage.setItem('user', JSON.stringify(data));
    }

    return data;
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
 * @returns {Promise<Object>} 包含新访问令牌的对象
 */
const refreshToken = async () => {
  try {
    const user = JSON.parse(localStorage.getItem('user'));

    if (!user || !user.refresh_token) {
      throw new Error('没有可用的刷新令牌');
    }

    const response = await fetch(`${API_URL}refresh`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${user.refresh_token}`,
        'Content-Type': 'application/json',
      },
    });

    const data = await response.json();

    if (!response.ok) {
      throw new Error(data.error || '刷新令牌失败');
    }

    // 更新localStorage中的访问令牌
    if (data.access_token) {
      user.access_token = data.access_token;
      localStorage.setItem('user', JSON.stringify(user));
    }

    return data;
  } catch (error) {
    console.error('刷新令牌错误:', error);
    throw error;
  }
};

/**
 * 获取当前用户信息
 * @returns {Object|null} 用户信息对象或null
 */
const getCurrentUser = () => {
  const userStr = localStorage.getItem('user');
  if (!userStr) return null;
  
  try {
    return JSON.parse(userStr);
  } catch (e) {
    console.error('解析用户信息失败:', e);
    return null;
  }
};

/**
 * 获取用户个人资料
 * @returns {Promise<Object>} 用户个人资料
 */
const getProfile = async () => {
  try {
    const user = getCurrentUser();
    
    if (!user || !user.access_token) {
      throw new Error('未登录');
    }
    
    const response = await fetch(`${API_URL}profile`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${user.access_token}`,
        'Content-Type': 'application/json',
      },
    });
    
    const data = await response.json();
    
    if (!response.ok) {
      throw new Error(data.error || '获取个人资料失败');
    }
    
    return data;
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
const updateProfile = async (profileData) => {
  try {
    const user = getCurrentUser();
    
    if (!user || !user.access_token) {
      throw new Error('未登录');
    }
    
    const response = await fetch(`${API_URL}profile`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${user.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(profileData),
    });
    
    const data = await response.json();
    
    if (!response.ok) {
      throw new Error(data.error || '更新个人资料失败');
    }
    
    return data;
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
    const user = getCurrentUser();
    
    if (!user || !user.access_token) {
      throw new Error('未登录');
    }
    
    const response = await fetch(`${API_URL}change-password`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${user.access_token}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        current_password: currentPassword,
        new_password: newPassword
      }),
    });
    
    const data = await response.json();
    
    if (!response.ok) {
      throw new Error(data.error || '修改密码失败');
    }
    
    return data;
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
  getProfile,
  updateProfile,
  changePassword
};

export default authService;
