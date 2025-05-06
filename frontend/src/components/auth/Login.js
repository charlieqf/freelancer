import React, { useState } from 'react';
import authService from '../../services/authService';

/**
 * 用户登录组件
 * 提供简洁的表单，允许用户输入用户名和密码进行登录
 */
const Login = ({ onLoginSuccess }) => {
  // 表单状态
  const [formData, setFormData] = useState({
    username: '',
    password: ''
  });

  // 加载和错误状态
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  
  /**
   * 处理输入变化
   */
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
    // 清除上一次的错误
    setError('');
  };

  /**
   * 处理表单提交
   */
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // 表单验证
    if (!formData.username || !formData.password) {
      setError('请输入用户名和密码');
      return;
    }
    
    setIsLoading(true);
    setError('');
    
    try {
      // 调用登录API
      await authService.login(formData.username, formData.password);
      
      // 登录成功回调
      if (onLoginSuccess) {
        onLoginSuccess();
      }
    } catch (error) {
      setError(error.message || '登录失败，请检查用户名和密码');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-form-wrapper">
        <h2>飞行员登录</h2>
        
        {error && <div className="error-message">{error}</div>}
        
        <form onSubmit={handleSubmit} className="login-form">
          <div className="form-group">
            <label htmlFor="username">用户名</label>
            <input
              type="text"
              id="username"
              name="username"
              value={formData.username}
              onChange={handleChange}
              disabled={isLoading}
              placeholder="输入您的用户名"
            />
          </div>
          
          <div className="form-group">
            <label htmlFor="password">密码</label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              disabled={isLoading}
              placeholder="输入您的密码"
            />
          </div>
          
          <button 
            type="submit" 
            className="login-button"
            disabled={isLoading}
          >
            {isLoading ? '登录中...' : '登录'}
          </button>
        </form>
        
        <div className="form-footer">
          <p>
            还没有账号？ <a href="/register">立即注册</a>
          </p>
          <p>
            <a href="/forgot-password">忘记密码？</a>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Login;
