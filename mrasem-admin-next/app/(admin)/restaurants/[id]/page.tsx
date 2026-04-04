"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { useParams, useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { ImageUploadField } from "@/components/ImageUploadField";
import type { Restaurant } from "@/lib/types";

export default function EditRestaurantPage() {
  const params = useParams();
  const id = Number(params.id);
  const router = useRouter();
  const [form, setForm] = useState<Partial<Restaurant> | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!id) return;
    const sb = createClient();
    void sb
      .from("restaurants")
      .select("*")
      .eq("id", id)
      .single()
      .then(({ data, error: qErr }) => {
        if (qErr || !data) setError(qErr?.message ?? "Not found");
        else setForm(data as Restaurant);
        setLoading(false);
      });
  }, [id]);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!form) return;
    setError(null);
    setSaving(true);
    const sb = createClient();
    const { error: upErr } = await sb
      .from("restaurants")
      .update({
        name: form.name,
        arabic_name: form.arabic_name,
        rating: form.rating,
        cuisine: form.cuisine,
        arabic_cuisine: form.arabic_cuisine,
        image_name: form.image_name,
        has_michelin: form.has_michelin,
        description: form.description,
        arabic_description: form.arabic_description,
        city: form.city,
        arabic_city: form.arabic_city,
        updated_at: new Date().toISOString(),
      })
      .eq("id", id);
    setSaving(false);
    if (upErr) {
      setError(upErr.message);
      return;
    }
    router.push("/restaurants");
    router.refresh();
  }

  async function onDelete() {
    if (!confirm("Delete this restaurant?")) return;
    const sb = createClient();
    await sb.from("restaurants").delete().eq("id", id);
    router.push("/restaurants");
    router.refresh();
  }

  if (loading || !form) {
    return (
      <div>
        <p className="text-gray-500">{error ?? "Loading…"}</p>
        <Link href="/restaurants" className="mt-4 inline-block text-mrasem-awaki">
          ← Back
        </Link>
      </div>
    );
  }

  return (
    <div>
      <div className="mb-6 flex flex-wrap items-center gap-4">
        <Link href="/restaurants" className="text-sm text-mrasem-awaki hover:underline">
          ← Back
        </Link>
        <h1 className="text-2xl font-semibold text-mrasem-preiwinki">Edit restaurant #{id}</h1>
      </div>
      <form
        onSubmit={(e) => void onSubmit(e)}
        className="max-w-3xl space-y-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
      >
        <div className="grid gap-4 sm:grid-cols-2">
          <Field label="Name (EN)" value={form.name ?? ""} onChange={(v) => setForm({ ...form, name: v })} />
          <Field label="Name (AR)" value={form.arabic_name ?? ""} onChange={(v) => setForm({ ...form, arabic_name: v })} />
          <Field label="Cuisine (EN)" value={form.cuisine ?? ""} onChange={(v) => setForm({ ...form, cuisine: v })} />
          <Field label="Cuisine (AR)" value={form.arabic_cuisine ?? ""} onChange={(v) => setForm({ ...form, arabic_cuisine: v })} />
          <Field label="City (EN)" value={form.city ?? ""} onChange={(v) => setForm({ ...form, city: v })} />
          <Field label="City (AR)" value={form.arabic_city ?? ""} onChange={(v) => setForm({ ...form, arabic_city: v })} />
          <div>
            <label className="block text-sm font-medium text-gray-700">Rating</label>
            <input
              type="number"
              step="0.1"
              min={0}
              max={5}
              value={form.rating ?? 0}
              onChange={(e) => setForm({ ...form, rating: parseFloat(e.target.value) || 0 })}
              className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
            />
          </div>
          <label className="flex items-center gap-2 pt-8">
            <input
              type="checkbox"
              checked={!!form.has_michelin}
              onChange={(e) => setForm({ ...form, has_michelin: e.target.checked })}
            />
            <span className="text-sm text-gray-700">Michelin</span>
          </label>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Description (EN)</label>
          <textarea
            value={form.description ?? ""}
            onChange={(e) => setForm({ ...form, description: e.target.value })}
            rows={4}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Description (AR)</label>
          <textarea
            value={form.arabic_description ?? ""}
            onChange={(e) => setForm({ ...form, arabic_description: e.target.value })}
            rows={4}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <ImageUploadField
          folder="restaurants"
          value={form.image_name ?? ""}
          onChange={(url) => setForm({ ...form, image_name: url })}
        />
        {error && <p className="text-sm text-red-600">{error}</p>}
        <div className="flex flex-wrap gap-3">
          <button
            type="submit"
            disabled={saving}
            className="rounded-lg bg-mrasem-preiwinki px-5 py-2.5 text-sm font-medium text-white disabled:opacity-50"
          >
            {saving ? "Saving…" : "Save"}
          </button>
          <button
            type="button"
            onClick={() => void onDelete()}
            className="rounded-lg border border-red-200 bg-red-50 px-5 py-2.5 text-sm font-medium text-red-800"
          >
            Delete
          </button>
        </div>
      </form>
    </div>
  );
}

function Field({
  label,
  value,
  onChange,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
}) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700">{label}</label>
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
      />
    </div>
  );
}
