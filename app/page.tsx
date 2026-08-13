import { TaskPanel } from "./TaskPanel";

export default function Home() {
  return (
    <main className="shell">
      <section className="hero" aria-labelledby="page-title">
        <p className="eyebrow">POSTGRESQL · STARTER</p>
        <h1 id="page-title">Небольшая панель для базы данных</h1>
        <p className="intro">
          Добавляйте и отмечайте задачи. Все действия выполняются через API и
          сохраняются в PostgreSQL.
        </p>
        <a className="health-link" href="/health">
          Проверить здоровье сервиса →
        </a>
      </section>

      <TaskPanel />
    </main>
  );
}
