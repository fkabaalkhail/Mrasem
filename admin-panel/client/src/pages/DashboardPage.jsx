import { useState, useEffect } from 'react';
import { apiGet } from '../api';
import LoadingSpinner from '../components/LoadingSpinner';

export default function DashboardPage() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiGet('/api/dashboard')
      .then(setData)
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <LoadingSpinner />;

  const stats = data?.stats || {};
  const recentBookings = data?.recentBookings || [];

  const cards = [
    { label: 'Active Bookings', value: stats.activeBookings ?? 0 },
    { label: 'Registered Users', value: stats.registeredUsers ?? 0 },
    { label: 'Listed Events', value: stats.totalEvents ?? 0 },
  ];

  return (
    <div>
      <h1 className="text-2xl font-bold text-[#31231B] mb-6">Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        {cards.map((card) => (
          <div key={card.label} className="bg-white rounded-lg shadow p-6 text-center">
            <p className="text-4xl font-bold text-[#31231B]">{card.value}</p>
            <p className="text-sm text-gray-500 mt-2">{card.label}</p>
          </div>
        ))}
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <h2 className="text-lg font-semibold text-[#31231B] p-4 border-b">Recent Bookings</h2>
        <table className="w-full">
          <thead>
            <tr className="bg-[#31231B] text-white text-sm">
              <th className="text-left px-4 py-3">Place</th>
              <th className="text-left px-4 py-3">Date</th>
              <th className="text-left px-4 py-3">Time</th>
              <th className="text-left px-4 py-3">User Phone</th>
              <th className="text-left px-4 py-3">Status</th>
            </tr>
          </thead>
          <tbody>
            {recentBookings.map((b, i) => (
              <tr key={i} className="border-b last:border-b-0 hover:bg-gray-50">
                <td className="px-4 py-3 text-sm">{b.placeTitle}</td>
                <td className="px-4 py-3 text-sm">{b.dateDisplay}</td>
                <td className="px-4 py-3 text-sm">{b.timeDisplay}</td>
                <td className="px-4 py-3 text-sm">{b.userPhone}</td>
                <td className="px-4 py-3 text-sm">
                  <span className={`px-2 py-1 rounded text-xs font-medium ${
                    b.status === 'approved' ? 'bg-green-100 text-green-800' :
                    b.status === 'rejected' ? 'bg-red-100 text-red-800' :
                    'bg-yellow-100 text-yellow-800'
                  }`}>
                    {b.status}
                  </span>
                </td>
              </tr>
            ))}
            {recentBookings.length === 0 && (
              <tr><td colSpan={5} className="px-4 py-6 text-center text-gray-400">No bookings yet</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
