export const regionData = [
  {
    value: 'CN',
    label: '中国',
    children: [
      {
        value: 'Beijing',
        label: '北京',
        children: [
          {
            value: 'Beijing',
            label: '北京',
            children: [
              { value: 'Dongcheng', label: '东城区' },
              { value: 'Xicheng', label: '西城区' },
              { value: 'Chaoyang', label: '朝阳区' },
              { value: 'Haidian', label: '海淀区' },
            ]
          }
        ]
      },
      {
        value: 'Zhejiang',
        label: '浙江',
        children: [
          {
            value: 'Hangzhou',
            label: '杭州',
            children: [
              { value: 'Xihu', label: '西湖区' },
              { value: 'Yuhang', label: '余杭区' },
            ]
          }
        ]
      },
      {
        value: 'Guangdong',
        label: '广东',
        children: [
          {
            value: 'Guangzhou',
            label: '广州',
            children: [
              { value: 'Tianhe', label: '天河区' },
              { value: 'Haizhu', label: '海珠区' },
            ]
          },
          {
            value: 'Shenzhen',
            label: '深圳',
            children: [
              { value: 'Nanshan', label: '南山区' },
              { value: 'Futian', label: '福田区' },
            ]
          }
        ]
      }
    ]
  },
  // Add more mock data as needed
];
