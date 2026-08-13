import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import { headers } from "next/headers";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export async function generateMetadata(): Promise<Metadata> {
  const requestHeaders = await headers();
  const host = requestHeaders.get("host") ?? "localhost:3000";
  const protocol = requestHeaders.get("x-forwarded-proto") ?? "https";

  return {
    metadataBase: new URL(`${protocol}://${host}`),
    title: "PostgreSQL Task Panel",
    description: "Небольшой интерфейс для задач в PostgreSQL.",
    openGraph: {
      title: "Задачи в PostgreSQL",
      description: "Небольшой интерфейс для задач в PostgreSQL.",
      images: [{ url: "/og.png", width: 1728, height: 912, alt: "Задачи в PostgreSQL" }],
    },
    twitter: { card: "summary_large_image", images: ["/og.png"] },
    icons: { icon: "/favicon.svg", shortcut: "/favicon.svg" },
  };
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
