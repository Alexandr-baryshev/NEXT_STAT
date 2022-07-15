select
  ce.id as id_ce_ID,
  ce.call_numb as id_ce_CALL_NUMB,
  ce.REG_NO as id_ce_REG_NO,
  ce.TIME_REG as id_ce_TIME_REG,
  patient.passport_number as card03_pat_document_num
from
  CALL_EVENT ce
  LEFT JOIN SRC_EVENT_TYPE src_et on ce.id_src_type = src_et.id
  LEFT JOIN ARM03_PATIENT_ASSISTANCE apa on ce.ID = apa.ID
  LEFT JOIN ARM03_CALL arm03_call on apa.ID = arm03_call.ID_CALL
  LEFT JOIN ARM03_PATIENT patient on arm03_call.id_patient = patient.id
where
  (
    ce.TIME_REG BETWEEN TIMESTAMP '2022-01-01 00:00:00'
    AND TIMESTAMP '2022-04-05 00:00:00'
    AND (
      (
        ce.id_src_type is null
        OR NOT(ce.id_src_type IN (8, 9))
      )
      AND ce.call_numb > 0.0
    )
  ) ;