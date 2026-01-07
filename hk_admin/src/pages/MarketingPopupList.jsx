import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Form, Input, Select, message, Modal, Card, Upload, DatePicker, Row, Col } from 'antd';
import { getMarketingPopups, createMarketingPopup, updateMarketingPopup, deleteMarketingPopup, uploadFile } from '../api';
import { PlusOutlined, UploadOutlined, DeleteOutlined, EditOutlined } from '@ant-design/icons';
import dayjs from 'dayjs';

const { Option } = Select;
const { RangePicker } = DatePicker;

const MarketingPopupList = () => {
  console.log('MarketingPopupList Rendered');
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [form] = Form.useForm();
  const [editingId, setEditingId] = useState(null);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });

  const fetchData = async (params = {}) => {
    setLoading(true);
    try {
      const res = await getMarketingPopups({
        page: params.current || pagination.current,
        limit: params.pageSize || pagination.pageSize,
      });
      setData(res.data.data);
      setPagination({
        ...pagination,
        current: res.data.page,
        total: res.data.total,
      });
    } catch (error) {
      console.error(error);
      // message.error('Failed to fetch popups');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleAdd = () => {
    setEditingId(null);
    form.resetFields();
    setIsModalVisible(true);
  };

  const handleEdit = (record) => {
    setEditingId(record.id);
    form.setFieldsValue({
      ...record,
      timeRange: record.start_time && record.end_time ? [dayjs(record.start_time), dayjs(record.end_time)] : [],
    });
    setIsModalVisible(true);
  };

  const handleDelete = async (id) => {
    Modal.confirm({
      title: '确认删除?',
      onOk: async () => {
        try {
          await deleteMarketingPopup(id);
          message.success('已删除');
          fetchData();
        } catch (error) {
          console.error(error);
          message.error('删除失败');
        }
      },
    });
  };

  const handleOk = async () => {
    try {
      const values = await form.validateFields();
      if (values.timeRange && values.timeRange.length === 2) {
        values.start_time = values.timeRange[0].toDate();
        values.end_time = values.timeRange[1].toDate();
      }
      delete values.timeRange;

      // Extract image url
      if (values.image_file && values.image_file.length > 0) {
         values.image_url = values.image_file[0].response || values.image_file[0].url;
      }
      delete values.image_file;

      if (editingId) {
        await updateMarketingPopup(editingId, values);
        message.success('更新成功');
      } else {
        await createMarketingPopup(values);
        message.success('创建成功');
      }
      setIsModalVisible(false);
      fetchData();
    } catch (error) {
      console.error(error);
      message.error('操作失败');
    }
  };

  const customRequest = async ({ file, onSuccess, onError }) => {
      try {
          const res = await uploadFile(file);
          const url = res.data.url;
          file.response = url;
          file.url = url;
          file.status = 'done';
          onSuccess(url, file);
      } catch (err) {
          message.error('Upload failed');
          onError(err);
      }
  };

  const getUrl = (e) => {
      if (Array.isArray(e)) return e;
      return e && e.fileList;
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '标题', dataIndex: 'title', key: 'title' },
    { title: '图片', dataIndex: 'image_url', key: 'image_url', render: (text) => <img src={text} style={{ height: 50 }} /> },
    { title: '频率', dataIndex: 'frequency', key: 'frequency' },
    { title: '状态', dataIndex: 'status', key: 'status' },
    { 
        title: '操作', 
        key: 'action', 
        width: 200,
        render: (_, record) => (
          <Space>
            <Button icon={<EditOutlined />} onClick={() => handleEdit(record)}>编辑</Button>
            <Button icon={<DeleteOutlined />} danger onClick={() => handleDelete(record.id)}>删除</Button>
          </Space>
        )
    },
  ];

  return (
    <div className="page-header-wrapper">
      <Card title="营销弹窗管理" extra={<Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增弹窗</Button>}>
        <Table columns={columns} dataSource={data} rowKey="id" loading={loading} pagination={pagination} onChange={(p) => fetchData({ current: p.current })} />
      </Card>

      <Modal
        title={editingId ? '编辑弹窗' : '新增弹窗'}
        open={isModalVisible}
        onOk={handleOk}
        onCancel={() => setIsModalVisible(false)}
        width={800}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="title" label="标题" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          
          <Form.Item name="image_file" label="弹窗图片" getValueFromEvent={getUrl} rules={[{ required: !editingId }]}>
             <Upload customRequest={customRequest} listType="picture-card" maxCount={1}>
                <div><PlusOutlined /><div style={{ marginTop: 8 }}>上传</div></div>
             </Upload>
          </Form.Item>
          {/* Hidden field to store existing URL if editing without changing */}
          <Form.Item name="image_url" noStyle><Input type="hidden" /></Form.Item>

          <Form.Item name="target_url" label="跳转链接">
            <Input placeholder="http://... 或 app schema" />
          </Form.Item>
          
          <Row gutter={16}>
             <Col span={12}>
                <Form.Item name="frequency" label="弹窗频率" initialValue="daily">
                    <Select>
                        <Option value="once">仅一次</Option>
                        <Option value="daily">每天一次</Option>
                        <Option value="always">每次启动</Option>
                    </Select>
                </Form.Item>
             </Col>
             <Col span={12}>
                <Form.Item name="status" label="状态" initialValue="active">
                    <Select>
                        <Option value="active">启用</Option>
                        <Option value="inactive">停用</Option>
                    </Select>
                </Form.Item>
             </Col>
          </Row>

          <Form.Item name="timeRange" label="有效期">
             <RangePicker showTime />
          </Form.Item>

          <Form.Item name="target_user_type" label="投放人群" initialValue="all">
             <Select>
                <Option value="all">全部用户</Option>
                <Option value="vip">VIP用户</Option>
                <Option value="free">免费用户</Option>
             </Select>
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default MarketingPopupList;
