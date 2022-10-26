select ce.id                                                                                           as id_ce_ID,
       ce.TIME_REG                                                                                     as id_ce_TIME_REG,
       ce.call_numb                                                                                    as id_ce_CALL_NUMB,
       ce.REG_NO                                                                                       as id_ce_REG_NO,
       concat_ws(' ', arm03_call.PATIENT, arm03_call.PATIENT_FIRSTNAME, arm03_call.PATIENT_MIDDLENAME) as card03_p,
       ct_brigade_cn.caption                                                                           as e_ct_b_name,
       pult_take_call.caption                                                                          as pult_take_call_d
from CALL_EVENT ce
       LEFT JOIN VW_SC_CALL_TECH_BRIGADE ct_b
                 on ce.ID = ct_b.ID_CALL AND (ct_b.TECH_DELETED is null OR ct_b.TECH_DELETED = 0)
       LEFT JOIN VW_SC_REPAIR_ID_PULT vw_sc_repair_id_pult on ce.ID = vw_sc_repair_id_pult.ID
       LEFT JOIN ARM03_PATIENT_ASSISTANCE apa on ce.ID = apa.ID
       LEFT JOIN TECHNIKA ct_brigade on ct_b.ID_TECH = ct_brigade.ID
       LEFT JOIN PULT pult_take_call on vw_sc_repair_id_pult.ID_PULT = pult_take_call.id
       LEFT JOIN ARM03_CALL arm03_call on apa.ID = arm03_call.ID_CALL
       LEFT JOIN CALL_NAME ct_brigade_cn
                 on ct_brigade.ID = ct_brigade_cn.ID_TBL AND ct_brigade_cn.TABLE_NAME = 'TECHNIKA'

where (
          ce.TIME_REG BETWEEN TIMESTAMP '2022-10-03 00:00:00' AND TIMESTAMP '2022-10-04 00:00:00'
          AND ce.call_numb = 66142.0
          AND vw_sc_repair_id_pult.id_pult IN (0, 577)
        )