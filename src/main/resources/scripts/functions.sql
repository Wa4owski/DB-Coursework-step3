create or replace function add_order(p_customer_id int, p_competence_id int, p_price int, p_description text) returns boolean as $$
begin
        if ((select status from customer where customer.id = p_customer_id) = 'banned') then
            raise notice 'customer % is banned', p_customer_id;
return false;
end if;
insert into "order_request" (customer_id, competence_id, price, description)
values (p_customer_id, p_competence_id, p_price, p_description);
return true;
end;
$$ language plpgsql;

select add_order(2, 2, 123, 'work');

create or replace function add_order_and_particular_executor(p_customer_id int, p_executor_id int, p_competence_id int, p_price int, p_description text) returns boolean as $$
    declare
cur_order_request_id int;
begin

        if ((select status from customer where customer.id = p_customer_id) = 'banned') then
            raise notice 'customer % is banned', p_customer_id;
return false;
end if;
        if ((select status from executor where executor.id = p_executor_id) = 'banned') then
            raise notice 'executor % is banned', p_executor_id;
return false;
end if;
        if ((select count(*) from executor_competence where executor_competence.executor_id = p_executor_id
                                                        and executor_competence.competence_id = p_competence_id) = 0) then
            raise notice 'executor % has no needed competence', p_executor_id;
return false;
end if;

insert into "order_request" (customer_id, competence_id, price, description, customer_default_agr)
values (p_customer_id, p_competence_id, p_price, p_description, true) returning id into cur_order_request_id;
insert into "order_requests_executors" (order_request_id, executor_id, customer_agr, executor_agr)
values (cur_order_request_id, p_executor_id, true, false);

return true;
end;
$$ language plpgsql;



select add_order_and_particular_executor(1, 2, 4, 10000, 'fix sine');

drop function get_feedback(p_order_id int, p_author client_type, p_rate int, p_feedback text, ticket_flag boolean);

create or replace function set_feedback(p_order_id int, p_author client_type, p_rate int, p_feedback text, ticket_flag boolean) returns void as $$
    insert into feedback (order_id, author, rate, feedback, author_wants_ticket)
    values (p_order_id, p_author, p_rate, p_feedback, ticket_flag);
$$ language SQL;

create or replace function chose_competence(p_executor_id int, p_competence_id int) returns void as $$
    insert into executor_competence values (p_executor_id, p_competence_id);
$$ language SQL;

create or replace function add_docs(p_executor_id int, doc bytea) returns void as $$
    insert into executor_competence values (p_executor_id, doc);
$$ language SQL;

create or replace function choose_order_request(p_executor_id int, p_order_request_id int) returns boolean as $$
begin
        if ((select count(*) from order_requests_executors where order_request_id = p_order_request_id
            and executor_id = p_executor_id) > 0) then
update order_requests_executors set executor_agr = true where order_request_id = p_order_request_id
                                                          and executor_id = p_executor_id;
return true;
end if;
        if ((select customer_default_agr from order_request where order_request.id = p_order_request_id) is true) then
            raise notice 'order % is private, not for this executor', p_order_request_id;
return false;
end if;
insert into order_requests_executors (order_request_id, executor_id, customer_agr, executor_agr)
values (p_order_request_id, p_executor_id, false, true);
return true;
end;
$$ language plpgsql;