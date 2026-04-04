import { createClient } from "@/lib/supabase/server";

export const dynamic = "force-dynamic";

async function count(
  supabase: ReturnType<typeof createClient>,
  table: string
): Promise<number> {
  const { count, error } = await supabase
    .from(table)
    .select("*", { count: "exact", head: true });
  if (error) return 0;
  return count ?? 0;
}

export default async function DashboardPage() {
  const supabase = createClient();
  const [
    bookings,
    users,
    restaurants,
    activities,
    events,
  ] = await Promise.all([
    count(supabase, "bookings"),
    count(supabase, "users"),
    count(supabase, "restaurants"),
    count(supabase, "activities"),
    count(supabase, "season_events"),
  ]);

  const cards = [
    { label: "Bookings", value: bookings, href: "/bookings" },
    { label: "Users", value: users, href: "/users" },
    { label: "Restaurants", value: restaurants, href: "/restaurants" },
    { label: "Activities", value: activities, href: "/activities" },
    { label: "Season events", value: events, href: "/events" },
  ];

  return (
    <div>
      <h1 className="text-2xl font-semibold text-mrasem-preiwinki">Dashboard</h1>
      <p className="mt-1 text-sm text-gray-600">Overview of your Mrasem data</p>
      <div className="mt-8 grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {cards.map((c) => (
          <a
            key={c.label}
            href={c.href}
            className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm transition hover:border-mrasem-awaki/40 hover:shadow"
          >
            <p className="text-sm font-medium text-gray-500">{c.label}</p>
            <p className="mt-2 text-3xl font-semibold text-mrasem-preiwinki">{c.value}</p>
          </a>
        ))}
      </div>
    </div>
  );
}
