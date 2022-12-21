insert into "person" (email, full_name, password)
values ('some@gmail.com', 'John Sina', 'passw');
insert into "person" (email, full_name, password)
values ('someother@gmail.com', 'John MacClein', 'passw1');
insert into "person" (email, full_name, password)
values ('user@gmail.com', 'Vito Scaletto', 'passw2');
insert into "person" (email, full_name, password)
values ('mac95@gmail.com', 'MacQuin', 'passw3');
insert into "person" (email, full_name, password)
values ('someother2@gmail.com', 'Mike Townsend', 'passw4');
insert into "person" (email, full_name, password)
values ('lina@service.com', 'Lina Ebbet', 'passw5');

insert into "customer" (person_id, rate, status)
values (1, null, 'active');
insert into "customer" (person_id, rate, status)
values (2, null, 'banned');

insert into "executor" (person_id, rate, status)
values (3, null, 'active');
insert into "executor" (person_id, rate, status)
values (4, null, 'active');
insert into "executor" (person_id, rate, status)
values (5, null, 'banned');

insert into "moderator" (person_id)
values (6);

insert into competence (competence) values ('plumber');
insert into competence (competence) values ('electrician');
insert into competence (competence) values ('manicurist');
insert into competence (competence) values ('glazier');

insert into executor_competence values (1, 1);
insert into executor_competence values (2, 1);
insert into executor_competence values (2, 2);
insert into executor_competence values (3, 3);
insert into executor_competence values (3, 4);