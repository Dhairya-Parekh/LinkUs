DROP TABLE IF EXISTS message_actions;
DROP TABLE IF EXISTS delete_messages;
DROP TABLE IF EXISTS group_actions;
DROP TABLE IF EXISTS reacts;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS links;
DROP TABLE IF EXISTS participants;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS users;

CREATE TABLE users
(
    user_id varchar(36) not null,
    user_name varchar(15) not null unique,
    passcode varchar(256) not null,
    email varchar(40) not null,
    primary key (user_id)
);

CREATE TABLE groups
(
    group_id varchar(36) not null,
    group_name varchar(15) not null,
    group_info varchar(150) default null,
    primary key (group_id)
);

CREATE TABLE participants
(
    user_id varchar(36) not null,
    group_id varchar(36) not null,
    roles varchar(3) not null,
    primary key (group_id, user_id),
    foreign key (group_id) references groups on delete CASCADE,
    foreign key (user_id) references users on delete CASCADE
);

CREATE TABLE links
(
    link_id varchar(36) not null,
    sender_id varchar(36) default null,
    group_id varchar(36) not null,
    title varchar(50) default 'New Book',
    link varchar(256) not null,
    info varchar(100) default null,
    time_stamp timestamp not null,
    primary key (link_id),
    foreign key (group_id) references groups on delete CASCADE,
    foreign key (sender_id) references users on delete set default
);

CREATE TABLE tags
(
    link_id varchar(36) not null,
    tags varchar(15) not null,
    primary key (link_id, tags),
    foreign key (link_id) references links on delete CASCADE
);

CREATE TABLE reacts
(
    user_id varchar(36) not null,
    link_id varchar(36) not null,
    react varchar(1),
    primary key (user_id, link_id),
    foreign key (link_id) references links on delete CASCADE,
    foreign key (user_id) references users on delete CASCADE
);

CREATE TABLE message_actions
(
    receiver_id varchar(36) not null,
    sender_id varchar(36) not null,
    link_id varchar(36) not null,
    time_stamp timestamp not null,
    action_type varchar(3),
    primary key (sender_id, receiver_id, link_id, time_stamp),
    foreign key (link_id) references links on delete CASCADE,
    foreign key (sender_id) references users on delete CASCADE,
    foreign key (receiver_id) references users on delete CASCADE
);

CREATE TABLE delete_messages
(
    receiver_id varchar(36) not null,
    sender_id varchar(36) not null,
    link_id varchar(36) not null,
    time_stamp timestamp not null,
    primary key (sender_id, receiver_id, link_id, time_stamp),
    foreign key (sender_id) references users on delete CASCADE,
    foreign key (receiver_id) references users on delete CASCADE
);

CREATE TABLE group_actions
(
    receiver_id varchar(36) not null,
    group_id varchar(36) not null,
    affected_id varchar(36) not null,
    affected_role varchar(3) default null,
    time_stamp timestamp not null,
    action_type varchar(3) not null,
    primary key (receiver_id, affected_id, group_id, time_stamp, action_type),
    foreign key (group_id) references groups on delete CASCADE,
    foreign key (affected_id) references users on delete CASCADE,
    foreign key (receiver_id) references users on delete CASCADE
);