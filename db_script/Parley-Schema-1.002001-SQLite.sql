-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Sun Oct 17 13:51:48 2010
-- 

BEGIN TRANSACTION;

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id  NOT NULL,
  name  NOT NULL,
  PRIMARY KEY (id)
);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  password text NOT NULL,
  authenticated boolean(1) NOT NULL DEFAULT 'false',
  username text NOT NULL
);

CREATE UNIQUE INDEX authentication_username_key ON parley (username);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id  NOT NULL,
  name  NOT NULL,
  description  NOT NULL,
  PRIMARY KEY (id)
);

CREATE UNIQUE INDEX unique_ban_name ON parley (name);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  time_string text NOT NULL,
  sample text NOT NULL,
  comment text
);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id  NOT NULL,
  idx  NOT NULL,
  name  NOT NULL,
  description  NOT NULL,
  PRIMARY KEY (id)
);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id  NOT NULL,
  session_data  NOT NULL,
  expires  NOT NULL,
  created  NOT NULL,
  PRIMARY KEY (id)
);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  created timestamp with time zone NOT NULL,
  content text NOT NULL,
  change_summary text NOT NULL
);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id  NOT NULL,
  ban_type_id  NOT NULL,
  ip_range  NOT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX parley.ip_ban_idx_ban_type_id ON parley (ban_type_id);

CREATE UNIQUE INDEX unique_ip_ban_type ON parley (ban_type_id);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  timezone text NOT NULL DEFAULT 'UTC',
  time_format_id integer(4) NOT NULL,
  show_tz boolean(1) NOT NULL DEFAULT 'true',
  notify_thread_watch boolean(1) NOT NULL DEFAULT 'false',
  watch_on_post boolean(1) NOT NULL DEFAULT 'false',
  skin text NOT NULL DEFAULT 'base'
);

CREATE INDEX parley.preference_idx_time_format_id ON parley (time_format_id);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  creator_id integer(4) NOT NULL,
  subject text,
  quoted_post_id integer(4),
  message text NOT NULL,
  quoted_text text,
  created timestamp with time zone(8) DEFAULT 'now()',
  thread_id integer(4) NOT NULL,
  reply_to_id integer(4),
  edited timestamp with time zone(8),
  ip_addr inet(8),
  admin_editor_id  NOT NULL,
  locked  NOT NULL
);

CREATE INDEX parley.post_idx_admin_editor_id ON parley (admin_editor_id);

CREATE INDEX parley.post_idx_creator_id ON parley (creator_id);

CREATE INDEX parley.post_idx_quoted_post_id ON parley (quoted_post_id);

CREATE INDEX parley.post_idx_reply_to_id ON parley (reply_to_id);

CREATE INDEX parley.post_idx_thread_id ON parley (thread_id);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id  NOT NULL,
  authentication_id  NOT NULL,
  role_id  NOT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX parley.user_roles_idx_authentication_id ON parley (authentication_id);

CREATE INDEX parley.user_roles_idx_role_id ON parley (role_id);

CREATE UNIQUE INDEX userroles_authentication_role_key ON parley (authentication_id, role_id);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  last_post_id integer(4),
  post_count integer(4) NOT NULL DEFAULT 0,
  active boolean(1) NOT NULL DEFAULT 'true',
  name text NOT NULL,
  description text
);

CREATE INDEX parley.forum_idx_last_post_id ON parley (last_post_id);

CREATE UNIQUE INDEX forum_name_key ON parley (name);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  authentication_id integer(4),
  last_name text NOT NULL,
  email text NOT NULL,
  forum_name text NOT NULL,
  preference_id integer(4),
  last_post_id integer(4),
  post_count integer(4) NOT NULL DEFAULT 0,
  first_name text NOT NULL,
  suspended  NOT NULL
);

CREATE INDEX parley.person_idx_authentication_id ON parley (authentication_id);

CREATE INDEX parley.person_idx_last_post_id ON parley (last_post_id);

