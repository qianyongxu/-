import React, { useState } from 'react';
import { Layout, Menu, Breadcrumb, Avatar, Dropdown, Space } from 'antd';
import { 
  UserOutlined, 
  FileOutlined, 
  TagsOutlined, 
  AppstoreOutlined, 
  MenuUnfoldOutlined, 
  MenuFoldOutlined,
  LogoutOutlined,
  MessageOutlined,
  BookOutlined,
  NotificationOutlined
} from '@ant-design/icons';
import { Link, Outlet, useLocation } from 'react-router-dom';

const { Header, Content, Sider } = Layout;

const MainLayout = () => {
  const location = useLocation();
  const [collapsed, setCollapsed] = useState(false);

  const menuItems = [
    {
      key: '/materials',
      icon: <FileOutlined />,
      label: <Link to="/materials">素材管理</Link>,
    },
    {
      key: '/tags',
      icon: <TagsOutlined />,
      label: <Link to="/tags">标签管理</Link>,
    },
    {
      key: '/software',
      icon: <AppstoreOutlined />,
      label: <Link to="/software">软件管理</Link>,
    },
    {
      key: '/users',
      icon: <UserOutlined />,
      label: <Link to="/users">用户管理</Link>,
    },
    {
      key: '/feedback',
      icon: <MessageOutlined />,
      label: <Link to="/feedback">意见反馈</Link>,
    },
    {
      key: '/help-guides',
      icon: <BookOutlined />,
      label: <Link to="/help-guides">帮助指南</Link>,
    },
    {
      key: '/marketing-popups',
      icon: <NotificationOutlined />,
      label: <Link to="/marketing-popups">营销弹窗</Link>,
    },
  ];

  const userMenu = {
    items: [
      {
        key: 'logout',
        label: '退出登录',
        icon: <LogoutOutlined />,
      },
    ],
  };

  const getBreadcrumbItems = () => {
    const pathSnippets = location.pathname.split('/').filter((i) => i);
    const breadcrumbNameMap = {
      materials: '素材管理',
      tags: '标签管理',
      software: '软件管理',
      users: '用户管理',
      upload: '上传素材',
      feedback: '意见反馈',
      'help-guides': '帮助指南',
      'marketing-popups': '营销弹窗',
    };
    
    const extraBreadcrumbItems = pathSnippets.map((_, index) => {
      const url = `/${pathSnippets.slice(0, index + 1).join('/')}`;
      const name = breadcrumbNameMap[pathSnippets[index]] || pathSnippets[index];
      return {
        title: name,
        key: url,
      };
    });
    
    return [
      { title: '首页', key: '/' },
    ].concat(extraBreadcrumbItems);
  };

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider trigger={null} collapsible collapsed={collapsed}>
        <div className="logo">HK Admin</div>
        <Menu 
          theme="dark" 
          mode="inline" 
          selectedKeys={[location.pathname]} 
          items={menuItems} 
        />
      </Sider>
      <Layout className="site-layout">
        <Header style={{ padding: 0, background: '#fff', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          {React.createElement(collapsed ? MenuUnfoldOutlined : MenuFoldOutlined, {
            className: 'trigger',
            onClick: () => setCollapsed(!collapsed),
          })}
          <div style={{ marginRight: 24 }}>
            <Dropdown menu={userMenu}>
              <Space style={{ cursor: 'pointer' }}>
                <Avatar icon={<UserOutlined />} />
                <span>管理员</span>
              </Space>
            </Dropdown>
          </div>
        </Header>
        <Content style={{ margin: '24px 24px', padding: 0, minHeight: 280 }}>
           <Outlet />
        </Content>
      </Layout>
    </Layout>
  );
};

export default MainLayout;
