select lpu_act.caption                                                                                 as c03_lpu_act_capt,
       ref_call_event_sound.AON                                                                        as id_ce_lAON,
       ce.TIME_REG                                                                                     as id_ce_TIME_REG,
       patient.birthday                                                                                as c03_pat_birthday,
       ce.informer                                                                                     as id_ce_INFORMER,
       ce.id                                                                                           as id_ce_ID,
       patient.work_Place                                                                              as c03_pat_work_place,
       ce.call_numb                                                                                    as id_ce_CALL_NUMB,
       icd10_primary.caption                                                                           as card03_icd10_primary_cap,
       vw_sc_staff_list.staffs                                                                         as c03_staff_fio_list,
       ce.phone_from                                                                                   as id_ce_PHONE_FROM,
       concat_ws(' ', arm03_call.PATIENT, arm03_call.PATIENT_FIRSTNAME, arm03_call.PATIENT_MIDDLENAME) as card03_p,
       lpu_act.caption                                                                                 as c03_lpu_act,
       icd10_primary.code                                                                              as card03_icd10_primary_cod,
       apa.diagnosis                                                                                   as card03_icd10_primary_text,
       apa.hospital_comment                                                                            as apa_hospital_comment,
       isdB.saturation                                                                                 as c03_isdB_satur,
       isdB.temperature                                                                                as c03_isdB_temp,
       isdB.respiratory_rate                                                                           as c03_isdB_chd,
       pult_take_call.caption                                                                          as pult_take_call_d,
       CASE
         WHEN arm03_call.YEARS > 0 THEN concat(arm03_call.YEARS, ' ë.')
         WHEN arm03_call.MONTHS > 0 THEN concat(arm03_call.MONTHS, ' ì.')
         WHEN arm03_call.DAYS > 0 THEN concat(arm03_call.DAYS, ' ä.')
         ELSE NULL END                                                                                 as card03_age_p,
       apa.is_not_hospitalized                                                                         as c03_is_not_hospitalized,
       ce.adress                                                                                       as id_addr_ADRESS,
       ce.flat                                                                                         as id_addr_FLAT
from CALL_EVENT ce

       LEFT JOIN SRC_EVENT_TYPE src_et on ce.id_src_type = src_et.id
       LEFT JOIN VW_SC_REPAIR_ID_PULT vw_sc_repair_id_pult on ce.ID = vw_sc_repair_id_pult.ID
       LEFT JOIN VW_SC_STAFF_LIST vw_sc_staff_list on ce.id = vw_sc_staff_list.id_call
       LEFT JOIN ARM03_PATIENT_ASSISTANCE apa on ce.ID = apa.ID
       LEFT JOIN PULT pult_take_call on vw_sc_repair_id_pult.ID_PULT = pult_take_call.id
       LEFT JOIN ARM03_CALL arm03_call on apa.ID = arm03_call.ID_CALL
       LEFT JOIN ARM03_ICD_10 icd10_primary on apa.id_primary_icd10 = icd10_primary.id
       LEFT JOIN HOSPITAL lpu_act on apa.ID_ACT_CALL_HOSPITAL = lpu_act.id
       LEFT JOIN ARM03_PATIENT_OBJECTIVE_DATA apod on apa.id = apod.id
       LEFT JOIN ARM03_PATIENT patient on arm03_call.id_patient = patient.id
       LEFT JOIN ARM03_PATIENT_INSTR_STUDY_DATA isdB on apod.id_instr_data_before = isdB.id
       LEFT JOIN REF_CALL_EVENT_SOUND ref_call_event_sound on ce.id = ref_call_event_sound.ID_CALL_EVENT

where (
  ce.TIME_REG BETWEEN TIMESTAMP '2022-02-01 00:00:00' AND TIMESTAMP '2022-02-25 00:00:00' AND
       ((ce.id_src_type is null OR NOT (ce.id_src_type IN (8, 9))) AND (ce.WRONG_CALL is null OR ce.WRONG_CALL = 0) AND
        (arm03_call.YEARS >= 18) AND
        (apa.ID_ACT_CALL_HOSPITAL IN (216, 126, 212, 95, 115, 119, 118, 116, 114, 5, 3, 4, 2)))
  )