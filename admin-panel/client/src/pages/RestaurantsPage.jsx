import { useState, useEffect, useCallback } from 'react';
import { Link } from 'react-router-dom';
import { apiGet, apiDelete } from '../api';
import CityFilter from '../components/CityFilter';
import LoadingSpinner from '../components/LoadingSpinner';
import Pagination from '../components/Pagination';
import ConfirmDialog from '../components/ConfirmDialog';
import Toast from '../components/Toast';
import EntityImage from '../components/EntityImage';

export default function RestaurantsPage() {
  const [city, setCity] = useState('');
  const [page, setPage] = useState(1);
  const [data, setData] = useState({ rows: [], totalPages: 1 });
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);
  const [deleteTarget, setDeleteTarget] = useState(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      const result = await apiGet(`/api/restaurants?city=${encodeURIComponent(city)}&page=${page}&limit=20`);
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
      await apiDelete(`/api/restaurants/${deleteTarget.id}`);
      setToast({ message: 'Restaurant deleted successfully', type: 'success' });
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
      <ConfirmDialog
        open={!!deleteTarget}
        message={`Delete "${deleteTarget?.name}"?`}
        onConfirm={handleDelete}
        onCancel={() => setDeleteTarget(null)}
      />

      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold text-[#31231B]">Restaurants</h1>
        <div className="flex items-center gap-3">
          <CityFilter value={city} onChange={setCity} />
          <Link to="/restaurants/new" className="px-4 py-2 bg-[#31231B] text-white rounded-lg text-sm font-medium hover:opacity-90 transition-opacity">
            Add Restaurant
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
                  <th className="text-left px-4 py-3">Arabic Name</th>
                  <th className="text-left px-4 py-3">Cuisine</th>
                  <th className="text-left px-4 py-3">City</th>
                  <th className="text-left px-4 py-3">Rating</th>
                  <th className="text-left px-4 py-3">Michelin</th>
                  <th className="text-left px-4 py-3">Actions</th>
                </tr>
              </thead>
              <tbody>
                {data.rows.length === 0 ? (
                  <tr><td colSpan={8} className="px-4 py-6 text-center text-gray-400">No restaurants found</td></tr>
                ) : (
                  data.rows.map((r) => (
                    <tr key={r.id} className="border-b last:border-b-0 hover:bg-gray-50">
                      <td className="px-4 py-3">
                        {r.imageName ? (
                          <EntityImage imageName={r.imageName} alt={r.name} />
                        ) : (
                          <div className="w-12 h-12 bg-gray-200 rounded flex items-center justify-center text-gray-400 text-xs">No img</div>
                        )}
                      </td>
                      <td className="px-4 py-3 text-sm font-medium text-[#31231B]">{r.name}</td>
                      <td className="px-4 py-3 text-sm" dir="rtl">{r.arabicName}</td>
                      <td className="px-4 py-3 text-sm">{r.cuisine}</td>
                      <td className="px-4 py-3 text-sm">{r.city}</td>
                      <td className="px-4 py-3 text-sm">{r.rating}</td>
                      <td className="px-4 py-3 text-sm">
                        {r.hasMichelin ? (
                          <span className="px-2 py-1 bg-yellow-100 text-yellow-800 rounded text-xs font-medium">⭐ Michelin</span>
                        ) : '—'}
                      </td>
                      <td className="px-4 py-3 text-sm">
                        <div className="flex gap-2">
                          <Link to={`/restaurants/${r.id}/edit`} className="text-[#213C2E] hover:underline text-sm">Edit</Link>
                          <button onClick={() => setDeleteTarget(r)} className="text-[#DC2626] hover:underline text-sm">Delete</button>
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
