-- Обращения в СМП
with pv as (select id
            from standart_phrases
            where caption = 'Приём вызова'),

     base as (select rces.id,
                     rces.missing,
                     rces.dt_start,
                     ca.dtime,
                     rces.dt_stop,
                     ca.id as                                                        reg_id,
                     greatest(rces.dt_stop - ca.dtime, -(rces.dt_stop - ca.dtime))   raz,
                     greatest(ca.dtime - rces.dt_start, -(ca.dtime - rces.dt_start)) wait,
                     pult_take_call.caption                                          район_выезда
              from ref_call_event_sound rces
                       left join call_event ce on rces.id_call_event = ce.id
                       left join call_action ca on ce.id = ca.id_call and ca.id_action in (select id from pv)

                       LEFT JOIN VW_SC_REPAIR_ID_PULT vw_sc_repair_id_pult on ce.ID = vw_sc_repair_id_pult.ID
                       LEFT JOIN PULT pult_take_call on vw_sc_repair_id_pult.ID_PULT = pult_take_call.id


              where dt_start BETWEEN TIMESTAMP '2023-07-01 00:00:00' AND TIMESTAMP '2023-07-01 00:20:00'

                --  dt_start between to_timestamp('$date1', 'DD.MM.YYYY HH24:MI:SS')::timestamp without time zone
                --      and to_timestamp('$date2', 'DD.MM.YYYY HH24:MI:SS')::timestamp without time zone

                and is_out = 0)

select '#_#'                                                                           city,
       count(distinct id)::bigint                                                      all_call,
       count(distinct case when missing = 1 then id end)::bigint                       all_miss,
       EXTRACT(EPOCH from avg(distinct case when missing = 0 then raz end))::bigint    avg_raz,
       EXTRACT(EPOCH from max(distinct case when missing = 0 then wait end))::bigint   max_wait,
       EXTRACT(EPOCH from avg(distinct case when missing = 0 then wait end))::bigint   avg_wait,
       count(distinct case when wait > '3 MINUTE' and missing = 0 then id end)::bigint avg_m_3,
       count(distinct reg_id)::bigint                                                  all_reg,
       count(distinct case when missing = 0 and reg_id is null then id end)            all_outher,
       район_выезда

from base
group by район_выезда