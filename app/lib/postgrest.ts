const API_URL = process.env.POSTGREST_URL?.replace(/\/$/, "");
const API_KEY = process.env.POSTGREST_API_KEY;

export class DatabaseUnavailableError extends Error {}

function requireApiUrl() {
  if (!API_URL) {
    throw new DatabaseUnavailableError(
      "PostgreSQL пока не подключён. Укажите POSTGREST_URL в переменных окружения.",
    );
  }
  return API_URL;
}

export async function postgresRequest(path: string, init: RequestInit = {}) {
  const headers = new Headers(init.headers);
  headers.set("accept", "application/json");
  if (API_KEY) headers.set("apikey", API_KEY);

  const response = await fetch(`${requireApiUrl()}${path}`, { ...init, headers });
  if (!response.ok) {
    const detail = await response.text();
    throw new Error(detail || `PostgreSQL API вернул код ${response.status}.`);
  }
  return response;
}

export async function databaseHealth() {
  const response = await postgresRequest("/", { cache: "no-store" });
  return response.ok;
}
