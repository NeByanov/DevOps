--
-- PostgreSQL database dump
--

\restrict 7guMYAsboYxcA1rOnzVpK0rOr4ckMPqKJuxzLJiZL2zvXq6F9G2tNkJ0Tjy1HY9

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: tasks; Type: TABLE; Schema: public; Owner: app_owner
--

CREATE TABLE public.tasks (
    id bigint NOT NULL,
    title character varying(160) NOT NULL,
    done boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.tasks OWNER TO app_owner;

--
-- Name: tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: app_owner
--

CREATE SEQUENCE public.tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.tasks_id_seq OWNER TO app_owner;

--
-- Name: tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: app_owner
--

ALTER SEQUENCE public.tasks_id_seq OWNED BY public.tasks.id;


--
-- Name: tasks id; Type: DEFAULT; Schema: public; Owner: app_owner
--

ALTER TABLE ONLY public.tasks ALTER COLUMN id SET DEFAULT nextval('public.tasks_id_seq'::regclass);


--
-- Data for Name: tasks; Type: TABLE DATA; Schema: public; Owner: app_owner
--

COPY public.tasks (id, title, done, created_at) FROM stdin;
4	111	t	2026-08-10 09:57:12.867109+00
3	Сделай котлетки	t	2026-08-10 09:41:19.082159+00
2	Мой ежедневник	t	2026-08-10 09:41:12.336255+00
1	проверь	t	2026-08-10 09:41:04.163104+00
5	биба	t	2026-08-10 13:04:38.102749+00
6	Тест1	f	2026-08-11 11:00:55.580449+00
7	не те данные	f	2026-08-11 11:12:40.43551+00
8	не те данные	f	2026-08-11 11:12:44.258452+00
9	не те данные	f	2026-08-11 11:12:47.867116+00
10	1	f	2026-08-11 11:39:05.297134+00
11	1	f	2026-08-11 11:39:07.131027+00
12	1	f	2026-08-11 11:39:08.046887+00
13	2	f	2026-08-11 11:49:22.126957+00
14	2	f	2026-08-11 11:49:22.915095+00
15	3	f	2026-08-11 12:38:17.873269+00
16	3	f	2026-08-11 12:38:19.442878+00
17	4	f	2026-08-11 12:38:20.507927+00
18	4	f	2026-08-11 12:38:21.806941+00
\.


--
-- Name: tasks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: app_owner
--

SELECT pg_catalog.setval('public.tasks_id_seq', 18, true);


--
-- Name: tasks tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: app_owner
--

ALTER TABLE ONLY public.tasks
    ADD CONSTRAINT tasks_pkey PRIMARY KEY (id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO web_anon;


--
-- Name: TABLE tasks; Type: ACL; Schema: public; Owner: app_owner
--

GRANT SELECT ON TABLE public.tasks TO web_anon;


--
-- Name: COLUMN tasks.title; Type: ACL; Schema: public; Owner: app_owner
--

GRANT INSERT(title) ON TABLE public.tasks TO web_anon;


--
-- Name: COLUMN tasks.done; Type: ACL; Schema: public; Owner: app_owner
--

GRANT UPDATE(done) ON TABLE public.tasks TO web_anon;


--
-- Name: SEQUENCE tasks_id_seq; Type: ACL; Schema: public; Owner: app_owner
--

GRANT SELECT,USAGE ON SEQUENCE public.tasks_id_seq TO web_anon;


--
-- PostgreSQL database dump complete
--

\unrestrict 7guMYAsboYxcA1rOnzVpK0rOr4ckMPqKJuxzLJiZL2zvXq6F9G2tNkJ0Tjy1HY9

