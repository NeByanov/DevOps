CREATE ROLE web_anon NOLOGIN;
GRANT web_anon TO app_owner;

CREATE TABLE IF NOT EXISTS tasks (
  id BIGSERIAL PRIMARY KEY,
  title VARCHAR(160) NOT NULL,
  done BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

GRANT USAGE ON SCHEMA public TO web_anon;
GRANT SELECT ON tasks TO web_anon;
GRANT INSERT (title) ON tasks TO web_anon;
GRANT UPDATE (done) ON tasks TO web_anon;
GRANT USAGE, SELECT ON SEQUENCE tasks_id_seq TO web_anon;
