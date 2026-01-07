import React, { useState, useEffect } from 'react';
import { Table, Button, Space, Form, Input, Select, DatePicker, message, Card, Row, Col, Modal, Upload, Descriptions, Tag as AntTag, Popconfirm } from 'antd';
import { getMaterials, updateMaterialStatus, getTags, getSoftware, createMaterial, uploadFile, getMaterial, updateMaterial } from '../api';
import { PlusOutlined, SearchOutlined, ReloadOutlined, UploadOutlined } from '@ant-design/icons';

const { Option } = Select;
const { RangePicker } = DatePicker;

const categoryMap = {
  brush: '笔刷',
  lineart: '线稿',
  font: '字体',
  '3d': '3D',
  texture: '纹理',
  illustration: '插图',
  mockup: 'Mockup',
  template: 'Template'
};

const statusMap = {
  on_shelf: '上架',
  off_shelf: '下架'
};

const MaterialList = () => {
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [pagination, setPagination] = useState({ current: 1, pageSize: 10, total: 0 });
  const [form] = Form.useForm();
  
  // Filter Options
  const [tags, setTags] = useState([]);
  const [software, setSoftware] = useState([]);

  // Upload Modal State
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [uploadForm] = Form.useForm();
  const [uploadLoading, setUploadLoading] = useState(false);
  const [editingId, setEditingId] = useState(null);

  // Detail Modal State
  const [detailVisible, setDetailVisible] = useState(false);
  const [detailData, setDetailData] = useState(null);

  const fetchOptions = async () => {
    try {
      const tagRes = await getTags({ limit: 100 });
      setTags(tagRes.data.data);
      const softRes = await getSoftware({ limit: 100 });
      setSoftware(softRes.data.data);
    } catch {
      // ignore
    }
  };

  const fetchData = async (params = {}) => {
    setLoading(true);
    try {
      // Handle Date Range
      const values = form.getFieldsValue();
      const { dateRange, ...rest } = values;
      if (dateRange) {
        rest.date_from = dateRange[0].format('YYYY-MM-DD');
        rest.date_to = dateRange[1].format('YYYY-MM-DD');
      }

      const res = await getMaterials({
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
    } catch {
      message.error('Failed to fetch materials');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOptions();
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
  }

  const handleStatusChange = async (id, status) => {
    try {
      await updateMaterialStatus(id, status);
      message.success('Status updated');
      fetchData();
    } catch {
      message.error('Update failed');
    }
  };

  const handleViewDetail = async (id) => {
    try {
      const res = await getMaterial(id);
      setDetailData(res.data);
      setDetailVisible(true);
    } catch {
      message.error('Load failed');
    }
  };

  const handleEdit = (record) => {
    setEditingId(record.id);
    uploadForm.setFieldsValue({
        title: record.title,
        category: record.category,
        tags: record.Tags?.map(t => t.name),
        software_ids: record.Softwares?.map(s => s.id),
        preview_url: record.preview_url ? [{ 
            uid: '-1', 
            name: 'preview.png', 
            status: 'done', 
            url: record.preview_url,
            response: record.preview_url 
        }] : [],
        file_url: record.Files && record.Files.length > 0 ? record.Files.map((f, i) => ({
            uid: i,
            name: f.name,
            status: 'done',
            url: f.url,
            response: f.url,
            originalSize: f.size
        })) : (record.file_url ? [{ 
            uid: '-1', 
            name: 'file', 
            status: 'done', 
            url: record.file_url,
            response: record.file_url 
        }] : [])
    });
    setIsModalVisible(true);
  };

  const handleModalCancel = () => {
      setIsModalVisible(false);
      setEditingId(null);
      uploadForm.resetFields();
  };

  // Upload Logic
  const handleSubmit = async () => {
      try {
          const values = await uploadForm.validateFields();
          
          // Extract actual URL from fileList with fallback
          const getFileUrl = (fileList) => {
              if (!fileList || fileList.length === 0) return null;
              const file = fileList[0];
              return file.response || file.url; // Try response first, then url
          };

          const previewFile = getFileUrl(values.preview_url);
          // Handle multiple files
          // Fix: values.file_url might be the array itself (from getValueFromEvent) or an object
          const rawFiles = values.file_url;
          const fileList = Array.isArray(rawFiles) ? rawFiles : (rawFiles?.fileList || []);
          
          const files = fileList.map(f => ({
              name: f.name,
              url: f.response || f.url,
              size: f.originalSize || (f.size ? (f.size / 1024 / 1024).toFixed(2) + 'MB' : 'Unknown'),
              format: f.name.split('.').pop(),
              preview_url: '' // Optional
          }));

          // Legacy single file fallback
          const materialFile = files.length > 0 ? files[0].url : null;

          if (!previewFile) {
              message.error('预览图未上传完成或上传失败');
              return;
          }
          if (!materialFile) {
              message.error('素材文件未上传完成或上传失败');
              return;
          }

          setUploadLoading(true);
          const payload = {
              ...values,
              preview_url: previewFile,
              file_url: materialFile,
              files: files
          };

          if (editingId) {
              await updateMaterial(editingId, payload);
              message.success('Material updated successfully');
          } else {
              await createMaterial(payload);
              message.success('Material created successfully');
          }
          
          handleModalCancel();
          fetchData();
      } catch (error) {
          console.error(error);
          message.error('Operation failed');
      } finally {
          setUploadLoading(false);
      }
  };

  const handleUploadCommon = async (file, onSuccess, onError) => {
      try {
          const res = await uploadFile(file);
          const url = res.data.url;
          
          file.response = url;
          file.url = url;
          file.status = 'done';
          
          onSuccess(url, file);
          return url;
      } catch (err) {
          console.error("Upload error:", err);
          const errorMsg = err.response?.data?.message || err.message || 'Upload failed';
          message.error(`上传失败: ${errorMsg}`);
          onError(err);
          throw err;
      }
  };

  const customRequestPreview = async ({ file, onSuccess, onError }) => {
      await handleUploadCommon(file, onSuccess, onError);
  };

  const customRequestFile = async ({ file, onSuccess, onError }) => {
      try {
          await handleUploadCommon(file, onSuccess, onError);
          
          const ext = file.name.split('.').pop().toLowerCase();
          // Find all softwares that support this extension
          const matchedSoftwares = software.filter(s => s.supported_formats && s.supported_formats.includes(ext));
          
          if (matchedSoftwares.length > 0) {
              const ids = matchedSoftwares.map(s => s.id);
              // Merge with existing selection if any (optional, usually overwrite or append)
              // Here we overwrite or append? Let's append to be safe or overwrite? 
              // Usually auto-detect implies "this is what it is". 
              // But if user manually selected something, maybe we shouldn't clear it.
              // Let's just set it to the detected ones for now as it's cleaner.
              uploadForm.setFieldsValue({ software_ids: ids });
              message.info(`自动识别软件: ${matchedSoftwares.map(s => s.name).join(', ')}`);
          }
      } catch {
          // ignore
      }
  };

  const getUrl = (e) => {
      if (Array.isArray(e)) return e;
      // When customRequest calls onSuccess, the file status is 'done'
      // We return the fileList directly, and the validator will extract the URL
      return e && e.fileList;
  };

  const columns = [
    { title: 'ID', dataIndex: 'id', key: 'id', width: 80, fixed: 'left', render: (text) => `HK-${text}` },
    { 
        title: '预览图', 
        dataIndex: 'preview_url', 
        key: 'preview_url', 
        width: 80, 
        render: (text) => text ? (
            <img 
                src={text} 
                alt="preview" 
                style={{ width: 50, height: 50, objectFit: 'cover', borderRadius: 4 }} 
                onError={(e) => { e.target.onerror = null; e.target.src = 'https://via.placeholder.com/50?text=Error'; }}
            />
        ) : '-' 
    },
    { title: '名称', dataIndex: 'title', key: 'title', width: 150 },
    { title: '分类', dataIndex: 'category', key: 'category', width: 100, render: (text) => categoryMap[text] || text },
    { title: '标签', dataIndex: 'Tags', key: 'tags', width: 150, render: (tags) => tags?.map(t => t.name).join(', ') },
    { title: '支持软件', dataIndex: 'Softwares', key: 'softwares', width: 150, render: (s) => s?.map(soft => soft.name).join(', ') },
    { title: '文件大小', dataIndex: 'file_size', key: 'file_size', width: 100 },
    { title: '曝光量', dataIndex: 'exposure_count', key: 'exposure_count', width: 80 },
    { title: '点击量', dataIndex: 'click_count', key: 'click_count', width: 80 },
    { title: '点击率', dataIndex: 'click_rate', key: 'click_rate', width: 80 },
    { title: '下载量', dataIndex: 'download_count', key: 'download_count', width: 80 },
    { title: '下载率', dataIndex: 'download_rate', key: 'download_rate', width: 80 },
    { title: '分享量', dataIndex: 'share_count', key: 'share_count', width: 80 },
    { title: '上架时间', dataIndex: 'created_at', key: 'created_at', width: 150 },
    { title: '状态', dataIndex: 'status', key: 'status', width: 80, render: (text) => statusMap[text] || text },
    {
      title: '操作',
      key: 'action',
      fixed: 'right',
      width: 180,
      render: (_, record) => (
        <Space size="middle">
          <a onClick={() => handleViewDetail(record.id)}>详情</a>
          <a onClick={() => handleEdit(record)}>编辑</a>
          {record.status === 'on_shelf' ? (
            <Popconfirm title="确定下架吗？" onConfirm={() => handleStatusChange(record.id, 'off_shelf')}>
                <a style={{ color: 'red' }}>下架</a>
            </Popconfirm>
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
                <Input placeholder="请输入名称" />
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="category" label="分类">
                <Select allowClear placeholder="请选择">
                   <Option value="brush">笔刷</Option>
                   <Option value="lineart">线稿</Option>
                   <Option value="font">字体</Option>
                   <Option value="3d">3D</Option>
                   <Option value="texture">纹理</Option>
                   <Option value="illustration">插图</Option>
                   <Option value="mockup">Mockup</Option>
                   <Option value="template">Template</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="tag_id" label="标签">
                <Select allowClear showSearch optionFilterProp="children" placeholder="请选择">
                  {tags.map(t => <Option key={t.id} value={t.id}>{t.name}</Option>)}
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="software_id" label="软件">
                <Select allowClear placeholder="请选择">
                  {software.map(s => <Option key={s.id} value={s.id}>{s.name}</Option>)}
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="status" label="状态">
                <Select allowClear placeholder="请选择">
                  <Option value="on_shelf">上架</Option>
                  <Option value="off_shelf">下架</Option>
                </Select>
              </Form.Item>
            </Col>
            <Col span={4}>
              <Form.Item name="dateRange" label="上架日期">
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

      <Card variant="borderless" className="table-card" 
        title="素材列表" 
        extra={<Button type="primary" icon={<PlusOutlined />} onClick={() => { setEditingId(null); setIsModalVisible(true); }}>新建素材</Button>}
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

      <Modal 
        title={editingId ? "编辑素材" : "上传素材"} 
        open={isModalVisible} 
        onOk={handleSubmit} 
        onCancel={handleModalCancel}
        confirmLoading={uploadLoading}
        width={700}
      >
        <Form form={uploadForm} layout="vertical">
          <Row gutter={16}>
             <Col span={12}>
                <Form.Item name="title" label="素材标题" rules={[{ required: true }]}>
                    <Input placeholder="请输入素材标题" />
                </Form.Item>
             </Col>
             <Col span={12}>
                <Form.Item name="category" label="素材分类">
                    <Select placeholder="请选择分类">
                    <Option value="brush">笔刷</Option>
                    <Option value="lineart">线稿</Option>
                    <Option value="font">字体</Option>
                    <Option value="3d">3D</Option>
                    <Option value="texture">纹理</Option>
                    <Option value="illustration">插图</Option>
                    <Option value="mockup">Mockup</Option>
                    <Option value="template">Template</Option>
                    </Select>
                </Form.Item>
             </Col>
             <Col span={12}>
                <Form.Item name="tags" label="素材标签">
                    <Select allowClear mode="tags" style={{ width: '100%' }} placeholder="请选择或输入标签">
                        {tags.map(t => <Option key={t.id} value={t.name}>{t.name}</Option>)}
                    </Select>
                </Form.Item>
             </Col>
             <Col span={12}>
                <Form.Item name="software_ids" label="支持软件 (自动识别)">
                    <Select allowClear mode="multiple" placeholder="上传文件后自动识别">
                        {software.map(s => <Option key={s.id} value={s.id}>{s.name}</Option>)}
                    </Select>
                </Form.Item>
             </Col>
             <Col span={12}>
                <Form.Item label="预览图" name="preview_url" getValueFromEvent={getUrl} rules={[{ required: true, message: '请上传预览图' }]}>
                    <Upload customRequest={customRequestPreview} listType="picture" maxCount={1}>
                        <Button icon={<UploadOutlined />}>上传预览图</Button>
                    </Upload>
                </Form.Item>
             </Col>
             <Col span={12}>
                <Form.Item label="素材文件" name="file_url" getValueFromEvent={getUrl} rules={[{ required: true, message: '请上传素材文件' }]}>
                    <Upload customRequest={customRequestFile} multiple>
                        <Button icon={<UploadOutlined />}>上传文件 (支持多选)</Button>
                    </Upload>
                </Form.Item>
             </Col>
          </Row>
        </Form>
      </Modal>

      <Modal
        title="素材详情"
        open={detailVisible}
        onCancel={() => setDetailVisible(false)}
        footer={null}
        width={800}
      >
        {detailData && (
          <Descriptions bordered column={2}>
            <Descriptions.Item label="ID">{detailData.id}</Descriptions.Item>
            <Descriptions.Item label="标题">{detailData.title}</Descriptions.Item>
            <Descriptions.Item label="分类">{detailData.category}</Descriptions.Item>
            <Descriptions.Item label="类型">{detailData.type}</Descriptions.Item>
            <Descriptions.Item label="标签">
              {detailData.Tags?.map(t => <AntTag key={t.id}>{t.name}</AntTag>)}
            </Descriptions.Item>
            <Descriptions.Item label="支持软件">
              {detailData.Softwares?.map(s => <AntTag color="blue" key={s.id}>{s.name}</AntTag>)}
            </Descriptions.Item>
            <Descriptions.Item label="预览图" span={2}>
              <img src={`${detailData.preview_url}?v=1`} alt="preview" style={{ maxWidth: '100%', maxHeight: 200 }} />
            </Descriptions.Item>
            <Descriptions.Item label="文件列表" span={2}>
              {detailData.Files && detailData.Files.length > 0 ? (
                  <div style={{ maxHeight: 200, overflowY: 'auto' }}>
                      {detailData.Files.map((f, index) => (
                          <div key={index} style={{ marginBottom: 8, padding: 8, border: '1px solid #f0f0f0', borderRadius: 4 }}>
                              <div><strong>{f.name}</strong></div>
                              <div style={{ fontSize: 12, color: '#999' }}>
                                  {f.format?.toUpperCase()} · {f.size} · <a href={f.url} target="_blank" rel="noreferrer">下载</a>
                              </div>
                          </div>
                      ))}
                  </div>
              ) : (
                  <div>
                      Legacy URL: <a href={detailData.file_url} target="_blank" rel="noreferrer">下载</a>
                  </div>
              )}
            </Descriptions.Item>
            <Descriptions.Item label="数据统计" span={2}>
               <div>下载: {detailData.download_count}</div>
               <div>点击: {detailData.click_count}</div>
               <div>曝光: {detailData.exposure_count}</div>
            </Descriptions.Item>
          </Descriptions>
        )}
      </Modal>
    </div>
  );
};

export default MaterialList;
