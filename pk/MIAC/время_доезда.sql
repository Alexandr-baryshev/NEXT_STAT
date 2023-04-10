/*miac2*/

select
      'Владивосток'              as город,
       pult_take_call.caption    as район_выезда,
       ce.id                     as id_03,
       ct_brigade_cn.caption     as позывной_бр,
       ce.REG_NO                 as рег_номер,
       ct_b.receive_time         as вр_получения_команды,
       ct_b.send_time            as вр_отправки,
       ct_b.at_place_time        as вр_прибытия,
       a03_category_call.caption as категория_вызова,
       ce.TIME_REG               as вр_регистрации,
       rank.caption              as повод,

       ct_technika_pult.caption  as владелец_техники,
       ct_brigade_pult.caption   as владелец_бригады

from CALL_EVENT ce
       LEFT JOIN VW_SC_CALL_TECH_BRIGADE ct_b
                 on ce.ID = ct_b.ID_CALL AND (ct_b.TECH_DELETED is null OR ct_b.TECH_DELETED = 0)
       LEFT JOIN VW_SC_REPAIR_ID_PULT vw_sc_repair_id_pult on ce.ID = vw_sc_repair_id_pult.ID
       LEFT JOIN TECHNIKA ct_brigade on ct_b.ID_TECH = ct_brigade.ID
       LEFT JOIN PULT pult_take_call on vw_sc_repair_id_pult.ID_PULT = pult_take_call.id
       LEFT JOIN CALL_NAME ct_brigade_cn
                 on ct_brigade.ID = ct_brigade_cn.ID_TBL AND ct_brigade_cn.TABLE_NAME = 'TECHNIKA'
       LEFT JOIN ARM03_PATIENT_ASSISTANCE apa on ce.ID = apa.ID
       LEFT JOIN ARM03_CALL arm03_call on apa.ID = arm03_call.ID_CALL
       LEFT JOIN ARM03_CATEGORY_CALL a03_category_call on arm03_call.ID_CATEG_CALL = a03_category_call.id
       LEFT JOIN RANK rank on ce.ID_RANK = rank.id

       LEFT JOIN PULT ct_brigade_pult on ct_brigade.ID_PULT = ct_brigade_pult.ID
       LEFT JOIN PULT ct_technika_pult on ct_brigade.ID_PULT = ct_technika_pult.ID

where (ce.TIME_REG BETWEEN  '2023-03-14 00:00:00' and '2023-03-15 00:00:00' AND
      (NOT (ce.id_rank IN (5456, 5188, 1670)) AND ce.call_numb > 0.0));