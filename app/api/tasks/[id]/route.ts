import { DatabaseUnavailableError, postgresRequest } from "../../../lib/postgrest";

type Context = { params: Promise<{ id: string }> };

export async function PATCH(request: Request, context: Context) {
  try {
    const { id } = await context.params;
    if (!/^\d+$/.test(id)) return Response.json({ error: "Некорректный идентификатор задачи." }, { status: 400 });

    const payload = (await request.json()) as { done?: boolean };
    if (typeof payload.done !== "boolean") return Response.json({ error: "Нужен статус задачи." }, { status: 400 });

    const response = await postgresRequest(`/tasks?id=eq.${id}`, {
      method: "PATCH",
      headers: { "content-type": "application/json", Prefer: "return=representation" },
      body: JSON.stringify({ done: payload.done }),
    });
    const [task] = (await response.json()) as unknown[];
    if (!task) return Response.json({ error: "Задача не найдена." }, { status: 404 });
    return Response.json({ task });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Не удалось обновить задачу.";
    return Response.json({ error: message }, { status: error instanceof DatabaseUnavailableError ? 503 : 502 });
  }
}
