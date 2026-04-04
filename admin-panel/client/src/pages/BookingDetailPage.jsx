import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { apiGet, apiPatch } from '../api';
import LoadingSpinner from '../components/LoadingSpinner';
import Toast from '../components/Toast';

export default function BookingDetailPage() {
  const { id } = useParams();
  const [booking, setBooking] = useState(null);
  const [loading, setLoading] = useState(true);
  const [toast, setToast] = useState(null);
  const [scanResult, setScanResult] = useState(null);

  useEffect(() => {
    apiGet(`/api/bookings/${id}`)
      .then(setBooking)
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [id]);

  const handleStatusUpdate = async (status) => {
    try {
      const updated = await apiPatch(`/api/bookings/${id}`, { status });
      setBooking((prev) => ({ ...prev, status: updated.status || status }));
      setToast({ message: `Booking ${status} successfully`, type: 'success' });
    } catch (err) {
      setToast({ message: err.message || 'Failed to update status', type: 'error' });
    }
  };

  const handleTestScan = () => {
    if (!booking?.qrPayload) return;
    const parts = booking.qrPayload.split('|');
    setScanResult({
      prefix: parts[0] || '',
      ticketCode: parts[1] || '',
      placeName: parts[2] || '',
    });
  };

  if (loading) return <LoadingSpinner />;
  if (!booking) {
    return (
      <div className="text-center py-12">
        <p className="text-gray-500">Booking not found</p>
        <Link to="/bookings" className="text-[#213C2E] hover:underline mt-2 inline-block">Back to Bookings</Link>
      </div>
    );
  }

  const fields = [
    { label: 'Ticket Code', value: booking.ticketCode },
    { label: 'Place', value: booking.placeTitle },
    { label: 'Subtitle', value: booking.subtitle },
    { label: 'Date', value: booking.dateDisplay },
    { label: 'Time', value: booking.timeDisplay },
    { label: 'Branch', value: booking.branch },
    { label: 'Event Date', value: booking.eventDate },
    { label: 'User Phone', value: booking.userPhone },
    { label: 'Status', value: booking.status },
    { label: 'Created', value: booking.createdAt },
  ];

  return (
    <div>
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}

      <div className="flex items-center gap-4 mb-6">
        <Link to="/bookings" className="text-[#213C2E] hover:underline text-sm">&larr; Back to Bookings</Link>
        <h1 className="text-2xl font-bold text-[#31231B]">Booking Detail</h1>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Booking Fields */}
        <div className="lg:col-span-2 bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-[#31231B] mb-4">Booking Information</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {fields.map((f) => (
              <div key={f.label}>
                <p className="text-xs text-gray-500 uppercase tracking-wide">{f.label}</p>
                <p className="text-sm font-medium text-[#31231B] mt-1">
                  {f.label === 'Status' ? (
                    <span className={`px-2 py-1 rounded text-xs font-medium ${
                      f.value === 'approved' ? 'bg-green-100 text-green-800' :
                      f.value === 'rejected' ? 'bg-red-100 text-red-800' :
                      'bg-yellow-100 text-yellow-800'
                    }`}>
                      {f.value}
                    </span>
                  ) : (
                    f.value || '—'
                  )}
                </p>
              </div>
            ))}
          </div>

          {/* QR Payload */}
          <div className="mt-6 pt-4 border-t">
            <p className="text-xs text-gray-500 uppercase tracking-wide">QR Payload</p>
            <p className="text-sm font-mono bg-gray-50 p-2 rounded mt-1 break-all">{booking.qrPayload}</p>
          </div>

          {/* Approve / Reject */}
          {booking.status === 'pending' && (
            <div className="mt-6 pt-4 border-t flex gap-3">
              <button
                onClick={() => handleStatusUpdate('approved')}
                className="px-4 py-2 bg-[#213C2E] text-white rounded-lg text-sm font-medium hover:opacity-90 transition-opacity"
              >
                Approve
              </button>
              <button
                onClick={() => handleStatusUpdate('rejected')}
                className="px-4 py-2 bg-[#DC2626] text-white rounded-lg text-sm font-medium hover:opacity-90 transition-opacity"
              >
                Reject
              </button>
            </div>
          )}
        </div>

        {/* QR Code + Ticket Code */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-lg font-semibold text-[#31231B] mb-4">QR Code</h2>
          <div className="flex flex-col items-center">
            <img
              src={`/api/bookings/${id}/qr`}
              alt="Booking QR Code"
              className="w-48 h-48 border rounded"
            />
            <p className="mt-3 text-sm text-gray-500">Ticket Code</p>
            <p className="text-lg font-mono font-bold text-[#31231B]">{booking.ticketCode}</p>

            <button
              onClick={handleTestScan}
              className="mt-4 px-4 py-2 bg-[#31231B] text-white rounded-lg text-sm font-medium hover:opacity-90 transition-opacity w-full"
            >
              Test Scan
            </button>

            {scanResult && (
              <div className="mt-4 w-full bg-gray-50 rounded-lg p-4 text-sm">
                <p className="font-semibold text-[#31231B] mb-2">Scan Result</p>
                <div className="space-y-1">
                  <p><span className="text-gray-500">Prefix:</span> {scanResult.prefix}</p>
                  <p><span className="text-gray-500">Ticket Code:</span> {scanResult.ticketCode}</p>
                  <p><span className="text-gray-500">Place Name:</span> {scanResult.placeName}</p>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
