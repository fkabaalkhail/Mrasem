"use client";

import { Suspense, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { BrandMark } from "@/components/BrandMark";

function LoginForm() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  const searchParams = useSearchParams();
  const next = searchParams.get("next") || "/dashboard";

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    const supabase = createClient();
    const { error: signErr } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    setLoading(false);
    if (signErr) {
      setError(signErr.message);
      return;
    }
    router.push(next);
    router.refresh();
  }

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-mrasem-preiwinki px-4 py-10">
      <div className="mb-10 w-full max-w-md">
        <BrandMark variant="login" />
      </div>
      <div className="w-full max-w-md rounded-2xl border border-black/10 bg-mrasem-white p-8 shadow-xl shadow-black/20">
        <h2 className="text-lg font-semibold text-mrasem-preiwinki">Sign in</h2>
        <p className="mt-1 text-sm text-neutral-500">
          Use your Supabase admin email and password
        </p>
        <form onSubmit={(e) => void onSubmit(e)} className="mt-6 space-y-4">
          <div>
            <label htmlFor="email" className="block text-sm font-medium text-neutral-700">
              Email
            </label>
            <input
              id="email"
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="mt-1 w-full rounded-lg border border-neutral-200 bg-mrasem-white px-3 py-2 text-sm text-neutral-900 focus:border-mrasem-awaki focus:outline-none focus:ring-1 focus:ring-mrasem-awaki"
            />
          </div>
          <div>
            <label htmlFor="password" className="block text-sm font-medium text-neutral-700">
              Password
            </label>
            <input
              id="password"
              type="password"
              autoComplete="current-password"
              required
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="mt-1 w-full rounded-lg border border-neutral-200 bg-mrasem-white px-3 py-2 text-sm text-neutral-900 focus:border-mrasem-awaki focus:outline-none focus:ring-1 focus:ring-mrasem-awaki"
            />
          </div>
          {error && <p className="text-sm text-red-600">{error}</p>}
          <button
            type="submit"
            disabled={loading}
            className="w-full rounded-lg bg-mrasem-preiwinki py-2.5 text-sm font-medium text-mrasem-white hover:bg-black/80 disabled:opacity-50"
          >
            {loading ? "Signing in…" : "Sign in"}
          </button>
        </form>
      </div>
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense
      fallback={
        <div className="flex min-h-screen items-center justify-center bg-mrasem-preiwinki">
          <p className="text-sm text-white/60">Loading…</p>
        </div>
      }
    >
      <LoginForm />
    </Suspense>
  );
}
