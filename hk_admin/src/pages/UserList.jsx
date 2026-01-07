import React, { useState, useEffect } from 'react';
import { Table, Form, Input, Select, Button, message, DatePicker, Card, Row, Col, Space, Cascader, Modal, Descriptions, Popconfirm, Tag } from 'antd';
import { getUsers, getFilterOptions, getUser, updateUserStatus } from '../api';
import { SearchOutlined, ReloadOutlined } from '@ant-design/icons';
import { regionData } from '../utils/regionData';

const { Option } = Select;
const { RangePicker } = DatePicker;

const UserList = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [form] = Form.useForm();
  
  const [filterOpts, setFilterOpts] = useState({
      device_models: [],
      system_versions: [],
      app_versions: []
  });

  const fetchData = async (params = {}) => {
    setLoading(true);
    try {
      const values = form.getFieldsValue();
      const { regDateRange, location, ...rest } = values;
       if (regDateRange) {
        rest.date_from = regDateRange[0].format('YYYY-MM-DD');
        rest.date_to = regDateRange[1].format('YYYY-MM-DD');
      }
      
      if (location && location.length > 0) {
          rest.country = location[0];
          rest.province = location[1];
          rest.city = location[2];
          rest.district = location[3];
      }

      const res = await getUsers({
        page: params.current || pagination.current,
        limit: params.pageSize || pagination.pageSize,
        ...rest,
      });
      setData(res.data.data);
      setPagination({
        ...pagination,
        current: res.data.page,
        total: res.data.total,
      });
    } catch (error) {
      console.error(error);
      message.error('Failed to fetch users');
    } finally {
      setLoading(false);
    }
  };
  
  const fetchFilterOpts = async () => {
      try {
          const res = await getFilterOptions();
          setFilterOpts(res.data);
      } catch {
           // ignore
       }
  };

  const [detailVisible, setDetailVisible] = useState(false);
  const [detailData, setDetailData] = useState(null);

  const handleViewDetail = async (id) => {
      try {
          const res = await getUser(id);
          setDetailData(res.data);
          setDetailVisible(true);
      } catch {
          message.error('Load detail failed');
      }
  };

  const handleUpdateStatus = async (status) => {
      try {
          await updateUserStatus(detailData.id, status);
          message.success('Status updated');
          setDetailData({ ...detailData, status });
          fetchData();
      } catch {
          message.error('Update failed');
      }
  };

  useEffect(() => {
    fetchFilterOpts();
    fetchData();
  }, []);

  const handleTableChange = (newPagination) => {
    setPagination(newPagination);
    fetchData({ current: newPagination.current, pageSize: newPagination.pageSize });
  };

  const handleSearch = () => {
    setPagination({ ...pagination, current: 1 });
    fetchData({ current: 1 });
  };
  
  const handleReset = () => {
      form.resetFields();
      handleSearch();
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 60, fixed: 'left' },
    { title: '头像', dataIndex: 'avatar', key: 'avatar', width: 60, render: (text) => text ? <img src={text} alt="avatar" style={{ width: 30, height: 30, borderRadius: '50%' }} /> : '-' },
    { title: '昵称', dataIndex: 'nickname', key: 'nickname', width: 120 },
    { title: '微信ID', dataIndex: 'openid', key: 'openid', width: 150 },
    { title: '活跃状态', dataIndex: 'active_status', key: 'active_status', width: 100 },
    { title: '地区', key: 'location', width: 150, render: (_, r) => `${r.country || ''} ${r.province || ''} ${r.city || ''}` },
    { title: '设备', dataIndex: 'device_model', key: 'device_model', width: 120 },
    { title: '系统', dataIndex: 'system_version', key: 'system_version', width: 100 },
    { title: 'App版本', dataIndex: 'app_version', key: 'app_version', width: 100 },
    { title: '今日下载', dataIndex: 'today_download_count', key: 'today_download_count', width: 100 },
    { title: '累计下载', dataIndex: 'total_download_count', key: 'total_download_count', width: 100 },
    { title: '收藏数', dataIndex: 'favorites_count', key: 'favorites_count', width: 80 },
    { title: '注册时间', dataIndex: 'created_at', key: 'created_at', width: 150 },
    { 
      title: '操作', 
      key: 'action', 
      fixed: 'right',
      width: 80,
      render: (_, record) => <a onClick={() => handleViewDetail(record.id)}>详情</a> 
    },
  ];

  return (
    <div className="page-header-wrapper">
      <Card variant="borderless" className="filter-card" styles={{ body: { paddingBottom: 0 } }}>
        <Form form={form} layout="vertical" onFinish={handleSearch}>
          <Row gutter={16}>
            <Col span={4}>
              <Form.Item name="search" label="搜索">
                <Input placeholder="昵称/ID" />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="active_status" label="活跃度">
                 <Select allowClear placeholder="请选择">
                  <Option value="high">高活跃</Option>
                  <Option value="medium">中活跃</Option>
                  <Option value="low">低活跃</Option>
                  <Option value="lost_general">一般流失</Option>
                  <Option value="lost_serious">严重流失</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="device_model" label="设备型号">
                <Select allowClear placeholder="请选择" showSearch>
                   {filterOpts.device_models.map(v => <Option key={v} value={v}>{v}</Option>)}
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="system_version" label="系统版本">
                 <Select allowClear placeholder="请选择" showSearch>
                   {filterOpts.system_versions.map(v => <Option key={v} value={v}>{v}</Option>)}
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="app_version" label="App版本">
                 <Select allowClear placeholder="请选择" showSearch>
                   {filterOpts.app_versions.map(v => <Option key={v} value={v}>{v}</Option>)}
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="location" label="地区">
                <Cascader options={regionData} placeholder="请选择地区" changeOnSelect />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="regDateRange" label="注册时间">
                <RangePicker style={{ width: '100%' }} />
              </Form.Item>
            </Col>
            <Col span={24} style={{ textAlign: 'right', marginBottom: 24 }}>
                <Space>
                  <Button type="primary" htmlType="submit" icon={<SearchOutlined />}>查询</Button>
                  <Button icon={<ReloadOutlined />} onClick={handleReset}>重置</Button>
                </Space>
            </Col>
          </Row>
        </Form>
      </Card>
      
      <Card variant="borderless" className="table-card" title="用户列表">
        <Table
          columns={columns}
          rowKey="id"
          dataSource={data}
          pagination={pagination}
          loading={loading}
          onChange={handleTableChange}
          scroll={{ x: 'max-content' }}
        />
      </Card>
      
      <Modal
        title="用户详情"
        open={detailVisible}
        onCancel={() => setDetailVisible(false)}
        footer={[
            <Button key="close" onClick={() => setDetailVisible(false)}>关闭</Button>
        ]}
        width={800}
      >
        {detailData && (
            <>
                <Descriptions bordered column={2}>
                    <Descriptions.Item label="头像"><img src={detailData.avatar} style={{width: 50, borderRadius: '50%'}} /></Descriptions.Item>
                    <Descriptions.Item label="昵称">{detailData.nickname}</Descriptions.Item>
                    <Descriptions.Item label="ID">{detailData.id}</Descriptions.Item>
                    <Descriptions.Item label="状态">
                        {detailData.status === 'banned' ? <Tag color="red">禁用</Tag> : (detailData.status === 'restricted' ? <Tag color="orange">限制下载</Tag> : <Tag color="green">正常</Tag>)}
                    </Descriptions.Item>
                    <Descriptions.Item label="地区">{detailData.country} {detailData.province} {detailData.city}</Descriptions.Item>
                    <Descriptions.Item label="设备">{detailData.device_model || '-'}</Descriptions.Item>
                    <Descriptions.Item label="系统">{detailData.system_version || '-'}</Descriptions.Item>
                    <Descriptions.Item label="App版本">{detailData.app_version || '-'}</Descriptions.Item>
                    <Descriptions.Item label="注册时间">{detailData.created_at}</Descriptions.Item>
                    <Descriptions.Item label="最后登录">{detailData.last_login_time}</Descriptions.Item>
                    <Descriptions.Item label="总下载">{detailData.total_download_count || 0}</Descriptions.Item>
                    <Descriptions.Item label="收藏数">{detailData.favorites_count || 0}</Descriptions.Item>
                    <Descriptions.Item label="OpenID" span={2}>{detailData.openid}</Descriptions.Item>
                </Descriptions>
                <div style={{ marginTop: 20 }}>
                    <Space>
                        <Popconfirm title="确定限制访问吗？用户将无法登录App。" onConfirm={() => handleUpdateStatus('banned')}>
                            <Button danger disabled={detailData.status === 'banned'}>限制访问 (Ban)</Button>
                        </Popconfirm>
                        <Popconfirm title="确定限制下载吗？用户将无法下载素材。" onConfirm={() => handleUpdateStatus('restricted')}>
                            <Button type="primary" danger disabled={detailData.status === 'restricted'}>限制下载</Button>
                        </Popconfirm>
                        <Popconfirm title="确定恢复正常吗？" onConfirm={() => handleUpdateStatus('active')}>
                            <Button type="primary" disabled={detailData.status === 'active'}>恢复正常</Button>
                        </Popconfirm>
                    </Space>
                </div>
            </>
        )}
      </Modal>
    </div>
  );
};

export default UserList;
