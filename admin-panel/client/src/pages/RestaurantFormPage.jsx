import { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { apiGet, apiPost, apiPut } from '../api';
import LoadingSpinner from '../components/LoadingSpinner';
import Toast from '../components/Toast';
import EntityImage from '../components/EntityImage';

const CITIES = ['Jeddah', 'Riyadh', 'Mecca', 'AlUla', 'Southern Provence'];
const REQUIRED = ['name', 'arabicName', 'cuisine', 'city'];

export default function RestaurantFormPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const isEdit = Boolean(id);

  const [form, setForm] = useState({
    name: '', arabicName: '', rating: 0, cuisine: '', arabicCuisine: '',
    hasMichelin: false, description: '', arabicDescription: '', city: '', arabicCity: '',
  });
  const [imageFile, setImageFile] = useState(null);
  const [imagePreview, setImagePreview] = useState('');
  const [errors, setErrors] = useState({});
  const [loading, setLoading] = useState(isEdit);
  const [toast, setToast] = useState(null);

  useEffect(() => {
    if (!isEdit) return;
    apiGet(`/api/restaurants/${id}`)
      .then((data) => {
        setForm({
          name: data.name || '', arabicName: data.arabicName || '',
          rating: data.rating || 0, cuisine: data.cuisine || '',
          arabicCuisine: data.arabicCuisine || '', hasMichelin: Boolean(data.hasMichelin),
          description: data.description || '', arabicDescription: data.arabicDescription || '',
          city: data.city || '', arabicCity: data.arabicCity || '',
        });
        if (data.imageName) setImagePreview(data.imageName);
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, [id, isEdit]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setForm((prev) => ({ ...prev, [name]: type === 'checkbox' ? checked : value }));
    if (errors[name]) setErrors((prev) => ({ ...prev, [name]: false }));
  };

  const handleImageChange = (e) => {
    const file = e.target.files?.[0];
    if (file) {
      setImageFile(file);
      setImagePreview(URL.createObjectURL(file));
    }
  };

  const validate = () => {
    const newErrors = {};
    REQUIRED.forEach((f) => { if (!form[f]?.trim()) newErrors[f] = true; });
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validate()) return;
    const fd = new FormData();
    Object.entries(form).forEach(([k, v]) => {
      if (k === 'hasMichelin') fd.append(k, v ? '1' : '0');
      else fd.append(k, v);
    });
    if (imageFile) fd.append('image', imageFile);
    try {
      if (isEdit) await apiPut(`/api/restaurants/${id}`, fd);
      else await apiPost('/api/restaurants', fd);
      setToast({ message: `Restaurant ${isEdit ? 'updated' : 'created'} successfully`, type: 'success' });
      setTimeout(() => navigate('/restaurants'), 500);
    } catch (err) {
      setToast({ message: err.message || 'Failed to save', type: 'error' });
    }
  };

  if (loading) return <LoadingSpinner />;

  const inputClass = (field) =>
    `w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#31231B]/20 ${errors[field] ? 'border-red-500' : 'border-gray-300'}`;

  return (
    <div>
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}
      <div className="flex items-center gap-4 mb-6">
        <button onClick={() => navigate('/restaurants')} className="text-[#213C2E] hover:underline text-sm">&larr; Back</button>
        <h1 className="text-2xl font-bold text-[#31231B]">{isEdit ? 'Edit Restaurant' : 'Add Restaurant'}</h1>
      </div>

      <form onSubmit={handleSubmit} className="bg-white rounded-lg shadow p-6 max-w-3xl">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-medium text-[#31231B] mb-1">Name *</label>
            <input name="name" value={form.name} onChange={handleChange} className={inputClass('name')} />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#31231B] mb-1">Arabic Name *</label>
            <input name="arabicName" value={form.arabicName} onChange={handleChange} className={inputClass('arabicName')} dir="rtl" />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#31231B] mb-1">Cuisine *</label>
            <input name="cuisine" value={form.cuisine} onChange={handleChange} className={inputClass('cuisine')} />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#31231B] mb-1">Arabic Cuisine</label>
            <input name="arabicCuisine" value={form.arabicCuisine} onChange={handleChange} className={inputClass('arabicCuisine')} dir="rtl" />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#31231B] mb-1">City *</label>
            <select name="city" value={form.city} onChange={handleChange} className={inputClass('city')}>
              <option value="">Select city</option>
              {CITIES.map((c) => <option key={c} value={c}>{c}</option>)}
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-[#31231B] mb-1">Arabic City</label>
            <input name="arabicCity" value={form.arabicCity} onChange={handleChange} className={inputClass('arabicCity')} dir="rtl" />
          </div>
          <div>
            <label className="block text-sm font-medium text-[#31231B] mb-1">Rating (0-5)</label>
            <input name="rating" type="number" min="0" max="5" step="0.1" value={form.rating} onChange={handleChange} className={inputClass('rating')} />
          </div>
          <div className="flex items-center gap-2 pt-6">
            <input name="hasMichelin" type="checkbox" checked={form.hasMichelin} onChange={handleChange} className="w-4 h-4" />
            <label className="text-sm font-medium text-[#31231B]">Has Michelin</label>
          </div>
        </div>

        <div className="mt-4">
          <label className="block text-sm font-medium text-[#31231B] mb-1">Description</label>
          <textarea name="description" value={form.description} onChange={handleChange} rows={3} className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#31231B]/20" />
        </div>
        <div className="mt-4">
          <label className="block text-sm font-medium text-[#31231B] mb-1">Arabic Description</label>
          <textarea name="arabicDescription" value={form.arabicDescription} onChange={handleChange} rows={3} dir="rtl" className="w-full px-3 py-2 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-[#31231B]/20" />
        </div>

        <div className="mt-4">
          <label className="block text-sm font-medium text-[#31231B] mb-1">Image</label>
          <input type="file" accept="image/jpeg,image/png" onChange={handleImageChange} className="text-sm" />
          <p className="mt-1 text-xs text-gray-500">Recommended: 800×600px or larger, JPG or PNG. Landscape orientation works best in the iOS app.</p>
          {imagePreview && <EntityImage imageName={imagePreview} alt="Preview" className="mt-2 w-32 h-32 object-cover rounded" />}
        </div>

        <div className="mt-6 flex gap-3">
          <button type="submit" className="px-6 py-2 bg-[#31231B] text-white rounded-lg text-sm font-medium hover:opacity-90 transition-opacity">
            {isEdit ? 'Update' : 'Create'}
          </button>
          <button type="button" onClick={() => navigate('/restaurants')} className="px-6 py-2 bg-gray-200 text-gray-700 rounded-lg text-sm font-medium hover:bg-gray-300">
            Cancel
          </button>
        </div>
      </form>
    </div>
  );
}
