# Web Invite Flow — iOS Handoff

## New URL shape

```
https://project-xk931.vercel.app/invite/<token>
```

(Replace with custom domain when ready, e.g. `https://mrasem.com/invite/<token>`)

## How it works

1. **iOS creates the invitation server-side** by inserting into `public.invitations` via Supabase.
2. The insert returns a row with a `token` (UUID).
3. iOS shares the URL `https://<domain>/invite/<token>` via the share sheet.
4. Recipient opens the link in Safari → sees place card → taps Accept or Decline.
5. The web page PATCHes `invitations.status` from `pending` → `accepted` / `declined`.
6. iOS can poll or subscribe to the invitation row to see the updated status.

## iOS change: `InvitationStore.swift`

Replace `appInviteURL(forPhone:)` with a method that creates the invite server-side first:

```swift
/// Creates an invitation on the server and returns the shareable web URL.
static func createAndShareInvite(
    recipientPhone: String,
    placeTitle: String,
    subtitle: String,
    imageName: String,
    dateDisplay: String,
    timeDisplay: String,
    branch: String
) async throws -> URL {
    let supabase = // your Supabase client
    let row = try await supabase
        .from("invitations")
        .insert([
            "sender_phone": senderPhone,
            "recipient_phone": recipientPhone,
            "place_title": placeTitle,
            "subtitle": subtitle,
            "image_name": imageName,
            "date_display": dateDisplay,
            "time_display": timeDisplay,
            "branch": branch,
        ])
        .select("token")
        .single()
        .execute()

    let token = row.data["token"] as! String
    return URL(string: "https://project-xk931.vercel.app/invite/\(token)")!
}
```

## Supabase table: `invitations`

| Column | Type | Notes |
|--------|------|-------|
| id | uuid (PK) | auto |
| token | uuid (unique) | public-facing, in URL |
| sender_phone | text | E.164 |
| recipient_phone | text | E.164 |
| status | text | pending / accepted / declined |
| place_title | text | snapshot |
| subtitle | text | nullable |
| image_name | text | nullable |
| date_display | text | nullable |
| time_display | text | nullable |
| branch | text | nullable |
| arabic_* | text | nullable Arabic copies |
| expires_at | timestamptz | default now() + 30 days |
| created_at | timestamptz | auto |

## Migration

Run `supabase/migrations/20260404130000_invitations_table.sql` in Supabase SQL Editor.

## Legacy `/join?phone=...`

Old links still work — they show a "Download Mrasem" landing page. No token lookup needed.
