/**
 * Renders an entity image. If imageName starts with "/uploads/", it's a
 * server-hosted file. Otherwise it's an iOS asset name — show a styled
 * placeholder with the first letter.
 */
export default function EntityImage({ imageName, alt, className = 'w-12 h-12 object-cover rounded' }) {
  if (!imageName) {
    return (
      <div className={`${className} bg-gray-200 flex items-center justify-center text-gray-400 text-xs`}>
        No img
      </div>
    );
  }

  if (imageName.startsWith('/uploads/')) {
    return <img src={imageName} alt={alt} className={className} />;
  }

  // iOS asset name — show a placeholder with initials
  const initials = (alt || imageName)
    .split(/[\s-]+/)
    .slice(0, 2)
    .map(w => w[0]?.toUpperCase() || '')
    .join('');

  return (
    <div className={`${className} bg-[#31231B] flex items-center justify-center text-white text-xs font-medium`}>
      {initials}
    </div>
  );
}
