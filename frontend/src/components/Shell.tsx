import { type ReactNode } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Car, LogOut } from 'lucide-react';
import { getSession, setSession } from '../lib/api';

export default function Shell({ children }: { children: ReactNode }) {
  const nav = useNavigate();
  const session = getSession();

  return (
    <>
      <header className="top">
        <Link to="/" className="brand"><Car />Auto<span>Marketplace</span></Link>
        <nav>
          <Link to="/">Comprar</Link>
          <a href="/#vender">Vender</a>
          <Link to="/alugar">Alugar</Link>
          {session?.role === 'DEALER' && <Link to="/lojista">Painel Lojista</Link>}
          {session?.role === 'RENTAL' && <Link to="/locadora">Painel Locadora</Link>}
          {session?.role === 'ADMIN' && <Link to="/admin">Admin</Link>}
          {session ? (
            <button className="ghost" onClick={() => { setSession(null); nav('/'); }}>
              <LogOut size={17} />Sair
            </button>
          ) : (
            <Link className="btn small" to="/login">Entrar</Link>
          )}
        </nav>
      </header>
      {children}
    </>
  );
}
