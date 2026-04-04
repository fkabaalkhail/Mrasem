"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { BrandMark } from "@/components/BrandMark";

const links = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/restaurants", label: "Restaurants" },
  { href: "/activities", label: "Activities" },
  { href: "/events", label: "Season events" },
  { href: "/cars", label: "Cars" },
  { href: "/bookings", label: "Bookings" },
  { href: "/users", label: "Users" },
];

export function Sidebar() {
  const pathname = usePathname();
  const supabase = createClient();

  async function signOut() {
    await supabase.auth.signOut();
    window.location.href = "/login";
  }

  return (
    <aside className="flex w-56 shrink-0 flex-col bg-mrasem-preiwinki text-mrasem-white min-h-screen border-r border-black/10">
      <div className="border-b border-white/10 px-3 py-4 sm:px-4">
        <BrandMark variant="sidebar" />
      </div>
      <nav className="flex flex-1 flex-col gap-0.5 p-3">
        {links.map(({ href, label }) => {
          const active =
            pathname === href || (href !== "/dashboard" && pathname.startsWith(href));
          return (
            <Link
              key={href}
              href={href}
              className={`rounded-lg px-3 py-2 text-sm transition ${
                active
                  ? "bg-mrasem-awaki text-mrasem-white shadow-sm"
                  : "text-white/85 hover:bg-white/10"
              }`}
            >
              {label}
            </Link>
          );
        })}
      </nav>
      <div className="border-t border-white/10 p-3">
        <button
          type="button"
          onClick={() => void signOut()}
          className="w-full rounded-lg px-3 py-2 text-left text-sm text-white/70 hover:bg-white/10"
        >
          Sign out
        </button>
      </div>
    </aside>
  );
}
