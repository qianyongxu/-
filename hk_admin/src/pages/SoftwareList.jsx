import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Form, Input, Select, message, Modal, Card, Row, Col, Upload } from 'antd';
import { getSoftware, createSoftware, updateSoftware, updateSoftwareStatus, uploadFile } from '../api';
import { PlusOutlined, SearchOutlined, ReloadOutlined, UploadOutlined, EditOutlined } from '@ant-design/icons';

const { Option } = Select;

const SoftwareList = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [form] = Form.useForm();
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [createForm] = Form.useForm();
  const [editingId, setEditingId] = useState(null);

  const fetchData = async (params = {}) => {
    setLoading(true);
    try {
      const res = await getSoftware({
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
      console.error(error);
      message.error('Failed to fetch software');
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
      await updateSoftwareStatus(id, status);
      message.success('Status updated');
      fetchData();
    } catch (error) {
      console.error(error);
      message.error('Update failed');
    }
  };

  const customRequestLogo = async ({ file, onSuccess, onError }) => {
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

  const handleEdit = (record) => {
      setEditingId(record.id);
      createForm.setFieldsValue({
          ...record,
          logo: record.logo ? [{ uid: '-1', name: 'logo.png', status: 'done', url: record.logo, response: record.logo }] : []
      });
      setIsModalVisible(true);
  };

  const handleAdd = () => {
      setEditingId(null);
      createForm.resetFields();
      setIsModalVisible(true);
  };

  const handleOk = async () => {
    try {
      const values = await createForm.validateFields();
      
      const logoList = values.logo;
      let logoUrl = '';
      if (logoList && logoList.length > 0) {
          logoUrl = logoList[0].response || logoList[0].url;
      }

      const payload = { ...values, logo: logoUrl };

      if (editingId) {
          await updateSoftware(editingId, payload);
          message.success('Software updated');
      } else {
          await createSoftware(payload);
          message.success('Software created');
      }
      
      setIsModalVisible(false);
      createForm.resetFields();
      fetchData();
    } catch (error) {
      console.error(error);
      message.error('Operation failed');
    }
  };

  const columns = [
    { title: 'Logo', dataIndex: 'logo', key: 'logo', render: (text) => text ? <img src={text} alt="logo" style={{ width: 30 }} /> : '-' },
    { title: '软件名称', dataIndex: 'name', key: 'name' },
    { title: '支持格式', dataIndex: 'supported_formats', key: 'supported_formats' },
    { title: '源文件格式', dataIndex: 'source_format', key: 'source_format' },
    { title: '更新时间', dataIndex: 'updated_at', key: 'updated_at' },
    { title: '状态', dataIndex: 'status', key: 'status' },
    {
      title: '操作',
      key: 'action',
      render: (_, record) => (
        <Space size="middle">
          <Button type="link" icon={<EditOutlined />} onClick={() => handleEdit(record)}>编辑</Button>
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
      <Card variant="borderless" className="filter-card">
        <Form form={form} layout="vertical" onFinish={handleSearch}>
          <Row gutter={{ xs: 8, sm: 16, md: 24, lg: 32 }}>
            <Col span={6}>
              <Form.Item name="search" label="搜索">
                <Input placeholder="软件名称" />
              </Form.Item>
            </Col>
            <Col span={6}>
              <Form.Item name="status" label="状态">
                <Select allowClear placeholder="请选择状态">
                  <Option value="on_shelf">上架</Option>
                  <Option value="off_shelf">下架</Option>
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
      
      <Card variant="borderless" className="table-card" 
        title="软件列表"
        extra={<Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>添加软件</Button>}
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
      
      <Modal title={editingId ? "编辑软件" : "添加软件"} open={isModalVisible} onOk={handleOk} onCancel={() => setIsModalVisible(false)}>
        <Form form={createForm} layout="vertical">
          <Form.Item name="name" label="软件名称" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item name="logo" label="Logo" getValueFromEvent={getUrl}>
             <Upload customRequest={customRequestLogo} listType="picture" maxCount={1}>
                 <Button icon={<UploadOutlined />}>上传Logo</Button>
             </Upload>
          </Form.Item>
          <Form.Item name="supported_formats" label="支持的格式">
            <Input placeholder="如: psd,ai" />
          </Form.Item>
          <Form.Item name="source_format" label="源文件格式">
            <Input />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default SoftwareList;