CREATE INDEX parley.person_idx_preference_id ON parley (preference_id);

CREATE UNIQUE INDEX person_email_key ON parley (email);

CREATE UNIQUE INDEX person_forum_name_key ON parley (forum_name);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  recipient_id integer(4) NOT NULL,
  cc_id integer(4),
  bcc_id integer(4),
  sender text,
  subject text NOT NULL,
  html_content text,
  attempted_delivery boolean(1) NOT NULL DEFAULT 'false',
  text_content text NOT NULL,
  queued timestamp with time zone(8) NOT NULL DEFAULT 'now()'
);

CREATE INDEX parley.email_queue_idx_bcc_id ON parley (bcc_id);

CREATE INDEX parley.email_queue_idx_cc_id ON parley (cc_id);

CREATE INDEX parley.email_queue_idx_recipient_id ON parley (recipient_id);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  recipient_id integer(4) NOT NULL,
  expires timestamp without time zone(8)
);

CREATE INDEX parley.password_reset_idx_recipient_id ON parley (recipient_id);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id text NOT NULL,
  recipient_id integer(4) NOT NULL,
  expires date(4),
  PRIMARY KEY (id)
);

CREATE INDEX parley.registration_authentication_idx_recipient_id ON parley (recipient_id);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id  NOT NULL,
  person_id  NOT NULL,
  admin_id  NOT NULL,
  created  NOT NULL,
  message  NOT NULL,
  action_id  NOT NULL,
  PRIMARY KEY (id)
);

CREATE INDEX parley.log_admin_action_idx_action_id ON parley (action_id);

CREATE INDEX parley.log_admin_action_idx_person_id ON parley (person_id);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  person_id integer NOT NULL,
  terms_id integer NOT NULL,
  accepted_on timestamp with time zone NOT NULL
);

CREATE INDEX parley.terms_agreed_idx_person_id ON parley (person_id);

CREATE INDEX parley.terms_agreed_idx_terms_id ON parley (terms_id);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  locked boolean(1) NOT NULL DEFAULT 'false',
  creator_id integer(4) NOT NULL,
  subject text NOT NULL,
  active boolean(1) NOT NULL DEFAULT 'true',
  forum_id integer(4) NOT NULL,
  created timestamp with time zone(8) DEFAULT 'now()',
  last_post_id integer(4),
  sticky boolean(1) NOT NULL DEFAULT 'false',
  post_count integer(4) NOT NULL DEFAULT 0,
  view_count integer(4) NOT NULL DEFAULT 0
);

CREATE INDEX parley.thread_idx_creator_id ON parley (creator_id);

CREATE INDEX parley.thread_idx_forum_id ON parley (forum_id);

CREATE INDEX parley.thread_idx_last_post_id ON parley (last_post_id);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id  NOT NULL,
  person_id integer(4) NOT NULL,
  forum_id integer(4) NOT NULL,
  can_moderate boolean(1) NOT NULL DEFAULT 'false',
  PRIMARY KEY (id)
);

CREATE INDEX parley.forum_moderator_idx_forum_id ON parley (forum_id);

CREATE INDEX parley.forum_moderator_idx_person_id ON parley (person_id);

CREATE UNIQUE INDEX forum_moderator_person_key ON parley (person_id, forum_id);

--
-- Table: parley
--
DROP TABLE parley;

CREATE TABLE parley (
  id INTEGER PRIMARY KEY NOT NULL,
  watched boolean(1) NOT NULL DEFAULT 'false',
  last_notified timestamp with time zone(8),
  thread_id integer(4) NOT NULL,
  timestamp timestamp with time zone(8) NOT NULL DEFAULT 'now()',
  person_id integer(4) NOT NULL
);

CREATE INDEX parley.thread_view_idx_person_id ON parley (person_id);

CREATE INDEX parley.thread_view_idx_thread_id ON parley (thread_id);

CREATE UNIQUE INDEX thread_view_person_key ON parley (person_id, thread_id);

COMMIT;
