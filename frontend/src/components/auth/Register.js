import React, { useState, useEffect } from 'react';
import authService from '../../services/authService';

/**
 * 用户注册组件
 * 提供表单让新用户创建账户并选择初始势力
 */
const Register = ({ onRegisterSuccess }) => {
  // 表单状态
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
    factionId: 1 // 默认为地球联邦
  });

  // 势力选项
  const [factions, setFactions] = useState([
    { id: 1, name: '地球联邦', description: '人类的主要政府组织，拥有强大的军事力量和先进技术' },
    { id: 2, name: '半人马工业联盟', description: '以商业和工业为主的独立联盟，经济发达' },
    { id: 3, name: '天狼星自由联盟', description: '崇尚自由和独立的星际组织，贸易网络广泛' },
    { id: 4, name: '猎户座前哨', description: '边缘区域的探险者和殖民者，资源丰富但危险' }
  ]);

  // 加载和错误状态
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const [generalError, setGeneralError] = useState('');

  /**
   * 处理输入变化
   */
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({
      ...formData,
      [name]: value
    });
    
    // 清除该字段的错误
    if (errors[name]) {
      setErrors({
        ...errors,
        [name]: ''
      });
    }
    
    // 清除通用错误
    if (generalError) {
      setGeneralError('');
    }
  };

  /**
   * 验证表单
   */
  const validateForm = () => {
    const newErrors = {};
    
    // 用户名验证
    if (!formData.username || formData.username.length < 3) {
      newErrors.username = '用户名至少需要3个字符';
    } else if (formData.username.length > 20) {
      newErrors.username = '用户名不能超过20个字符';
    } else if (!/^[a-zA-Z0-9_]+$/.test(formData.username)) {
      newErrors.username = '用户名只能包含字母、数字和下划线';
    }
    
    // 邮箱验证
    if (!formData.email) {
      newErrors.email = '请输入电子邮箱';
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = '请输入有效的电子邮箱地址';
    }
    
    // 密码验证
    if (!formData.password) {
      newErrors.password = '请输入密码';
    } else if (formData.password.length < 8) {
      newErrors.password = '密码至少需要8个字符';
    } else if (!/[A-Z]/.test(formData.password)) {
      newErrors.password = '密码需要包含至少一个大写字母';
    } else if (!/[a-z]/.test(formData.password)) {
      newErrors.password = '密码需要包含至少一个小写字母';
    } else if (!/[0-9]/.test(formData.password)) {
      newErrors.password = '密码需要包含至少一个数字';
    }
    
    // 确认密码验证
    if (formData.password !== formData.confirmPassword) {
      newErrors.confirmPassword = '两次输入的密码不匹配';
    }
    
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  /**
   * 处理表单提交
   */
  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // 验证表单
    if (!validateForm()) {
      return;
    }
    
    setIsLoading(true);
    setGeneralError('');
    
    try {
      // 调用注册API
      await authService.register(
        formData.username,
        formData.email,
        formData.password,
        parseInt(formData.factionId, 10)
      );
      
      // 注册成功回调
      if (onRegisterSuccess) {
        onRegisterSuccess();
      }
    } catch (error) {
      setGeneralError(error.message || '注册失败，请稍后再试');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="register-container">
      <div className="register-form-wrapper">
        <h2>新飞行员注册</h2>
        
        {generalError && <div className="error-message">{generalError}</div>}
        
        <form onSubmit={handleSubmit} className="register-form">
          <div className="form-group">
            <label htmlFor="username">用户名 *</label>
            <input
              type="text"
              id="username"
              name="username"
              value={formData.username}
              onChange={handleChange}
              disabled={isLoading}
              placeholder="创建您的用户名"
              className={errors.username ? 'error' : ''}
            />
            {errors.username && <span className="error-text">{errors.username}</span>}
          </div>
          
          <div className="form-group">
            <label htmlFor="email">电子邮箱 *</label>
            <input
              type="email"
              id="email"
              name="email"
              value={formData.email}
              onChange={handleChange}
              disabled={isLoading}
              placeholder="输入您的电子邮箱地址"
              className={errors.email ? 'error' : ''}
            />
            {errors.email && <span className="error-text">{errors.email}</span>}
          </div>
          
          <div className="form-group">
            <label htmlFor="password">密码 *</label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              disabled={isLoading}
              placeholder="创建强密码"
              className={errors.password ? 'error' : ''}
            />
            {errors.password && <span className="error-text">{errors.password}</span>}
            <small className="password-hint">密码需要至少8个字符，包含大小写字母和数字</small>
          </div>
          
          <div className="form-group">
            <label htmlFor="confirmPassword">确认密码 *</label>
            <input
              type="password"
              id="confirmPassword"
              name="confirmPassword"
              value={formData.confirmPassword}
              onChange={handleChange}
              disabled={isLoading}
              placeholder="再次输入密码"
              className={errors.confirmPassword ? 'error' : ''}
            />
            {errors.confirmPassword && <span className="error-text">{errors.confirmPassword}</span>}
          </div>
          
          <div className="form-group">
            <label htmlFor="factionId">选择初始势力</label>
            <select
              id="factionId"
              name="factionId"
              value={formData.factionId}
              onChange={handleChange}
              disabled={isLoading}
            >
              {factions.map(faction => (
                <option key={faction.id} value={faction.id}>
                  {faction.name}
                </option>
              ))}
            </select>
            <div className="faction-description">
              {factions.find(f => f.id === parseInt(formData.factionId, 10))?.description}
            </div>
          </div>
          
          <button 
            type="submit" 
            className="register-button"
            disabled={isLoading}
          >
            {isLoading ? '注册中...' : '注册'}
          </button>
        </form>
        
        <div className="form-footer">
          <p>
            已有账号？ <a href="/login">立即登录</a>
          </p>
        </div>
      </div>
    </div>
  );
};

export default Register;
