"use client";

import { FormEvent, useEffect, useState } from "react";

type Task = {
  id: number;
  title: string;
  done: boolean;
  created_at: string;
};

type ApiResponse = { tasks?: Task[]; task?: Task; error?: string };

async function request(path: string, options?: RequestInit): Promise<ApiResponse> {
  const response = await fetch(path, {
    headers: { "content-type": "application/json", ...options?.headers },
    ...options,
  });
  const body = (await response.json()) as ApiResponse;
  if (!response.ok) throw new Error(body.error ?? "Не удалось выполнить запрос.");
  return body;
}

export function TaskPanel() {
  const [tasks, setTasks] = useState<Task[]>([]);
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("Загружаем задачи…");
  const [loading, setLoading] = useState(true);

  async function loadTasks() {
    setLoading(true);
    try {
      const data = await request("/api/tasks");
      setTasks(data.tasks ?? []);
      setMessage(data.tasks?.length ? "Данные синхронизированы с PostgreSQL." : "Пока нет задач.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Не удалось получить задачи.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    void loadTasks();
  }, []);

  async function addTask(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const value = title.trim();
    if (!value) return;

    setLoading(true);
    try {
      const data = await request("/api/tasks", {
        method: "POST",
        body: JSON.stringify({ title: value }),
      });
      setTasks((current) => (data.task ? [data.task, ...current] : current));
      setTitle("");
      setMessage("Задача добавлена в PostgreSQL.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Не удалось добавить задачу.");
    } finally {
      setLoading(false);
    }
  }

  async function toggleTask(task: Task) {
    setLoading(true);
    try {
      const data = await request(`/api/tasks/${task.id}`, {
        method: "PATCH",
        body: JSON.stringify({ done: !task.done }),
      });
      setTasks((current) => current.map((item) => (item.id === task.id && data.task ? data.task : item)));
      setMessage("Статус задачи обновлён в PostgreSQL.");
    } catch (error) {
      setMessage(error instanceof Error ? error.message : "Не удалось обновить задачу.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <section className="panel" aria-labelledby="tasks-title">
      <div className="panel-heading">
        <div>
          <p className="eyebrow">ДЕЙСТВИЯ</p>
          <h2 id="tasks-title">Задачи</h2>
        </div>
        <button className="secondary-button" type="button" onClick={() => void loadTasks()} disabled={loading}>
          Обновить
        </button>
      </div>

      <form className="task-form" onSubmit={addTask}>
        <label className="sr-only" htmlFor="task-title">Новая задача</label>
        <input
          id="task-title"
          value={title}
          onChange={(event) => setTitle(event.target.value)}
          placeholder="Например, проверить подключение"
          maxLength={160}
          disabled={loading}
        />
        <button className="primary-button" type="submit" disabled={loading || !title.trim()}>
          Добавить
        </button>
      </form>

      <p className="status" role="status">{message}</p>

      <ul className="task-list" aria-live="polite">
        {tasks.map((task) => (
          <li key={task.id} className={task.done ? "task done" : "task"}>
            <span>{task.title}</span>
            <button type="button" onClick={() => void toggleTask(task)} disabled={loading}>
              {task.done ? "Вернуть" : "Готово"}
            </button>
          </li>
        ))}
      </ul>
    </section>
  );
}
