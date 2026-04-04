import { NavLink } from 'react-router-dom';

const links = [
  { to: '/', label: 'Dashboard' },
  { to: '/bookings', label: 'Bookings' },
  { to: '/restaurants', label: 'Restaurants' },
  { to: '/activities', label: 'Activities' },
  { to: '/season-events', label: 'Season Events' },
  { to: '/users', label: 'Users' },
];

export default function Sidebar() {
  return (
    <aside className="w-60 min-h-screen bg-[#31231B] text-white p-4 flex flex-col">
      <div className="mb-8">
        <h1 className="text-2xl font-bold tracking-wide">Mrasem</h1>
        <p className="text-xs text-gray-400 mt-1">Admin Panel</p>
      </div>

      <nav className="flex flex-col gap-1">
        {links.map(({ to, label }) => (
          <NavLink
            key={to}
            to={to}
            end={to === '/'}
            className={({ isActive }) =>
              `block px-3 py-2 rounded text-sm font-medium transition-colors ${
                isActive
                  ? 'bg-[#213C2E] text-white'
                  : 'text-gray-300 hover:text-white hover:bg-white/10'
              }`
            }
          >
            {label}
          </NavLink>
        ))}
      </nav>
    </aside>
  );
}
