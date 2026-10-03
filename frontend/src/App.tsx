import { type ReactElement } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import Home from './pages/Home';
import Login from './pages/Login';
import Dealer from './pages/Dealer';
import Admin from './pages/Admin';
import Rent from './pages/Rent';
import Rental from './pages/Rental';
import { getSession } from './lib/api';

function Guard({ role, children }: { role: string; children: ReactElement }) {
  const session = getSession();
  return session?.role === role ? children : <Navigate to="/login" replace />;
}

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/alugar" element={<Rent />} />
      <Route path="/login" element={<Login />} />
      <Route path="/lojista" element={<Guard role="DEALER"><Dealer /></Guard>} />
      <Route path="/locadora" element={<Guard role="RENTAL"><Rental /></Guard>} />
      <Route path="/admin" element={<Guard role="ADMIN"><Admin /></Guard>} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}
