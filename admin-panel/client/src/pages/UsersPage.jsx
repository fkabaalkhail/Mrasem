import { useState, useEffect, useCallback } from 'react';
import { Link } from 'react-router-dom';
import { apiGet } from '../api';
import LoadingSpinner from '../components/LoadingSpinner';
import Pagination from '../components/Pagination';

export default function UsersPage() {
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [data, setData] = useState({ rows: [], totalPages: 1 });
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const result = await apiGet(`/api/users?search=${encodeURIComponent(search)}&page=${page}&limit=20`);
      setData({ rows: result.data || [], totalPages: result.totalPages || 1 });
    } catch {
      setData({ rows: [], totalPages: 1 });
    } finally {
      setLoading(false);
    }
  }, [search, page]);

  useEffect(() => { fetchData(); }, [fetchData]);
  useEffect(() => { setPage(1); }, [search]);

  return (
    <div>
      <h1 className="text-2xl font-bold text-[#31231B] mb-6">Users</h1>

      <div className="mb-4">
        <input
          type="text"
          placeholder="Search by phone number..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-full max-w-md px-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#31231B]/30"
        />
      </div>

      {loading ? (
        <LoadingSpinner />
      ) : (
        <>
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-[#31231B] text-white text-sm">
                  <th className="text-left px-4 py-3">Phone</th>
                  <th className="text-left px-4 py-3">Registration Date</th>
                  <th className="text-left px-4 py-3">Bookings</th>
                </tr>
              </thead>
              <tbody>
                {data.rows.length === 0 ? (
                  <tr><td colSpan={3} className="px-4 py-6 text-center text-gray-400">No users found</td></tr>
                ) : (
                  data.rows.map((u) => (
                    <tr key={u.id} className="border-b last:border-b-0 hover:bg-gray-50 cursor-pointer">
                      <td className="px-4 py-3 text-sm">
                        <Link to={`/users/${u.id}`} className="text-[#213C2E] hover:underline font-medium">{u.phone}</Link>
                      </td>
                      <td className="px-4 py-3 text-sm">{u.createdAt || u.created_at || '—'}</td>
                      <td className="px-4 py-3 text-sm">{u.bookingCount ?? 0}</td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
          <Pagination page={page} totalPages={data.totalPages} onPageChange={setPage} />
        </>
      )}
    </div>
  );
}
