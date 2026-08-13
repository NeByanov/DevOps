import { databaseHealth } from "../lib/postgrest";

async function getHealth() {
  try {
    await databaseHealth();
    return { ok: true, body: { status: "ok", database: "connected" } };
  } catch (error) {
    return {
      ok: false,
      body: {
        status: "degraded",
        database: "unavailable",
        error: error instanceof Error ? error.message : "Не удалось выполнить проверку.",
      },
    };
  }
}

export default async function HealthcheckPage() {
  const health = await getHealth();
  return (
    <main className="health-shell">
      <section className="health-card">
        <p className="eyebrow">HEALTH</p>
        <h1>{health.ok ? "Сервис работает" : "Сервис ожидает PostgreSQL"}</h1>
        <p className={health.ok ? "health-state healthy" : "health-state degraded"}>
          API: {health.body.status} · База: {health.body.database}
        </p>
        {health.body.error ? <p className="health-detail">{health.body.error}</p> : null}
        <a className="health-link" href="/">← На главную</a>
      </section>
    </main>
  );
}
