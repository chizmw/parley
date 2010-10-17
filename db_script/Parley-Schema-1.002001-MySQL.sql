-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Sun Oct 17 13:51:48 2010
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id`  NOT NULL,
  `name`  NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer(4) NOT NULL,
  `password` text NOT NULL,
  `authenticated` enum('0','1') NOT NULL DEFAULT 'false',
  `username` text NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `authentication_username_key` (`username`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id`  NOT NULL,
  `name`  NOT NULL,
  `description`  NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE `unique_ban_name` (`name`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer(4) NOT NULL,
  `time_string` text NOT NULL,
  `sample` text NOT NULL,
  `comment` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id`  NOT NULL,
  `idx`  NOT NULL,
  `name`  NOT NULL,
  `description`  NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id`  NOT NULL,
  `session_data`  NOT NULL,
  `expires`  NOT NULL,
  `created`  NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer NOT NULL,
  `created` timestamp with time zone NOT NULL,
  `content` text NOT NULL,
  `change_summary` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id`  NOT NULL,
  `ban_type_id`  NOT NULL,
  `ip_range`  NOT NULL,
  INDEX `parley.ip_ban_idx_ban_type_id` (`ban_type_id`),
  PRIMARY KEY (`id`),
  UNIQUE `unique_ip_ban_type` (`ban_type_id`),
  CONSTRAINT `parley.ip_ban_fk_ban_type_id` FOREIGN KEY (`ban_type_id`) REFERENCES `parley.ip_ban_type` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer(4) NOT NULL,
  `timezone` text NOT NULL DEFAULT 'UTC',
  `time_format_id` integer(4) NOT NULL,
  `show_tz` enum('0','1') NOT NULL DEFAULT 'true',
  `notify_thread_watch` enum('0','1') NOT NULL DEFAULT 'false',
  `watch_on_post` enum('0','1') NOT NULL DEFAULT 'false',
  `skin` text NOT NULL DEFAULT 'base',
  INDEX `parley.preference_idx_time_format_id` (`time_format_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `parley.preference_fk_time_format_id` FOREIGN KEY (`time_format_id`) REFERENCES `parley.preference_time_string` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer(4) NOT NULL,
  `creator_id` integer(4) NOT NULL,
  `subject` text,
  `quoted_post_id` integer(4),
  `message` text NOT NULL,
  `quoted_text` text,
  `created` timestamp with time zone(8) DEFAULT 'now()',
  `thread_id` integer(4) NOT NULL,
  `reply_to_id` integer(4),
  `edited` timestamp with time zone(8),
  `ip_addr` inet(8),
  `admin_editor_id`  NOT NULL,
  `locked`  NOT NULL,
  INDEX `parley.post_idx_admin_editor_id` (`admin_editor_id`),
  INDEX `parley.post_idx_creator_id` (`creator_id`),
  INDEX `parley.post_idx_quoted_post_id` (`quoted_post_id`),
  INDEX `parley.post_idx_reply_to_id` (`reply_to_id`),
  INDEX `parley.post_idx_thread_id` (`thread_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `parley.post_fk_admin_editor_id` FOREIGN KEY (`admin_editor_id`) REFERENCES `parley.person` (`id`),
  CONSTRAINT `parley.post_fk_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `parley.person` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `parley.post_fk_quoted_post_id` FOREIGN KEY (`quoted_post_id`) REFERENCES `parley.post` (`id`),
  CONSTRAINT `parley.post_fk_reply_to_id` FOREIGN KEY (`reply_to_id`) REFERENCES `parley.post` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `parley.post_fk_thread_id` FOREIGN KEY (`thread_id`) REFERENCES `parley.thread` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id`  NOT NULL,
  `authentication_id`  NOT NULL,
  `role_id`  NOT NULL,
  INDEX `parley.user_roles_idx_authentication_id` (`authentication_id`),
  INDEX `parley.user_roles_idx_role_id` (`role_id`),
  PRIMARY KEY (`id`),
  UNIQUE `userroles_authentication_role_key` (`authentication_id`, `role_id`),
  CONSTRAINT `parley.user_roles_fk_authentication_id` FOREIGN KEY (`authentication_id`) REFERENCES `parley.authentication` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `parley.user_roles_fk_role_id` FOREIGN KEY (`role_id`) REFERENCES `parley.role` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer(4) NOT NULL,
  `last_post_id` integer(4),
  `post_count` integer(4) NOT NULL DEFAULT 0,
  `active` enum('0','1') NOT NULL DEFAULT 'true',
  `name` text NOT NULL,
  `description` text,
  INDEX `parley.forum_idx_last_post_id` (`last_post_id`),
  PRIMARY KEY (`id`),
  UNIQUE `forum_name_key` (`name`),
  CONSTRAINT `parley.forum_fk_last_post_id` FOREIGN KEY (`last_post_id`) REFERENCES `parley.post` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer(4) NOT NULL,
  `authentication_id` integer(4),
  `last_name` text NOT NULL,
  `email` text NOT NULL,
  `forum_name` text NOT NULL,
  `preference_id` integer(4),
  `last_post_id` integer(4),
  `post_count` integer(4) NOT NULL DEFAULT 0,
  `first_name` text NOT NULL,
  `suspended`  NOT NULL,
  INDEX `parley.person_idx_authentication_id` (`authentication_id`),
  INDEX `parley.person_idx_last_post_id` (`last_post_id`),
  INDEX `parley.person_idx_preference_id` (`preference_id`),
  PRIMARY KEY (`id`),
  UNIQUE `person_email_key` (`email`),
  UNIQUE `person_forum_name_key` (`forum_name`),
  CONSTRAINT `parley.person_fk_authentication_id` FOREIGN KEY (`authentication_id`) REFERENCES `parley.authentication` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `parley.person_fk_last_post_id` FOREIGN KEY (`last_post_id`) REFERENCES `parley.post` (`id`),
  CONSTRAINT `parley.person_fk_preference_id` FOREIGN KEY (`preference_id`) REFERENCES `parley.preference` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer(4) NOT NULL,
  `recipient_id` integer(4) NOT NULL,
  `cc_id` integer(4),
  `bcc_id` integer(4),
  `sender` text,
  `subject` text NOT NULL,
  `html_content` text,
  `attempted_delivery` enum('0','1') NOT NULL DEFAULT 'false',
  `text_content` text NOT NULL,
  `queued` timestamp with time zone(8) NOT NULL DEFAULT 'now()',
  INDEX `parley.email_queue_idx_bcc_id` (`bcc_id`),
  INDEX `parley.email_queue_idx_cc_id` (`cc_id`),
  INDEX `parley.email_queue_idx_recipient_id` (`recipient_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `parley.email_queue_fk_bcc_id` FOREIGN KEY (`bcc_id`) REFERENCES `parley.person` (`id`),
  CONSTRAINT `parley.email_queue_fk_cc_id` FOREIGN KEY (`cc_id`) REFERENCES `parley.person` (`id`),
  CONSTRAINT `parley.email_queue_fk_recipient_id` FOREIGN KEY (`recipient_id`) REFERENCES `parley.person` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer NOT NULL,
  `recipient_id` integer(4) NOT NULL,
  `expires` timestamp without time zone(8),
  INDEX `parley.password_reset_idx_recipient_id` (`recipient_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `parley.password_reset_fk_recipient_id` FOREIGN KEY (`recipient_id`) REFERENCES `parley.person` (`id`)
);

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` text NOT NULL,
  `recipient_id` integer(4) NOT NULL,
  `expires` date,
  INDEX `parley.registration_authentication_idx_recipient_id` (`recipient_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `parley.registration_authentication_fk_recipient_id` FOREIGN KEY (`recipient_id`) REFERENCES `parley.person` (`id`)
);

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id`  NOT NULL,
  `person_id`  NOT NULL,
  `admin_id`  NOT NULL,
  `created`  NOT NULL,
  `message`  NOT NULL,
  `action_id`  NOT NULL,
  INDEX `parley.log_admin_action_idx_action_id` (`action_id`),
  INDEX `parley.log_admin_action_idx_person_id` (`person_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `parley.log_admin_action_fk_action_id` FOREIGN KEY (`action_id`) REFERENCES `parley.admin_action` (`id`),
  CONSTRAINT `parley.log_admin_action_fk_person_id` FOREIGN KEY (`person_id`) REFERENCES `parley.person` (`id`)
);

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer NOT NULL,
  `person_id` integer NOT NULL,
  `terms_id` integer NOT NULL,
  `accepted_on` timestamp with time zone NOT NULL,
  INDEX `parley.terms_agreed_idx_person_id` (`person_id`),
  INDEX `parley.terms_agreed_idx_terms_id` (`terms_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `parley.terms_agreed_fk_person_id` FOREIGN KEY (`person_id`) REFERENCES `parley.person` (`id`),
  CONSTRAINT `parley.terms_agreed_fk_terms_id` FOREIGN KEY (`terms_id`) REFERENCES `parley.terms` (`id`)
);

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer(4) NOT NULL,
  `locked` enum('0','1') NOT NULL DEFAULT 'false',
  `creator_id` integer(4) NOT NULL,
  `subject` text NOT NULL,
  `active` enum('0','1') NOT NULL DEFAULT 'true',
  `forum_id` integer(4) NOT NULL,
  `created` timestamp with time zone(8) DEFAULT 'now()',
  `last_post_id` integer(4),
  `sticky` enum('0','1') NOT NULL DEFAULT 'false',
  `post_count` integer(4) NOT NULL DEFAULT 0,
  `view_count` integer(4) NOT NULL DEFAULT 0,
  INDEX `parley.thread_idx_creator_id` (`creator_id`),
  INDEX `parley.thread_idx_forum_id` (`forum_id`),
  INDEX `parley.thread_idx_last_post_id` (`last_post_id`),
  PRIMARY KEY (`id`),
  CONSTRAINT `parley.thread_fk_creator_id` FOREIGN KEY (`creator_id`) REFERENCES `parley.person` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `parley.thread_fk_forum_id` FOREIGN KEY (`forum_id`) REFERENCES `parley.forum` (`id`),
  CONSTRAINT `parley.thread_fk_last_post_id` FOREIGN KEY (`last_post_id`) REFERENCES `parley.post` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id`  NOT NULL,
  `person_id` integer(4) NOT NULL,
  `forum_id` integer(4) NOT NULL,
  `can_moderate` enum('0','1') NOT NULL DEFAULT 'false',
  INDEX `parley.forum_moderator_idx_forum_id` (`forum_id`),
  INDEX `parley.forum_moderator_idx_person_id` (`person_id`),
  PRIMARY KEY (`id`),
  UNIQUE `forum_moderator_person_key` (`person_id`, `forum_id`),
  CONSTRAINT `parley.forum_moderator_fk_forum_id` FOREIGN KEY (`forum_id`) REFERENCES `parley.forum` (`id`),
  CONSTRAINT `parley.forum_moderator_fk_person_id` FOREIGN KEY (`person_id`) REFERENCES `parley.person` (`id`)
);

DROP TABLE IF EXISTS `parley`;

--
-- Table: `parley`
--
CREATE TABLE `parley` (
  `id` integer(4) NOT NULL,
  `watched` enum('0','1') NOT NULL DEFAULT 'false',
  `last_notified` timestamp with time zone(8),
  `thread_id` integer(4) NOT NULL,
  `timestamp` timestamp with time zone(8) NOT NULL DEFAULT 'now()',
  `person_id` integer(4) NOT NULL,
  INDEX `parley.thread_view_idx_person_id` (`person_id`),
  INDEX `parley.thread_view_idx_thread_id` (`thread_id`),
  PRIMARY KEY (`id`),
  UNIQUE `thread_view_person_key` (`person_id`, `thread_id`),
  CONSTRAINT `parley.thread_view_fk_person_id` FOREIGN KEY (`person_id`) REFERENCES `parley.person` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `parley.thread_view_fk_thread_id` FOREIGN KEY (`thread_id`) REFERENCES `parley.thread` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
);

SET foreign_key_checks=1;

