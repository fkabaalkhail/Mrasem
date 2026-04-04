import { useEffect } from 'react';

export default function Toast({ message, type = 'success', onClose }) {
  useEffect(() => {
    const timer = setTimeout(onClose, 3000);
    return () => clearTimeout(timer);
  }, [onClose]);

  const bg = type === 'error' ? 'bg-[#DC2626]' : 'bg-[#213C2E]';

  return (
    <div className={`fixed top-4 right-4 z-50 ${bg} text-white px-6 py-3 rounded-lg shadow-lg animate-slide-in flex items-center gap-3`}>
      <span>{message}</span>
      <button onClick={onClose} className="ml-2 text-white/80 hover:text-white text-lg leading-none">&times;</button>
    </div>
  );
}
