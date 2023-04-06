CREATE TABLE users
(
    user_id numeric(4,0) not null,
    user_name varchar(15) not null,
    passcode varchar(15) not null,
    email_id varchar(40) not null,
    primary key (user_id)
);

CREATE TABLE groups
(
    group_id numeric(4,0) not null,
    group_name varchar(15) not null,
    group_info varchar(150) default null,
    primary key (group_id)
);

CREATE TABLE participants
(
    group_id numeric(4,0) not null,
    user_id numeric(4,0) not null,
    roles varchar(3) not null,
    primary key (group_id, user_id),
    foreign key (group_id) references groups on delete CASCADE,
    foreign key (user_id) references users on delete CASCADE
);

CREATE TABLE links
(
    link_id numeric(4,0) not null,
    group_id numeric(4,0) not null,
    sender_id numeric(4,0) default null,
    title varchar(50) default "New Book",
    link varchar(256) not null,
    time_stamp timestamp not null,
    descrpition varchar(100) default null,
    primary key (link_id),
    foreign key (group_id) references groups on delete CASCADE,
    foreign key (user_id) references users on delete set default
);

CREATE TABLE tags
(
    link_id numeric(4,0) not null,
    tags varchar(15) not null,
    primary key (user_id, tags),
    foreign key (link_id) references links on delete CASCADE
);

CREATE TABLE reacts
(
    user_id numeric(4,0) not null,
    link_id numeric(4,0) not null,
    react varchar(1),
    primary key (user_id, link_id),
    foreign key (link_id) references links on delete CASCADE,
    foreign key (user_id) references users on delete CASCADE
);

CREATE TABLE message_actions
(
    receiver_id numeric(4,0) not null,
    sender_id numeric(4,0) not null,
    link_id numeric(4,0) not null,
    time_stamp timestamp not null,
    action_type varchar(3),
    primary key (sender_id, receiver_id, link_id),
    foreign key (link_id) references links on delete CASCADE,
    foreign key (sender_id) references users on delete CASCADE,
    foreign key (receiver_id) references users on delete CASCADE
);

CREATE TABLE group_actions
(
    receiver_id numeric(4,0) not null,
    group_id numeric(4,0) not null,
    affected_id numeric(4,0) not null,
    affected_role varchar(3) default null,
    time_stamp timestamp not null,
    action_type varchar(3) not null,
    primary key (receiver_id, affected_id, group_id, time_stamp),
    foreign key (group_id) references groups on delete CASCADE,
    foreign key (affected_id) references users on delete CASCADE,
    foreign key (receiver_id) references users on delete CASCADE
);