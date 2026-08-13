import { databaseHealth, DatabaseUnavailableError } from "../../lib/postgrest";

export async function GET() {
  try {
    await databaseHealth();
    return Response.json({ status: "ok", database: "connected" });
  } catch (error) {
    const message = error instanceof Error ? error.message : "PostgreSQL недоступен.";
    return Response.json(
      { status: "degraded", database: "unavailable", error: message },
      { status: error instanceof DatabaseUnavailableError ? 503 : 502 },
    );
  }
}
