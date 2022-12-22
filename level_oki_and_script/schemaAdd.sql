create view vw_sc_call_tech_technika(id, id_call, id_tech, send_time, id_oper_send, at_place_time, id_oper_at_place, return_time, id_oper_return, at_base_time, id_oper_at_base, retreat_time, id_oper_retreat, redirect_time, id_call_redirect, id_oper_redirect, id_call_name, receive_time, id_oper_receive, to_hospital, id_oper_to_hospital, at_hospital, id_oper_at_hospital, id_center, id_send_type, re_hospital, id_oper_re_hospital, re_at_hospital, id_oper_re_at_hospital, tech_deleted, id_tech_type, id_trans_type, send_type_text, id_duty, id_sync_tech) as
SELECT call_tech.id,
       call_tech.id_call,
       call_tech.id_tech,
       call_tech.send_time,
       call_tech.id_oper_send,
       call_tech.at_place_time,
       call_tech.id_oper_at_place,
       call_tech.return_time,
       call_tech.id_oper_return,
       call_tech.at_base_time,
       call_tech.id_oper_at_base,
       call_tech.retreat_time,
       call_tech.id_oper_retreat,
       call_tech.redirect_time,
       call_tech.id_call_redirect,
       call_tech.id_oper_redirect,
       call_tech.id_call_name,
       call_tech.receive_time,
       call_tech.id_oper_receive,
       call_tech.to_hospital,
       call_tech.id_oper_to_hospital,
       call_tech.at_hospital,
       call_tech.id_oper_at_hospital,
       call_tech.id_center,
       call_tech.id_send_type,
       call_tech.re_hospital,
       call_tech.id_oper_re_hospital,
       call_tech.re_at_hospital,
       call_tech.id_oper_re_at_hospital,
       call_tech.tech_deleted,
       call_tech.id_tech_type,
       call_tech.id_trans_type,
       call_tech.send_type_text,
       call_tech.id_duty,
       call_tech.id_sync_tech
FROM (call_tech
         LEFT JOIN technika ON ((call_tech.id_tech = technika.id)))
WHERE (technika.is_brigade = (0)::numeric);


create view vw_sc_call_tech_brigade(id, id_call, id_tech, send_time, id_oper_send, at_place_time, id_oper_at_place, return_time, id_oper_return, at_base_time, id_oper_at_base, retreat_time, id_oper_retreat, redirect_time, id_call_redirect, id_oper_redirect, id_call_name, receive_time, id_oper_receive, to_hospital, id_oper_to_hospital, at_hospital, id_oper_at_hospital, id_center, id_send_type, re_hospital, id_oper_re_hospital, re_at_hospital, id_oper_re_at_hospital, tech_deleted, id_tech_type, id_trans_type, send_type_text, id_duty, id_sync_tech) as
SELECT call_tech.id,
       call_tech.id_call,
       call_tech.id_tech,
       call_tech.send_time,
       call_tech.id_oper_send,
       call_tech.at_place_time,
       call_tech.id_oper_at_place,
       call_tech.return_time,
       call_tech.id_oper_return,
       call_tech.at_base_time,
       call_tech.id_oper_at_base,
       call_tech.retreat_time,
       call_tech.id_oper_retreat,
       call_tech.redirect_time,
       call_tech.id_call_redirect,
       call_tech.id_oper_redirect,
       call_tech.id_call_name,
       call_tech.receive_time,
       call_tech.id_oper_receive,
       call_tech.to_hospital,
       call_tech.id_oper_to_hospital,
       call_tech.at_hospital,
       call_tech.id_oper_at_hospital,
       call_tech.id_center,
       call_tech.id_send_type,
       call_tech.re_hospital,
       call_tech.id_oper_re_hospital,
       call_tech.re_at_hospital,
       call_tech.id_oper_re_at_hospital,
       call_tech.tech_deleted,
       call_tech.id_tech_type,
       call_tech.id_trans_type,
       call_tech.send_type_text,
       call_tech.id_duty,
       call_tech.id_sync_tech
FROM (call_tech
         LEFT JOIN technika ON ((call_tech.id_tech = technika.id)))
WHERE (technika.is_brigade = (1)::numeric);




create view vw_sc_for_first_call_sign as
    SELECT c.id, coalesce(max(le.is_following),0) as is_first_call
    FROM call_event c left join linked_event le on c.id = le.id group by c.id;




create view vw_sc_for_follow_and_cont_sign as
SELECT c.id, coalesce(max(le.is_following),0) as is_following, coalesce(max(le.is_continious),0) as is_continious
FROM call_event c left join linked_event le on c.id = le.id group by c.id;



create view vw_sc_for_linked_sign as
select c.id, case when (l0.id is not null or l1.id_call is not null) then 1::numeric else 0::numeric end is_linked_event
from call_event c
    left join linked_event l0 on l0.id = c.id
    left join linked_event l1 on l1.id_call = c.id;


create view vw_sc_help_list_usl as
select ID_CALL as id,  string_agg(('(' || aes.CODE || ') ' || case when aes.CAPTION2 is null then aes.CAPTION else aes.CAPTION2 end), ', ' ORDER BY aes.id) AS help
    from arm03_call_easy_service ahc LEFT JOIN ARM03_EASY_SERVICE aes
      ON ahc.ID_EASY_SERVICE = aes.ID group by ID_CALL;


create or replace view vw_sc_repair_id_pult as
select id, coalesce(id_pult, 0) as id_pult from call_event;


create or replace view vw_sc_staff_list as
select rc.id_call, string_agg(st.fio, ', ') as staffs from ref_call_staff rc left join staff_tbl st on rc.id_staff = st.id left join appointment a on rc.id_appoint = a.id
where a.caption not like '%Водитель%'
group by rc.id_call;

CREATE EXTENSION cube;
CREATE EXTENSION earthdistance;

create or replace view vw_sc_main_call as
SELECT le.id, min(le.id_call) as id_call
           FROM linked_event le group by le.id;



create or replace view vw_sc_hospital_adress as
select max(h.ID) id_hospital, fapr.id id_full_adress from ref_object_adresses roa left join full_adress fapr on fapr.ID_BASE_ADRESS = roa.ID_BASE_ADRESS left join HOSPITAL h on h.ID_OBJECT = roa.ID_OBJECT
where roa.id_base_adress is not null and roa.id_object is not null and h.id is not null
group by fapr.id;

create or replace view vw_sc_disp_send as
SELECT distinct ca.ID_CALL, u.ID as user_id FROM CALL_ACTION ca
        LEFT JOIN STANDART_PHRASES sp ON ca.ID_ACTION = sp.ID
        LEFT JOIN USERS u ON ca.ID_OPER = u.ID
        WHERE LOWER(sp.CAPTION) LIKE 'передано%';


create or replace view vw_sc_repair_own_pult as
select call_event.id, coalesce(pult.id, 0) as id_own_pult from call_event left join pult on call_event.own_pult = pult.cascade_id;

create or replace view vw_sc_mob_device_use as
select ce.id, coalesce((select distinct 1 from arm03_110u_history ah where ah.id_call=ce.id and ah.is_from_mob_device=1), 0) is_mob_device_use from call_event ce;

create or replace view vw_sc_get_call as
select id_call id, dtime from call_action where id_action = (select id from standart_phrases where caption = 'Приём вызова');