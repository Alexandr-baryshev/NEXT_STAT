select
       'Владивосток'                     as город,
       ce.id                             as idcall,
       ce.REG_NO                         as регистрационный_номер,
       ce.call_numb                      as номер_вызова,
       ce.TIME_REG                       as время_регистрации,
       remd_info_short.document_version  as версия_сэмд,
       remd_info_short.semd_ts           as время_создания_сэмд,
       remd_info_short.semd_id           as уникальный_идентификатор_сэмд,
       remd_info_short.remd_ts           as время_создания_рэмд,
       remd_info_short.remd_id           as уникальный_идентификатор_рэмд,
       remd_info_short.remd_status_short as статус_выгрузки_в_рэмд,
       pult_take_call.caption            as район_выезда

from CALL_EVENT ce
       LEFT JOIN VW_SC_REPAIR_ID_PULT vw_sc_repair_id_pult on ce.ID = vw_sc_repair_id_pult.ID
       LEFT JOIN DWORKER.REMD_INFO_SHORT remd_info_short on ce.id = remd_info_short.id_call
       LEFT JOIN PULT pult_take_call on vw_sc_repair_id_pult.ID_PULT = pult_take_call.id
where (
          ce.TIME_REG BETWEEN TIMESTAMP '2023-01-01 00:00:00' AND TIMESTAMP '2023-01-17 00:00:00'

         -- AND ce.TIME_REG BETWEEN to_timestamp('$date1', 'DD.MM.YYYY HH24:MI:SS')
         -- AND to_timestamp('$date2', 'DD.MM.YYYY HH24:MI:SS')

          AND (ce.call_numb > 0.0)
        )