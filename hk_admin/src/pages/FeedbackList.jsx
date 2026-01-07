import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Form, Input, Select, message, Card, Row, Col, Modal } from 'antd';
import { getFeedbacks, updateFeedback } from '../api';
import { SearchOutlined, ReloadOutlined } from '@ant-design/icons';

const { Option } = Select;

const FeedbackList = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [form] = Form.useForm();

  const fetchData = async (params = {}) => {
    setLoading(true);
    try {
      const res = await getFeedbacks({
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
      message.error('Failed to fetch feedback');
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
      await updateFeedback(id, { status });
      message.success('Status updated');
      fetchData();
    } catch (error) {
      message.error('Update failed');
    }
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id' },
    { title: '用户ID', dataIndex: 'user_id', key: 'user_id' },
    { title: '内容', dataIndex: 'content', key: 'content', width: 300, ellipsis: true },
    { title: '联系方式', dataIndex: 'contact', key: 'contact' },
    { title: '图片', dataIndex: 'images', key: 'images', render: (imgs) => imgs && imgs.length > 0 ? imgs.map((img, i) => <a key={i} href={img} target="_blank">图{i+1} </a>) : '-' },
    { title: '提交时间', dataIndex: 'createdAt', key: 'createdAt' },
    { title: '状态', dataIndex: 'status', key: 'status' },
    {
      title: '操作',
      key: 'action',
      render: (_, record) => (
        <Space size="middle">
          {record.status === 'pending' ? (
            <a onClick={() => handleStatusChange(record.id, 'processed')}>标记已处理</a>
          ) : (
            <span style={{ color: 'green' }}>已处理</span>
          )}
        </Space>
      ),
    },
  ];

  return (
    <div className="page-header-wrapper">
      <Card variant="borderless" className="filter-card">
        <Form form={form} layout="vertical" onFinish={handleSearch}>
          <Row gutter={{ xs: 8, sm: 16, md: 24, lg: 32 }}>
            <Col span={6}>
              <Form.Item name="status" label="状态">
                <Select allowClear placeholder="请选择状态">
                  <Option value="pending">待处理</Option>
                  <Option value="processed">已处理</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={6} style={{ display: 'flex', alignItems: 'flex-end', paddingBottom: '24px' }}>
                <Space>
                    <Button type="primary" htmlType="submit" icon={<SearchOutlined />}>查询</Button>
                    <Button icon={<ReloadOutlined />} onClick={handleReset}>重置</Button>
                </Space>
            </Col>
          </Row>
        </Form>
      </Card>
      
      <Card variant="borderless" className="table-card" title="意见反馈列表">
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
    </div>
  );
};

export default FeedbackList;
