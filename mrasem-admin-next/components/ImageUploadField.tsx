"use client";

import { useState } from "react";
import { createClient } from "@/lib/supabase/client";

type Props = {
  folder: string;
  value: string;
  onChange: (publicUrl: string) => void;
  label?: string;
};

export function ImageUploadField({
  folder,
  value,
  onChange,
  label = "Image",
}: Props) {
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function onFile(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (!file) return;
    setError(null);
    setUploading(true);
    const supabase = createClient();
    const path = `${folder}/${Date.now()}-${file.name.replace(/[^a-zA-Z0-9.-]/g, "_")}`;
    const { data, error: upErr } = await supabase.storage
      .from("images")
      .upload(path, file, { cacheControl: "3600", upsert: false });
    setUploading(false);
    if (upErr) {
      setError(upErr.message);
      return;
    }
    const {
      data: { publicUrl },
    } = supabase.storage.from("images").getPublicUrl(data.path);
    onChange(publicUrl);
  }

  return (
    <div className="space-y-2">
      <label className="block text-sm font-medium text-gray-700">{label}</label>
      <input
        type="file"
        accept="image/*"
        onChange={(e) => void onFile(e)}
        disabled={uploading}
        className="block w-full text-sm text-gray-600 file:mr-4 file:rounded-lg file:border-0 file:bg-mrasem-awaki file:px-4 file:py-2 file:text-sm file:font-medium file:text-white"
      />
      {uploading && <p className="text-sm text-gray-500">Uploading…</p>}
      {error && <p className="text-sm text-red-600">{error}</p>}
      {value ? (
        <div className="mt-2">
          <p className="text-xs text-gray-500 break-all">{value}</p>
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src={
              value.startsWith("http")
                ? value
                : `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/images/${folder}/${value}.jpg`
            }
            alt="Preview"
            className="mt-2 h-24 w-auto max-w-full rounded border object-cover"
          />
        </div>
      ) : null}
    </div>
  );
}
