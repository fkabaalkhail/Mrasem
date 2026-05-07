"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { ImageUploadField } from "@/components/ImageUploadField";

const empty = {
  name: "",
  arabic_name: "",
  rating: 4.5,
  cuisine: "",
  arabic_cuisine: "",
  image_name: "",
  has_michelin: false,
  description: "",
  arabic_description: "",
  city: "Jeddah",
  arabic_city: "جدة",
};

export default function NewRestaurantPage() {
  const router = useRouter();
  const [form, setForm] = useState(empty);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    if (!form.name.trim() || !form.arabic_name.trim() || !form.city.trim() || !form.cuisine.trim()) {
      setError("Please fill in all required fields.");
      return;
    }
    setSaving(true);
    const sb = createClient();
    const { error: insErr } = await sb.from("restaurants").insert({
      name: form.name,
      arabic_name: form.arabic_name,
      rating: form.rating,
      cuisine: form.cuisine,
      arabic_cuisine: form.arabic_cuisine,
      image_name: form.image_name || null,
      has_michelin: form.has_michelin,
      description: form.description || null,
      arabic_description: form.arabic_description || null,
      city: form.city,
      arabic_city: form.arabic_city,
    });
    setSaving(false);
    if (insErr) {
      setError(insErr.message);
      return;
    }
    router.push("/restaurants");
    router.refresh();
  }

  return (
    <div>
      <div className="mb-6 flex items-center gap-4">
        <Link href="/restaurants" className="text-sm text-mrasem-awaki hover:underline">
          ← Back
        </Link>
        <h1 className="text-2xl font-semibold text-mrasem-preiwinki">New restaurant</h1>
      </div>
      <form
        onSubmit={(e) => void onSubmit(e)}
        className="max-w-3xl space-y-6 rounded-xl border border-gray-200 bg-white p-6 shadow-sm"
      >
        <div className="grid gap-4 sm:grid-cols-2">
          <Field label="Name (EN)" value={form.name} onChange={(v) => setForm({ ...form, name: v })} required />
          <Field label="Name (AR)" value={form.arabic_name} onChange={(v) => setForm({ ...form, arabic_name: v })} required />
          <Field label="Cuisine (EN)" value={form.cuisine} onChange={(v) => setForm({ ...form, cuisine: v })} required />
          <Field label="Cuisine (AR)" value={form.arabic_cuisine} onChange={(v) => setForm({ ...form, arabic_cuisine: v })} required />
          <Field label="City (EN)" value={form.city} onChange={(v) => setForm({ ...form, city: v })} required />
          <Field label="City (AR)" value={form.arabic_city} onChange={(v) => setForm({ ...form, arabic_city: v })} required />
          <div>
            <label className="block text-sm font-medium text-gray-700">Rating</label>
            <input
              type="number"
              step="0.1"
              min={0}
              max={5}
              value={form.rating}
              onChange={(e) => setForm({ ...form, rating: parseFloat(e.target.value) || 0 })}
              className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
            />
          </div>
          <label className="flex items-center gap-2 pt-8">
            <input
              type="checkbox"
              checked={form.has_michelin}
              onChange={(e) => setForm({ ...form, has_michelin: e.target.checked })}
            />
            <span className="text-sm text-gray-700">Michelin</span>
          </label>
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Description (EN)</label>
          <textarea
            value={form.description}
            onChange={(e) => setForm({ ...form, description: e.target.value })}
            rows={4}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <div>
          <label className="block text-sm font-medium text-gray-700">Description (AR)</label>
          <textarea
            value={form.arabic_description}
            onChange={(e) => setForm({ ...form, arabic_description: e.target.value })}
            rows={4}
            className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
          />
        </div>
        <ImageUploadField
          folder="restaurants"
          value={form.image_name}
          onChange={(url) => setForm({ ...form, image_name: url })}
          recommendedSize="1420 x 1000 px"
          recommendedRatio="10:7"
        />
        {error && <p className="text-sm text-red-600">{error}</p>}
        <button
          type="submit"
          disabled={saving}
          className="rounded-lg bg-mrasem-preiwinki px-5 py-2.5 text-sm font-medium text-white disabled:opacity-50"
        >
          {saving ? "Saving…" : "Create"}
        </button>
      </form>
    </div>
  );
}

function Field({
  label,
  value,
  onChange,
  required,
}: {
  label: string;
  value: string;
  onChange: (v: string) => void;
  required?: boolean;
}) {
  return (
    <div>
      <label className="block text-sm font-medium text-gray-700">{label}</label>
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        required={required}
        className="mt-1 w-full rounded-lg border border-gray-300 px-3 py-2 text-sm"
      />
    </div>
  );
}
