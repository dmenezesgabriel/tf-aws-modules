CREATE DATABASE "todo";

CREATE USER todo_app WITH PASSWORD '123abc';

GRANT ALL PRIVILEGES ON DATABASE "todo" TO todo_app;

\c todo
GRANT ALL PRIVILEGES ON SCHEMA public TO todo_app;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO todo_app;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO todo_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO todo_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO todo_app;