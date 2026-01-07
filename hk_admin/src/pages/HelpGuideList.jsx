import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Form, Input, InputNumber, message, Modal, Card, Upload, Row, Col } from 'antd';
import { getHelpGuides, createHelpGuide, updateHelpGuide, deleteHelpGuide, uploadFile } from '../api';
import { PlusOutlined, UploadOutlined, DeleteOutlined, EditOutlined } from '@ant-design/icons';

const { TextArea } = Input;

const HelpGuideList = () => {
  console.log('HelpGuideList Component Rendered');
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [form] = Form.useForm();
  const [editingId, setEditingId] = useState(null);

  const fetchData = async () => {
    setLoading(true);
    try {
      const res = await getHelpGuides(); // Admin gets all
      setData(res.data);
    } catch (error) {
      console.error(error);
      // message.error('Failed to fetch guides');
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
    form.setFieldsValue(record);
    setIsModalVisible(true);
  };

  const handleDelete = async (id) => {
    Modal.confirm({
      title: '确认删除?',
      onOk: async () => {
        try {
          await deleteHelpGuide(id);
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
      if (editingId) {
        await updateHelpGuide(editingId, values);
        message.success('更新成功');
      } else {
        await createHelpGuide(values);
        message.success('创建成功');
      }
      setIsModalVisible(false);
      fetchData();
    } catch (error) {
      console.error(error);
      message.error('操作失败');
    }
  };

  const insertImage = async ({ file, onSuccess, onError }) => {
     try {
         const res = await uploadFile(file);
         const url = res.data.url;
         const currentContent = form.getFieldValue('content') || '';
         // Insert HTML image tag
         const newContent = currentContent + `\n<img src="${url}" style="width:100%; border-radius: 8px; margin: 8px 0;" />\n`;
         form.setFieldsValue({ content: newContent });
         message.success('图片已插入内容末尾');
         onSuccess(url);
     } catch (e) {
         message.error('上传失败');
         onError(e);
     }
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80 },
    { title: '标题', dataIndex: 'title', key: 'title' },
    { title: '排序', dataIndex: 'sort_order', key: 'sort_order', width: 100 },
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
      <Card title="帮助与指南" extra={<Button type="primary" icon={<PlusOutlined />} onClick={handleAdd}>新增指南</Button>}>
        <Table columns={columns} dataSource={data} rowKey="id" loading={loading} />
      </Card>

      <Modal
        title={editingId ? '编辑指南' : '新增指南'}
        open={isModalVisible}
        onOk={handleOk}
        onCancel={() => setIsModalVisible(false)}
        width={800}
      >
        <Form form={form} layout="vertical">
          <Form.Item name="title" label="标题" rules={[{ required: true }]}>
            <Input />
          </Form.Item>
          <Form.Item label="内容插图">
             <Upload customRequest={insertImage} showUploadList={false}>
                <Button icon={<UploadOutlined />}>上传并插入图片</Button>
             </Upload>
             <span style={{ marginLeft: 8, color: '#999', fontSize: 12 }}>点击上传后会自动插入图片代码到内容末尾</span>
          </Form.Item>
          <Form.Item name="content" label="内容 (支持HTML)" rules={[{ required: true }]}>
            <TextArea rows={15} />
          </Form.Item>
          <Form.Item name="sort_order" label="排序权重">
            <InputNumber min={0} />
          </Form.Item>
        </Form>
      </Modal>
    </div>
  );
};

export default HelpGuideList;
