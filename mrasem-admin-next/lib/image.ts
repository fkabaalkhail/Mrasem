export function resolveImageSrc(value: string | null | undefined, folder?: string): string | null {
  const raw = value?.trim();
  if (!raw) return null;

  if (raw.startsWith("http://") || raw.startsWith("https://")) return raw;

  const base = process.env.NEXT_PUBLIC_SUPABASE_URL;
  if (!base) return raw;

  if (raw.startsWith("/storage/")) return `${base}${raw}`;
  if (raw.startsWith("storage/")) return `${base}/${raw}`;

  const normalized = raw.replace(/^\/+/, "");

  if (normalized.includes("/")) {
    return `${base}/storage/v1/object/public/images/${normalized}`;
  }

  if (folder) {
    return `${base}/storage/v1/object/public/images/${folder}/${normalized}`;
  }

  return `${base}/storage/v1/object/public/images/${normalized}`;
}
