import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import MainLayout from './components/MainLayout';
import MaterialList from './pages/MaterialList';
import UserList from './pages/UserList';
import TagList from './pages/TagList';
import SoftwareList from './pages/SoftwareList';
import FeedbackList from './pages/FeedbackList';
import HelpGuideList from './pages/HelpGuideList';
import MarketingPopupList from './pages/MarketingPopupList';

const App = () => {
  return (
    <Router basename="/crm">
      <Routes>
        <Route path="/" element={<MainLayout />}>
          <Route index element={<Navigate to="/materials" replace />} />
          <Route path="materials" element={<MaterialList />} />
          <Route path="tags" element={<TagList />} />
          <Route path="software" element={<SoftwareList />} />
          <Route path="users" element={<UserList />} />
          <Route path="feedback" element={<FeedbackList />} />
          <Route path="help-guides" element={<HelpGuideList />} />
          <Route path="marketing-popups" element={<MarketingPopupList />} />
        </Route>
      </Routes>
    </Router>
  );
};

export default App;
