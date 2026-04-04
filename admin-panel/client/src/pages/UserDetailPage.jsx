import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { apiGet } from '../api';
import LoadingSpinner from '../components/LoadingSpinner';

export default function UserDetailPage() {
  const { id } = useParams();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiGet(`/api/users/${id}`)
      .then(setUser)
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [id]);

  if (loading) return <LoadingSpinner />;
  if (!user) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">User not found</p>
        <Link to="/users" className="text-[#213C2E] hover:underline mt-2 inline-block">Back to Users</Link>
      </div>
    );
  }

  const bookings = user.bookings || [];

  return (
    <div>
      <div className="flex items-center gap-4 mb-6">
        <Link to="/users" className="text-[#213C2E] hover:underline text-sm">&larr; Back to Users</Link>
        <h1 className="text-2xl font-bold text-[#31231B]">User Detail</h1>
      </div>

      <div className="bg-white rounded-lg shadow p-6 mb-6 max-w-xl">
        <h2 className="text-lg font-semibold text-[#31231B] mb-4">User Information</h2>
        <div className="grid grid-cols-2 gap-4">
          <div>
            <p className="text-xs text-gray-500 uppercase tracking-wide">Phone</p>
            <p className="text-sm font-medium text-[#31231B] mt-1">{user.phone}</p>
          </div>
          <div>
            <p className="text-xs text-gray-500 uppercase tracking-wide">Registration Date</p>
            <p className="text-sm font-medium text-[#31231B] mt-1">{user.createdAt || user.created_at || '—'}</p>
          </div>
        </div>
      </div>

      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b">
          <h2 className="text-lg font-semibold text-[#31231B]">Bookings ({bookings.length})</h2>
        </div>
        <table className="w-full">
          <thead>
            <tr className="bg-[#31231B] text-white text-sm">
              <th className="text-left px-4 py-3">Ticket Code</th>
              <th className="text-left px-4 py-3">Place</th>
              <th className="text-left px-4 py-3">Date</th>
              <th className="text-left px-4 py-3">Time</th>
              <th className="text-left px-4 py-3">Status</th>
            </tr>
          </thead>
          <tbody>
            {bookings.length === 0 ? (
              <tr><td colSpan={5} className="px-4 py-6 text-center text-gray-400">No bookings</td></tr>
            ) : (
              bookings.map((b) => (
                <tr key={b.id} className="border-b last:border-b-0 hover:bg-gray-50">
                  <td className="px-4 py-3 text-sm">
                    <Link to={`/bookings/${b.id}`} className="text-[#213C2E] hover:underline font-medium">{b.ticketCode || b.ticket_code}</Link>
                  </td>
                  <td className="px-4 py-3 text-sm">{b.placeTitle || b.place_title}</td>
                  <td className="px-4 py-3 text-sm">{b.dateDisplay || b.date_display}</td>
                  <td className="px-4 py-3 text-sm">{b.timeDisplay || b.time_display}</td>
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
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
