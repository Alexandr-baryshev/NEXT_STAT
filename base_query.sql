select --
       ce.id                  as id_call,
       ce.REG_NO              as рег_номер,
       ce.call_numb           as номер_вызова,
       ce.TIME_REG            as вр_регистрации,
       pult_take_call.caption as район_выезда

from CALL_EVENT ce
         LEFT JOIN VW_SC_REPAIR_ID_PULT vw_sc_repair_id_pult on ce.ID = vw_sc_repair_id_pult.ID
         LEFT JOIN PULT pult_take_call on vw_sc_repair_id_pult.ID_PULT = pult_take_call.id

where (
              ce.TIME_REG BETWEEN TIMESTAMP '2023-07-01 00:00:00' AND TIMESTAMP '2023-07-02 00:00:00'
              AND (ce.call_numb > 0.0)
          )


