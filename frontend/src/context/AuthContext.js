import React, { createContext, useState, useEffect, useContext } from 'react';
import authService from '../services/authService';

// 创建认证上下文
const AuthContext = createContext();

/**
 * 认证提供者组件
 * 提供全局认证状态管理
 */
export const AuthProvider = ({ children }) => {
  // 用户状态
  const [currentUser, setCurrentUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  
  // 初始化时从localStorage加载用户
  useEffect(() => {
    const initAuth = () => {
      const user = authService.getCurrentUser();
      if (user && user.access_token) {
        setCurrentUser(user);
        setIsAuthenticated(true);
      }
      setIsLoading(false);
    };
    
    initAuth();
  }, []);
  
  /**
   * 登录方法
   */
  const login = async (username, password) => {
    const data = await authService.login(username, password);
    setCurrentUser(data.user);
    setIsAuthenticated(true);
    return data;
  };
  
  /**
   * 注册方法
   */
  const register = async (username, email, password, factionId) => {
    const data = await authService.register(username, email, password, factionId);
    setCurrentUser(data.user);
    setIsAuthenticated(true);
    return data;
  };
  
  /**
   * 注销方法
   */
  const logout = () => {
    authService.logout();
    setCurrentUser(null);
    setIsAuthenticated(false);
  };
  
  /**
   * 刷新用户资料
   */
  const refreshUserProfile = async () => {
    if (!isAuthenticated) return;
    
    try {
      const profileData = await authService.getProfile();
      setCurrentUser({
        ...currentUser,
        ...profileData
      });
    } catch (error) {
      console.error('刷新用户资料失败:', error);
    }
  };
  
  // 提供给上下文的值
  const value = {
    currentUser,
    isAuthenticated,
    isLoading,
    login,
    register,
    logout,
    refreshUserProfile
  };
  
  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

/**
 * 使用认证上下文的自定义Hook
 */
export const useAuth = () => {
  return useContext(AuthContext);
};

export default AuthContext;
