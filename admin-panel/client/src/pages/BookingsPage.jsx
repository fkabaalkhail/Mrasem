import { useState, useEffect, useCallback } from 'react';
import { Link } from 'react-router-dom';
import { apiGet } from '../api';
import LoadingSpinner from '../components/LoadingSpinner';
import Pagination from '../components/Pagination';

const TABS = [
  { key: 'bookings', label: 'Bookings' },
  { key: 'sent', label: 'Sent Invitations' },
  { key: 'received', label: 'Received Invitations' },
];

export default function BookingsPage() {
  const [tab, setTab] = useState('bookings');
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [data, setData] = useState({ rows: [], totalPages: 1 });
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    setLoading(true);
    try {
      let result;
      if (tab === 'bookings') {
        result = await apiGet(`/api/bookings?search=${encodeURIComponent(search)}&page=${page}&limit=20`);
      } else if (tab === 'sent') {
        result = await apiGet(`/api/invitations/sent?page=${page}&limit=20`);
      } else {
        result = await apiGet(`/api/invitations/received?page=${page}&limit=20`);
      }
      const rows = result.data || result.bookings || result.invitations || [];
      const totalPages = result.totalPages || 1;
      setData({ rows, totalPages });
    } catch {
      setData({ rows: [], totalPages: 1 });
    } finally {
      setLoading(false);
    }
  }, [tab, search, page]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  useEffect(() => {
    setPage(1);
  }, [tab, search]);

  return (
    <div>
      <h1 className="text-2xl font-bold text-[#31231B] mb-6">Bookings</h1>

      {/* Tabs */}
      <div className="flex gap-1 mb-6 border-b border-gray-200">
        {TABS.map((t) => (
          <button
            key={t.key}
            onClick={() => setTab(t.key)}
            className={`px-4 py-2 text-sm font-medium rounded-t-lg transition-colors ${
              tab === t.key
                ? 'bg-[#31231B] text-white'
                : 'text-gray-600 hover:bg-gray-100'
            }`}
          >
            {t.label}
          </button>
        ))}
      </div>

      {/* Search (bookings tab only) */}
      {tab === 'bookings' && (
        <div className="mb-4">
          <input
            type="text"
            placeholder="Search by ticket code, place, or phone..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full max-w-md px-4 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#31231B]/30"
          />
        </div>
      )}

      {loading ? (
        <LoadingSpinner />
      ) : (
        <>
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <table className="w-full">
              <thead>
                <tr className="bg-[#31231B] text-white text-sm">
                  {tab === 'bookings' && (
                    <>
                      <th className="text-left px-4 py-3">Ticket Code</th>
                      <th className="text-left px-4 py-3">Place</th>
                      <th className="text-left px-4 py-3">User Phone</th>
                      <th className="text-left px-4 py-3">Date</th>
                      <th className="text-left px-4 py-3">Time</th>
                      <th className="text-left px-4 py-3">Branch</th>
                      <th className="text-left px-4 py-3">Status</th>
                    </>
                  )}
                  {tab === 'sent' && (
                    <>
                      <th className="text-left px-4 py-3">Place</th>
                      <th className="text-left px-4 py-3">Recipient Phone</th>
                      <th className="text-left px-4 py-3">Date</th>
                      <th className="text-left px-4 py-3">Time</th>
                      <th className="text-left px-4 py-3">Branch</th>
                      <th className="text-left px-4 py-3">Outcome</th>
                    </>
                  )}
                  {tab === 'received' && (
                    <>
                      <th className="text-left px-4 py-3">Place</th>
                      <th className="text-left px-4 py-3">Inviter Phone</th>
                      <th className="text-left px-4 py-3">Date</th>
                      <th className="text-left px-4 py-3">Time</th>
                      <th className="text-left px-4 py-3">Branch</th>
                      <th className="text-left px-4 py-3">Response</th>
                    </>
                  )}
                </tr>
              </thead>
              <tbody>
                {data.rows.length === 0 ? (
                  <tr>
                    <td colSpan={7} className="px-4 py-6 text-center text-gray-400">
                      No records found
                    </td>
                  </tr>
                ) : (
                  data.rows.map((row) => (
                    <tr key={row.id} className="border-b last:border-b-0 hover:bg-gray-50">
                      {tab === 'bookings' && (
                        <>
                          <td className="px-4 py-3 text-sm">
                            <Link to={`/bookings/${row.id}`} className="text-[#213C2E] hover:underline font-medium">
                              {row.ticketCode}
                            </Link>
                          </td>
                          <td className="px-4 py-3 text-sm">{row.placeTitle}</td>
                          <td className="px-4 py-3 text-sm">{row.userPhone}</td>
                          <td className="px-4 py-3 text-sm">{row.dateDisplay}</td>
                          <td className="px-4 py-3 text-sm">{row.timeDisplay}</td>
                          <td className="px-4 py-3 text-sm">{row.branch}</td>
                          <td className="px-4 py-3 text-sm">
                            <span className={`px-2 py-1 rounded text-xs font-medium ${
                              row.status === 'approved' ? 'bg-green-100 text-green-800' :
                              row.status === 'rejected' ? 'bg-red-100 text-red-800' :
                              'bg-yellow-100 text-yellow-800'
                            }`}>
                              {row.status}
                            </span>
                          </td>
                        </>
                      )}
                      {tab === 'sent' && (
                        <>
                          <td className="px-4 py-3 text-sm">{row.placeTitle}</td>
                          <td className="px-4 py-3 text-sm">{row.recipientPhone}</td>
                          <td className="px-4 py-3 text-sm">{row.dateDisplay}</td>
                          <td className="px-4 py-3 text-sm">{row.timeDisplay}</td>
                          <td className="px-4 py-3 text-sm">{row.branch}</td>
                          <td className="px-4 py-3 text-sm">
                            <span className={`px-2 py-1 rounded text-xs font-medium ${
                              row.outcome === 'accepted' ? 'bg-green-100 text-green-800' :
                              row.outcome === 'declined' ? 'bg-red-100 text-red-800' :
                              'bg-yellow-100 text-yellow-800'
                            }`}>
                              {row.outcome}
                            </span>
                          </td>
                        </>
                      )}
                      {tab === 'received' && (
                        <>
                          <td className="px-4 py-3 text-sm">{row.placeTitle}</td>
                          <td className="px-4 py-3 text-sm">{row.inviterPhone}</td>
                          <td className="px-4 py-3 text-sm">{row.dateDisplay}</td>
                          <td className="px-4 py-3 text-sm">{row.timeDisplay}</td>
                          <td className="px-4 py-3 text-sm">{row.branch}</td>
                          <td className="px-4 py-3 text-sm">
                            <span className={`px-2 py-1 rounded text-xs font-medium ${
                              row.userResponse === 'accepted' ? 'bg-green-100 text-green-800' :
                              row.userResponse === 'declined' ? 'bg-red-100 text-red-800' :
                              'bg-yellow-100 text-yellow-800'
                            }`}>
                              {row.userResponse}
                            </span>
                          </td>
                        </>
                      )}
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
