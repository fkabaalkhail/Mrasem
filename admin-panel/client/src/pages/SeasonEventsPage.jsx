import { useState, useEffect, useCallback } from 'react';
import { Link } from 'react-router-dom';
import { apiGet, apiDelete } from '../api';
import CityFilter from '../components/CityFilter';
import LoadingSpinner from '../components/LoadingSpinner';
import EntityImage from '../components/EntityImage';
import Pagination from '../components/Pagination';
import ConfirmDialog from '../components/ConfirmDialog';
import Toast from '../components/Toast';

export default function SeasonEventsPage() {
  const [city, setCity] = useState('');
  const [page, setPage] = useState(1);
  const [data, setData] = useState({ rows: [], totalPages: 1 });
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);
  const [deleteTarget, setDeleteTarget] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const result = await apiGet(`/api/season-events?city=${encodeURIComponent(city)}&page=${page}&limit=20`);
      setData({ rows: result.data || [], totalPages: result.totalPages || 1 });
    } catch {
      setData({ rows: [], totalPages: 1 });
    } finally {
      setLoading(false);
    }
  }, [city, page]);

  useEffect(() => { fetchData(); }, [fetchData]);
  useEffect(() => { setPage(1); }, [city]);

  const handleDelete = async () => {
    if (!deleteTarget) return;
    try {
      await apiDelete(`/api/season-events/${deleteTarget.id}`);
      setToast({ message: 'Season event deleted successfully', type: 'success' });
      setDeleteTarget(null);
      fetchData();
    } catch (err) {
      setToast({ message: err.message || 'Failed to delete', type: 'error' });
      setDeleteTarget(null);
    }
  };

  return (
    <div>
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
      <ConfirmDialog open={!!deleteTarget} message={`Delete "${deleteTarget?.name}"?`} onConfirm={handleDelete} onCancel={() => setDeleteTarget(null)} />

      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-[#31231B]">Season Events</h1>
        <div className="flex items-center gap-3">
          <CityFilter value={city} onChange={setCity} />
          <Link to="/season-events/new" className="px-4 py-2 bg-[#31231B] text-white rounded-lg text-sm font-medium hover:opacity-90 transition-opacity">
            Add Season Event
          </Link>
        </div>
      </div>

      {loading ? (
        <LoadingSpinner />
      ) : (
        <>
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-[#31231B] text-white text-sm">
                  <th className="text-left px-4 py-3">Image</th>
                  <th className="text-left px-4 py-3">Name</th>
                  <th className="text-left px-4 py-3">Category</th>
                  <th className="text-left px-4 py-3">City</th>
                  <th className="text-left px-4 py-3">Location</th>
                  <th className="text-left px-4 py-3">Actions</th>
                </tr>
              </thead>
              <tbody>
                {data.rows.length === 0 ? (
                  <tr><td colSpan={6} className="px-4 py-6 text-center text-gray-400">No season events found</td></tr>
                ) : (
                  data.rows.map((s) => (
                    <tr key={s.id} className="border-b last:border-b-0 hover:bg-gray-50">
                      <td className="px-4 py-3">
                        {s.imageName ? (
                          <EntityImage imageName={s.imageName} alt={s.name} />
                        ) : (
                          <div className="w-12 h-12 bg-gray-200 rounded flex items-center justify-center text-gray-400 text-xs">No img</div>
                        )}
                      </td>
                      <td className="px-4 py-3 text-sm font-medium text-[#31231B]">{s.name}</td>
                      <td className="px-4 py-3 text-sm">{s.category}</td>
                      <td className="px-4 py-3 text-sm">{s.city}</td>
                      <td className="px-4 py-3 text-sm">{s.location || '—'}</td>
                      <td className="px-4 py-3 text-sm">
                        <div className="flex gap-2">
                          <Link to={`/season-events/${s.id}/edit`} className="text-[#213C2E] hover:underline text-sm">Edit</Link>
                          <button onClick={() => setDeleteTarget(s)} className="text-[#DC2626] hover:underline text-sm">Delete</button>
                        </div>
                      </td>
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
