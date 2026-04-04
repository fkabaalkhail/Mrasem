import { useAuth } from '../context/AuthContext';

export default function Topbar() {
  const { user, logout } = useAuth();

  return (
    <header className="h-14 bg-[#31231B] text-white flex items-center justify-between px-4">
      <div className="w-32" />

      <h1 className="text-lg font-bold tracking-wide">Mrasem</h1>

      <div className="w-32 flex items-center justify-end gap-3">
        {user?.email && (
          <span className="text-xs text-gray-300 truncate max-w-[120px]">
            {user.email}
          </span>
        )}
        <button
          onClick={logout}
          className="text-xs bg-white/10 hover:bg-white/20 px-3 py-1 rounded transition-colors"
        >
          Logout
        </button>
      </div>
    </header>
  );
}
