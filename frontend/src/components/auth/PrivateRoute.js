import React from 'react';
import { Navigate } from 'react-router-dom';
import authService from '../../services/authService';

/**
 * 私有路由组件
 * 保护需要登录才能访问的路由
 * 
 * @param {Object} props 包含组件和其他属性
 * @returns {JSX.Element} 如果用户已登录则渲染组件，否则重定向到登录页
 */
const PrivateRoute = ({ children }) => {
  const currentUser = authService.getCurrentUser();
  
  // 检查用户是否已登录
  if (!currentUser || !currentUser.access_token) {
    // 未登录，重定向到登录页
    return <Navigate to="/login" replace />;
  }
  
  // 已登录，渲染受保护的组件
  return children;
};

export default PrivateRoute;
