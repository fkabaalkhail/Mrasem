import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        background: "var(--background)",
        foreground: "var(--foreground)",
        mrasem: {
          white: "#ffffff",
          preiwinki: "#31231b",
          /** Accent: original Mrasem dark green (not Figma maroon) */
          awaki: "#213c2e",
          page: "#fafafa",
        },
      },
      fontFamily: {
        sans: ["var(--font-expo-arabic)", "var(--font-geist-sans)", "system-ui", "sans-serif"],
      },
    },
  },
  plugins: [],
};
export default config;
