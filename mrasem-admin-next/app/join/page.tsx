/**
 * Legacy /join?phone=... landing.
 * Once iOS switches to /invite/<token>, this becomes a simple
 * "Download Mrasem" fallback for old links.
 */
export default function JoinPage() {
  // For now, show a simple landing since we can't resolve phone → token without a lookup.
  // Once iOS creates invitations server-side first, it will share /invite/<token> instead.
  return (
    <div className="flex min-h-screen items-center justify-center bg-[#f5f0eb] px-4">
      <div className="w-full max-w-sm rounded-2xl bg-white p-8 text-center shadow-xl">
        <div className="mx-auto mb-4 h-16 w-16 rounded-full bg-[#213c2e] flex items-center justify-center">
          <span className="text-2xl text-white font-bold">M</span>
        </div>
        <h1 className="text-xl font-semibold text-[#31231b]">You&apos;re invited to Mrasem</h1>
        <p className="mt-2 text-sm text-gray-500">
          Download the Mrasem app to view your invitation and book experiences across Saudi Arabia.
        </p>
        <div className="mt-6 space-y-3">
          <a
            href="https://apps.apple.com/app/mrasem"
            className="block rounded-xl bg-[#213c2e] py-3 text-sm font-medium text-white transition hover:bg-[#2d5a40]"
          >
            Download on the App Store
          </a>
        </div>
        <p className="mt-4 text-xs text-gray-400">Powered by Mrasem</p>
      </div>
    </div>
  );
}
