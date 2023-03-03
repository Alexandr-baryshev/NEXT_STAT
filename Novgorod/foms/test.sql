select ce.id         as idcall,
       concat_ws(
           ' ',
           arm03_call.PATIENT,
           arm03_call.PATIENT_FIRSTNAME,
           arm03_call.PATIENT_MIDDLENAME
         )           as card03_p,
       ce.TIME_REG   as TIME_REG,

       AIC.code      as smo,
       AIC.okato_oms as st_okato,
       ce.call_numb  as CALL_NUMB,
       ce.REG_NO     as REG_NO,

       patient.id_insurance_company,
       patient.passport_series
from CALL_EVENT ce
       LEFT JOIN VW_SC_REPAIR_ID_PULT vw_sc_repair_id_pult on ce.ID = vw_sc_repair_id_pult.ID
       LEFT JOIN ARM03_PATIENT_ASSISTANCE apa on ce.ID = apa.ID
       LEFT JOIN PULT pult_take_call on vw_sc_repair_id_pult.ID_PULT = pult_take_call.id
       LEFT JOIN ARM03_CALL arm03_call on apa.ID = arm03_call.ID_CALL
       LEFT JOIN ARM03_PATIENT patient on arm03_call.id_patient = patient.id
       LEFT JOIN ARM03_INSURANCE_COMPANY AIC on patient.ID_INSURANCE_COMPANY = AIC.id
where (
          ce.TIME_REG BETWEEN TIMESTAMP '2023-02-01 00:00:00'
            AND TIMESTAMP '2023-02-02 00:00:00'
          AND vw_sc_repair_id_pult.id_pult IN (0, 380)
          AND ce.id = 2065325
          AND (
            NOT (
                concat_ws(
                    ' ',
                    arm03_call.PATIENT,
                    arm03_call.PATIENT_FIRSTNAME,
                    arm03_call.PATIENT_MIDDLENAME
                  ) = ''
              )
            )
        )
