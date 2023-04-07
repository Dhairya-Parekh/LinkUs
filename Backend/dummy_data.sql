5e50259f-adfe-4804-a073-5b0c9cabca37
99cdfab2-3f47-45c1-88bf-54cc8058cbbf
762465ca-175c-4421-b60c-012a5ec9f9c1
a8ee418a-5234-4132-bb8c-f38123494ea3
19e68428-e21a-4775-99cc-e823f4fa4dd3
8aecacf5-1899-4a4c-a231-84e2c85cdca9
46d30485-6f56-4caf-a1ab-0e3fd276fb8a
49ddc793-896f-43df-9740-2a74ea36f583
87a1f4d2-04c8-4ed5-a409-bcca0e4ac2ca
b2ed3a45-28f7-49b1-97ee-1d8fd98a651a

insert into users (user_id, user_name, passcode, email_id) values ('66ca74e6-367d-4b35-9de2-775e65eae0df', 'dummy1', 'pass1', 'mail1');
insert into users (user_id, user_name, passcode, email_id) values ('bf4cbb44-b618-4e7a-bf4d-9a84fce02ec3', 'dummy2', 'pass2', 'mail2');
insert into users (user_id, user_name, passcode, email_id) values ('26ac7a05-1708-4f47-bd4a-ee4727b3bb3f', 'dummy3', 'pass3', 'mail3');
insert into users (user_id, user_name, passcode, email_id) values ('9564050c-2921-476b-b317-ca321d3cd4ea', 'dummy4', 'pass4', 'mail4');
insert into users (user_id, user_name, passcode, email_id) values ('760463f2-4a4c-486d-b824-db8ec20b7ab5', 'dummy5', 'pass5', 'mail5');

insert into groups (group_id, group_name, group_info) values ('7b8e8a13-bb0b-4d68-b6c6-5d7c9ee7f38c', 'group1', 'info1');
insert into groups (group_id, group_name, group_info) values ('c959b80e-da93-4211-88e8-a0e807b68024', 'group2', 'info2');
insert into groups (group_id, group_name, group_info) values ('dc8e11e2-6d55-47ce-bbd8-952b86ef4db8', 'group3', 'info3');
insert into groups (group_id, group_name, group_info) values ('055e3795-f380-4928-bb87-e29c9513129b', 'group4', 'info4');
insert into groups (group_id, group_name, group_info) values ('d84eb2d5-7523-4faf-a923-eb855cf4679a', 'group5', 'info5');

insert into participants (user_id, group_id, roles) values ('66ca74e6-367d-4b35-9de2-775e65eae0df', '7b8e8a13-bb0b-4d68-b6c6-5d7c9ee7f38c', 'adm');
insert into participants (user_id, group_id, roles) values ('66ca74e6-367d-4b35-9de2-775e65eae0df', 'c959b80e-da93-4211-88e8-a0e807b68024', 'adm');
insert into participants (user_id, group_id, roles) values ('9564050c-2921-476b-b317-ca321d3cd4ea', 'dc8e11e2-6d55-47ce-bbd8-952b86ef4db8', 'adm');
insert into participants (user_id, group_id, roles) values ('66ca74e6-367d-4b35-9de2-775e65eae0df', 'd84eb2d5-7523-4faf-a923-eb855cf4679a', 'adm');
insert into participants (user_id, group_id, roles) values ('26ac7a05-1708-4f47-bd4a-ee4727b3bb3f', 'c959b80e-da93-4211-88e8-a0e807b68024', 'adm');
insert into participants (user_id, group_id, roles) values ('760463f2-4a4c-486d-b824-db8ec20b7ab5', '7b8e8a13-bb0b-4d68-b6c6-5d7c9ee7f38c', 'adm');
insert into participants (user_id, group_id, roles) values ('bf4cbb44-b618-4e7a-bf4d-9a84fce02ec3', 'dc8e11e2-6d55-47ce-bbd8-952b86ef4db8', 'mem');
insert into participants (user_id, group_id, roles) values ('9564050c-2921-476b-b317-ca321d3cd4ea', '7b8e8a13-bb0b-4d68-b6c6-5d7c9ee7f38c', 'mem');
insert into participants (user_id, group_id, roles) values ('66ca74e6-367d-4b35-9de2-775e65eae0df', '055e3795-f380-4928-bb87-e29c9513129b', 'adm');
insert into participants (user_id, group_id, roles) values ('bf4cbb44-b618-4e7a-bf4d-9a84fce02ec3', '055e3795-f380-4928-bb87-e29c9513129b', 'mem');
insert into participants (user_id, group_id, roles) values ('66ca74e6-367d-4b35-9de2-775e65eae0df', 'd84eb2d5-7523-4faf-a923-eb855cf4679a', 'mem');
insert into participants (user_id, group_id, roles) values ('66ca74e6-367d-4b35-9de2-775e65eae0df', 'd84eb2d5-7523-4faf-a923-eb855cf4679a', 'mem');
insert into participants (user_id, group_id, roles) values ('9564050c-2921-476b-b317-ca321d3cd4ea', '055e3795-f380-4928-bb87-e29c9513129b', 'mem');
insert into participants (user_id, group_id, roles) values ('bf4cbb44-b618-4e7a-bf4d-9a84fce02ec3', 'd84eb2d5-7523-4faf-a923-eb855cf4679a', 'mem');
insert into participants (user_id, group_id, roles) values ('26ac7a05-1708-4f47-bd4a-ee4727b3bb3f', '055e3795-f380-4928-bb87-e29c9513129b', 'mem');
insert into participants (user_id, group_id, roles) values ('bf4cbb44-b618-4e7a-bf4d-9a84fce02ec3', '7b8e8a13-bb0b-4d68-b6c6-5d7c9ee7f38c', 'mem');
insert into participants (user_id, group_id, roles) values ('760463f2-4a4c-486d-b824-db8ec20b7ab5', 'c959b80e-da93-4211-88e8-a0e807b68024', 'mem');
insert into participants (user_id, group_id, roles) values ('bf4cbb44-b618-4e7a-bf4d-9a84fce02ec3', 'dc8e11e2-6d55-47ce-bbd8-952b86ef4db8', 'mem');
insert into participants (user_id, group_id, roles) values ('26ac7a05-1708-4f47-bd4a-ee4727b3bb3f', '7b8e8a13-bb0b-4d68-b6c6-5d7c9ee7f38c', 'mem');
insert into participants (user_id, group_id, roles) values ('26ac7a05-1708-4f47-bd4a-ee4727b3bb3f', 'dc8e11e2-6d55-47ce-bbd8-952b86ef4db8', 'mem');