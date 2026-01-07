import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Form, Input, Select, message, Modal, Card, Row, Col } from 'antd';
import { getTags, createTag, updateTagStatus } from '../api';
import { PlusOutlined, SearchOutlined, ReloadOutlined } from '@ant-design/icons';

const { Option } = Select;

const TagList = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [form] = Form.useForm();
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [createForm] = Form.useForm();

  const fetchData = async (params = {}) => {
    setLoading(true);
    try {
      const res = await getTags({
        page: params.current || pagination.current,
        limit: params.pageSize || pagination.pageSize,
        ...form.getFieldsValue(),
      });
      setData(res.data.data);
      setPagination({
        ...pagination,
        current: res.data.page,
        total: res.data.total,
      });
    } catch (error) {
      message.error('Failed to fetch tags');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
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

  const handleStatusChange = async (id, status) => {
    try {
      await updateTagStatus(id, status);
      message.success('Status updated');
      fetchData();
    } catch (error) {
      message.error('Update failed');
    }
  };

  const handleCreate = async () => {
    try {
      const values = await createForm.validateFields();
      await createTag(values);
      message.success('Tag created');
      setIsModalVisible(false);
      createForm.resetFields();
      fetchData();
    } catch (error) {
      // Form validation error or API error
    }
  };

  const columns = [
    { title: '标签名称', dataIndex: 'name', key: 'name' },
    { title: '关联素材数', dataIndex: 'material_count', key: 'material_count', render: (text) => text || 0 },
    { title: '关联素材曝光数', dataIndex: 'exposure_sum', key: 'exposure_sum' },
    { title: '关联素材点击数', dataIndex: 'click_sum', key: 'click_sum' },
    { title: '关联素材下载数', dataIndex: 'download_sum', key: 'download_sum' },
    { title: '关联素材分享数', dataIndex: 'share_sum', key: 'share_sum' },
    { title: '创建时间', dataIndex: 'created_at', key: 'created_at' },
    { title: '状态', dataIndex: 'status', key: 'status' },
    {
      title: '操作',
      key: 'action',
      render: (_, record) => (
        <Space size="middle">
          {record.status === 'on_shelf' ? (
            <a style={{ color: 'red' }} onClick={() => handleStatusChange(record.id, 'off_shelf')}>下架</a>
          ) : (
            <a onClick={() => handleStatusChange(record.id, 'on_shelf')}>上架</a>
          )}
        </Space>
      ),
    },
  ];

  return (
    <div className="page-header-wrapper">
      <Card variant="borderless" className="filter-card" styles={{ body: { paddingBottom: 0 } }}>
        <Form form={form} layout="vertical" onFinish={handleSearch}>
          <Row gutter={16}>
            <Col span={4}>
              <Form.Item name="search" label="搜索">
                <Input placeholder="标签名称" />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="status" label="状态">
                <Select allowClear placeholder="请选择状态">
                  <Option value="on_shelf">上架</Option>
                  <Option value="off_shelf">下架</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={16} style={{ textAlign: 'right', marginBottom: 24 }}>
                <Space>
                    <Button type="primary" htmlType="submit" icon={<SearchOutlined />}>查询</Button>
                    <Button icon={<ReloadOutlined />} onClick={handleReset}>重置</Button>
                </Space>
            </Col>
          </Row>
        </Form>
      </Card>

      <Card variant="borderless" className="table-card" 
        title="标签列表" 
        extra={<Button type="primary" icon={<PlusOutlined />} onClick={() => setIsModalVisible(true)}>添加标签</Button>}
      >
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
      
      <Modal title="添加标签" open={isModalVisible} onOk={handleCreate} onCancel={() => setIsModalVisible(false)}>
        <Form form={createForm} layout="vertical">
          <Form.Item name="name" label="标签名称" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default TagList;
