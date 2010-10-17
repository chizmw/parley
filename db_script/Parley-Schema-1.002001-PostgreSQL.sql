-- 
-- Created by SQL::Translator::Producer::PostgreSQL
-- Created on Sun Oct 17 13:51:48 2010
-- 
--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id"  NOT NULL,
  "name"  NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" smallint NOT NULL,
  "password" text NOT NULL,
  "authenticated" boolean DEFAULT 'false' NOT NULL,
  "username" text NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "authentication_username_key" UNIQUE ("username")
);

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id"  NOT NULL,
  "name"  NOT NULL,
  "description"  NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "unique_ban_name" UNIQUE ("name")
);

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" smallint NOT NULL,
  "time_string" text NOT NULL,
  "sample" text NOT NULL,
  "comment" text,
  PRIMARY KEY ("id")
);

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id"  NOT NULL,
  "idx"  NOT NULL,
  "name"  NOT NULL,
  "description"  NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id"  NOT NULL,
  "session_data"  NOT NULL,
  "expires"  NOT NULL,
  "created"  NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" integer NOT NULL,
  "created" timestamp with time zone NOT NULL,
  "content" text NOT NULL,
  "change_summary" text NOT NULL,
  PRIMARY KEY ("id")
);

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id"  NOT NULL,
  "ban_type_id"  NOT NULL,
  "ip_range"  NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "unique_ip_ban_type" UNIQUE ("ban_type_id")
);
CREATE INDEX "parley.ip_ban_idx_ban_type_id" on "parley" ("ban_type_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" smallint NOT NULL,
  "timezone" text DEFAULT 'UTC' NOT NULL,
  "time_format_id" smallint NOT NULL,
  "show_tz" boolean DEFAULT 'true' NOT NULL,
  "notify_thread_watch" boolean DEFAULT 'false' NOT NULL,
  "watch_on_post" boolean DEFAULT 'false' NOT NULL,
  "skin" text DEFAULT 'base' NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "parley.preference_idx_time_format_id" on "parley" ("time_format_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" smallint NOT NULL,
  "creator_id" smallint NOT NULL,
  "subject" text,
  "quoted_post_id" smallint,
  "message" text NOT NULL,
  "quoted_text" text,
  "created" timestamp(6) with time zone DEFAULT 'now()',
  "thread_id" smallint NOT NULL,
  "reply_to_id" smallint,
  "edited" timestamp(6) with time zone,
  "ip_addr" inet,
  "admin_editor_id"  NOT NULL,
  "locked"  NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "parley.post_idx_admin_editor_id" on "parley" ("admin_editor_id");
CREATE INDEX "parley.post_idx_creator_id" on "parley" ("creator_id");
CREATE INDEX "parley.post_idx_quoted_post_id" on "parley" ("quoted_post_id");
CREATE INDEX "parley.post_idx_reply_to_id" on "parley" ("reply_to_id");
CREATE INDEX "parley.post_idx_thread_id" on "parley" ("thread_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id"  NOT NULL,
  "authentication_id"  NOT NULL,
  "role_id"  NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "userroles_authentication_role_key" UNIQUE ("authentication_id", "role_id")
);
CREATE INDEX "parley.user_roles_idx_authentication_id" on "parley" ("authentication_id");
CREATE INDEX "parley.user_roles_idx_role_id" on "parley" ("role_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" smallint NOT NULL,
  "last_post_id" smallint,
  "post_count" smallint DEFAULT 0 NOT NULL,
  "active" boolean DEFAULT 'true' NOT NULL,
  "name" text NOT NULL,
  "description" text,
  PRIMARY KEY ("id"),
  CONSTRAINT "forum_name_key" UNIQUE ("name")
);
CREATE INDEX "parley.forum_idx_last_post_id" on "parley" ("last_post_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" smallint NOT NULL,
  "authentication_id" smallint,
  "last_name" text NOT NULL,
  "email" text NOT NULL,
  "forum_name" text NOT NULL,
  "preference_id" smallint,
  "last_post_id" smallint,
  "post_count" smallint DEFAULT 0 NOT NULL,
  "first_name" text NOT NULL,
  "suspended"  NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "person_email_key" UNIQUE ("email"),
  CONSTRAINT "person_forum_name_key" UNIQUE ("forum_name")
);
CREATE INDEX "parley.person_idx_authentication_id" on "parley" ("authentication_id");
CREATE INDEX "parley.person_idx_last_post_id" on "parley" ("last_post_id");
CREATE INDEX "parley.person_idx_preference_id" on "parley" ("preference_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" smallint NOT NULL,
  "recipient_id" smallint NOT NULL,
  "cc_id" smallint,
  "bcc_id" smallint,
  "sender" text,
  "subject" text NOT NULL,
  "html_content" text,
  "attempted_delivery" boolean DEFAULT 'false' NOT NULL,
  "text_content" text NOT NULL,
  "queued" timestamp(6) with time zone DEFAULT 'now()' NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "parley.email_queue_idx_bcc_id" on "parley" ("bcc_id");
CREATE INDEX "parley.email_queue_idx_cc_id" on "parley" ("cc_id");
CREATE INDEX "parley.email_queue_idx_recipient_id" on "parley" ("recipient_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" integer NOT NULL,
  "recipient_id" smallint NOT NULL,
  "expires" timestamp(6) without time zone,
  PRIMARY KEY ("id")
);
CREATE INDEX "parley.password_reset_idx_recipient_id" on "parley" ("recipient_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" text NOT NULL,
  "recipient_id" smallint NOT NULL,
  "expires" date,
  PRIMARY KEY ("id")
);
CREATE INDEX "parley.registration_authentication_idx_recipient_id" on "parley" ("recipient_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id"  NOT NULL,
  "person_id"  NOT NULL,
  "admin_id"  NOT NULL,
  "created"  NOT NULL,
  "message"  NOT NULL,
  "action_id"  NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "parley.log_admin_action_idx_action_id" on "parley" ("action_id");
CREATE INDEX "parley.log_admin_action_idx_person_id" on "parley" ("person_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" integer NOT NULL,
  "person_id" integer NOT NULL,
  "terms_id" integer NOT NULL,
  "accepted_on" timestamp with time zone NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "parley.terms_agreed_idx_person_id" on "parley" ("person_id");
CREATE INDEX "parley.terms_agreed_idx_terms_id" on "parley" ("terms_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" smallint NOT NULL,
  "locked" boolean DEFAULT 'false' NOT NULL,
  "creator_id" smallint NOT NULL,
  "subject" text NOT NULL,
  "active" boolean DEFAULT 'true' NOT NULL,
  "forum_id" smallint NOT NULL,
  "created" timestamp(6) with time zone DEFAULT 'now()',
  "last_post_id" smallint,
  "sticky" boolean DEFAULT 'false' NOT NULL,
  "post_count" smallint DEFAULT 0 NOT NULL,
  "view_count" smallint DEFAULT 0 NOT NULL,
  PRIMARY KEY ("id")
);
CREATE INDEX "parley.thread_idx_creator_id" on "parley" ("creator_id");
CREATE INDEX "parley.thread_idx_forum_id" on "parley" ("forum_id");
CREATE INDEX "parley.thread_idx_last_post_id" on "parley" ("last_post_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id"  NOT NULL,
  "person_id" smallint NOT NULL,
  "forum_id" smallint NOT NULL,
  "can_moderate" boolean DEFAULT 'false' NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "forum_moderator_person_key" UNIQUE ("person_id", "forum_id")
);
CREATE INDEX "parley.forum_moderator_idx_forum_id" on "parley" ("forum_id");
CREATE INDEX "parley.forum_moderator_idx_person_id" on "parley" ("person_id");

--
-- Table: parley
--
DROP TABLE "parley" CASCADE;
CREATE TABLE "parley" (
  "id" smallint NOT NULL,
  "watched" boolean DEFAULT 'false' NOT NULL,
  "last_notified" timestamp(6) with time zone,
  "thread_id" smallint NOT NULL,
  "timestamp" timestamp(6) with time zone DEFAULT 'now()' NOT NULL,
  "person_id" smallint NOT NULL,
  PRIMARY KEY ("id"),
  CONSTRAINT "thread_view_person_key" UNIQUE ("person_id", "thread_id")
);
CREATE INDEX "parley.thread_view_idx_person_id" on "parley" ("person_id");
CREATE INDEX "parley.thread_view_idx_thread_id" on "parley" ("thread_id");

--
-- Foreign Key Definitions
--

ALTER TABLE "parley" ADD FOREIGN KEY ("ban_type_id")
  REFERENCES "parley.ip_ban_type" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("time_format_id")
  REFERENCES "parley.preference_time_string" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("admin_editor_id")
  REFERENCES "parley.person" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("creator_id")
  REFERENCES "parley.person" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("quoted_post_id")
  REFERENCES "parley.post" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("reply_to_id")
  REFERENCES "parley.post" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("thread_id")
  REFERENCES "parley.thread" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("authentication_id")
  REFERENCES "parley.authentication" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("role_id")
  REFERENCES "parley.role" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("last_post_id")
  REFERENCES "parley.post" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("authentication_id")
  REFERENCES "parley.authentication" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("last_post_id")
  REFERENCES "parley.post" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("preference_id")
  REFERENCES "parley.preference" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("bcc_id")
  REFERENCES "parley.person" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("cc_id")
  REFERENCES "parley.person" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("recipient_id")
  REFERENCES "parley.person" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("recipient_id")
  REFERENCES "parley.person" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("recipient_id")
  REFERENCES "parley.person" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("action_id")
  REFERENCES "parley.admin_action" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("person_id")
  REFERENCES "parley.person" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("person_id")
  REFERENCES "parley.person" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("terms_id")
  REFERENCES "parley.terms" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("creator_id")
  REFERENCES "parley.person" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("forum_id")
  REFERENCES "parley.forum" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("last_post_id")
  REFERENCES "parley.post" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("forum_id")
  REFERENCES "parley.forum" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("person_id")
  REFERENCES "parley.person" ("id") DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("person_id")
  REFERENCES "parley.person" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "parley" ADD FOREIGN KEY ("thread_id")
  REFERENCES "parley.thread" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

