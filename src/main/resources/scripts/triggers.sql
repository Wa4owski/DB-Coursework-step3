create or replace function form_new_order() returns trigger as $$
    begin
        insert into "order" (order_request_id, customer_id, executor_id, status)
        values (
           new.order_request_id,
           (select customer_id from order_request where order_request.id = new.order_request_id),
           new.executor_id,
           'started'
        );
    return new;
    end;
$$ language plpgsql;

create trigger order_requests_executors_agr
    after update or insert on order_requests_executors
    for each row
    when (new.customer_agr = true and new.executor_agr = true)
    execute function form_new_order();


create or replace function process_feedback() returns trigger as $$
    declare
        cur_executor_id int := (select executor_id from "order" where "order".id = new.order_id);
        cur_customer_id int := (select customer_id from "order" where "order".id = new.order_id);
    begin
        update "order" set status = 'finished' where "order".id = new.order_id;

        if (new.author = 'customer') then
            update executor set rate = (select avg(rate) from feedback inner join "order"
                                      on feedback.order_id = "order".id where feedback.author = 'customer')
                                     where executor.id = cur_executor_id;
        elsif (new.author = 'executor') then
            update customer set rate = (select avg(rate) from feedback inner join "order"
                                      on feedback.order_id = "order".id where feedback.author = 'executor')
                                        where customer.id = cur_customer_id;
        end if;

        if (TG_OP = 'INSERT' and new.author_wants_ticket = true) then
            insert into ticket (order_id, moderator_id)
            values (new.order_id, (select id from moderator order by random() limit 1));
        end if;

        return new;
    end;
$$ language plpgsql;

create trigger feedback_tr
    after insert or update on feedback
    for each row
    execute function process_feedback();


create or replace function process_verdict() returns trigger as $$
    declare
        cur_executor_id int := (select executor_id from "order" where "order".id = new.order_id);
        cur_customer_id int := (select customer_id from "order" where "order".id = new.order_id);
    begin
        if (new.new_rate_for_executor IS NOT NULL) then
            update feedback set rate = new.new_rate_for_executor where
            feedback.order_id = new.order_id and feedback.author = 'customer';
        end if;

        if (new.new_rate_for_customer IS NOT NULL) then
            update feedback set rate = new.new_rate_for_customer where
            feedback.order_id = new.order_id and feedback.author = 'executor';
        end if;

        if (new.delete_feedback_about_executor = true) then
            update feedback set feedback = null where
            feedback.order_id = new.order_id and feedback.author = 'customer';
        end if;

        if (new.delete_feedback_about_customer = true) then
            update feedback set feedback = null where
            feedback.order_id = new.order_id and feedback.author = 'executor';
        end if;

        if (new.ban_customer = true) then
            update customer set status = 'banned' where customer.id = cur_customer_id;
            update order_request set status = 'closed' where order_request.customer_id = cur_customer_id;
        end if;

        if (new.ban_executor = true) then
            update executor set status = 'banned' where executor.id = cur_executor_id;
            update order_requests_executors set executor_agr = false where order_requests_executors.executor_id = cur_executor_id;
        end if;

        return new;
    end;
$$ language plpgsql;

create trigger verdict_tr
    after insert or update on verdict
    for each row
    execute function process_verdict();