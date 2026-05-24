export type Restaurant = {
  id: number;
  name: string;
  arabic_name: string;
  rating: number | null;
  cuisine: string;
  arabic_cuisine: string;
  image_name: string | null;
  has_michelin: boolean | null;
  description: string | null;
  arabic_description: string | null;
  city: string;
  arabic_city: string;
  created_at?: string;
};

export type Activity = {
  id: number;
  name: string;
  rating: number | null;
  category: string;
  image_name: string | null;
  location: string | null;
  description: string | null;
  city: string;
  arabic_name: string;
  arabic_category: string;
  arabic_description: string | null;
  arabic_location: string | null;
  safety_guidelines: string | null;
  arabic_safety_guidelines: string | null;
  created_at?: string;
};

export type SeasonEvent = {
  id: number;
  name: string;
  category: string;
  image_name: string | null;
  location: string | null;
  description: string | null;
  city: string;
  arabic_name: string;
  arabic_category: string;
  arabic_description: string | null;
  arabic_location: string | null;
  created_at?: string;
};

export type Car = {
  id: number;
  name: string;
  category: string;
  passengers: number;
  image_name: string | null;
  about: string | null;
  arabic_name: string;
  arabic_about: string | null;
  arabic_passenger_line: string | null;
  created_at?: string;
};

export type AppUser = {
  id: number;
  phone: string;
  name: string | null;
  membership_id: string | null;
  created_at?: string;
};

export type Booking = {
  id: number;
  user_phone: string;
  ticket_code: string;
  place_title: string;
  subtitle: string | null;
  image_name: string | null;
  date_display: string | null;
  time_display: string | null;
  branch: string | null;
  qr_payload: string | null;
  event_date: string | null;
  status: string;
  uses_fork_subtitle_icon: boolean | null;
  created_at?: string;
};
