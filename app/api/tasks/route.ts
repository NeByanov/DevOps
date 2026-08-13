import { DatabaseUnavailableError, postgresRequest } from "../../lib/postgrest";

function errorResponse(error: unknown) {
  const message = error instanceof Error ? error.message : "Не удалось обратиться к PostgreSQL.";
  return Response.json({ error: message }, { status: error instanceof DatabaseUnavailableError ? 503 : 502 });
}

export async function GET() {
  try {
    const response = await postgresRequest("/tasks?select=id,title,done,created_at&order=created_at.desc&limit=30", {
      cache: "no-store",
    });
    return Response.json({ tasks: await response.json() });
  } catch (error) {
    return errorResponse(error);
  }
}

export async function POST(request: Request) {
  try {
    const payload = (await request.json()) as { title?: string };
    const title = payload.title?.trim();
    if (!title) return Response.json({ error: "Введите название задачи." }, { status: 400 });

    const response = await postgresRequest("/tasks", {
      method: "POST",
      headers: { "content-type": "application/json", Prefer: "return=representation" },
      body: JSON.stringify({ title }),
    });
    const [task] = (await response.json()) as unknown[];
    return Response.json({ task }, { status: 201 });
  } catch (error) {
    return errorResponse(error);
  }
}
