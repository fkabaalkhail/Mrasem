const CITIES = ['All', 'Jeddah', 'Riyadh', 'Mecca', 'AlUla', 'Southern Provence'];

export default function CityFilter({ value, onChange }) {
  return (
    <select
      value={value}
      onChange={(e) => onChange(e.target.value)}
      className="border border-gray-300 rounded px-3 py-2 text-sm text-[#31231B] bg-white focus:outline-none focus:ring-2 focus:ring-[#31231B]/20"
    >
      {CITIES.map((city) => (
        <option key={city} value={city === 'All' ? '' : city}>
          {city}
        </option>
      ))}
    </select>
  );
}
