select ce.TIME_REG                                                                                     as время_регистрации,
       ce.id                                                                                           as idcall,
       lpu_act.caption                                                                                 as активный_вызов_в_лпу,
       ref_call_event_sound.AON                                                                        as аон,
       patient.birthday                                                                                as дата_рождения,
       ce.informer                                                                                     as заявитель,
       patient.work_Place                                                                              as место_работы,
       icd10_primary.caption                                                                           as расшифровка_од,
       vw_sc_staff_list.staffs                                                                         as простой_список_состава,
       ce.phone_from                                                                                   as телефон_заявителя,
       lpu_act.caption                                                                                 as активный_вызов_в_лпу,
       icd10_primary.code                                                                              as код_од,
       apa.diagnosis                                                                                   as основной_диагноз_по_карте_од,
       apa.hospital_comment                                                                            as комментарий_для_поликлиники,
       isdB.saturation                                                                                 as сатурация_до,
       isdB.temperature                                                                                as температура_до,
       isdB.respiratory_rate                                                                           as чд_до,
       apa.is_not_hospitalized                                                                         as отказ_от_госпитализации,
       ce.adress                                                                                       as адрес_выз,
       ce.flat                                                                                         as квартира_выз,
       ce.call_numb                                                                                    as номер_вызова,
       concat_ws(' ', arm03_call.PATIENT, arm03_call.PATIENT_FIRSTNAME, arm03_call.PATIENT_MIDDLENAME) as фио_пациента,
       ce.is_repeated                                                                                  as признак_повтора,
       CASE
         WHEN arm03_call.YEARS > 0 THEN concat(arm03_call.YEARS, ' л.')
         WHEN arm03_call.MONTHS > 0 THEN concat(arm03_call.MONTHS, ' м.')
         WHEN arm03_call.DAYS > 0 THEN concat(arm03_call.DAYS, ' д.')
         ELSE NULL END                                                                                 as возраст,
       apa.diagnosis                                                                                   as од_по_карте,
       hospital.caption                                                                                as лпу_ктс,
       a03_depa_result.caption                                                                         as результат_вызова,
       apa.op_division_senior_doctor                                                                   as страший_оперотдела,
       pult_take_call.caption                                                                          as подразделение,
       ct_brigade_cn.caption                                                                           as позывной_бр,
       lpu_act.caption                                                                                 as активный_в_лпу,
       CASE
         WHEN patient.sex = 1 THEN 'М'
         WHEN patient.sex = 2 THEN 'Ж'
         WHEN patient.sex = 0 THEN 'Не определен'
         ELSE NULL END                                                                                 as пол,
       vw_sc_staff_list.staffs                                                                         as список_состава,

       string_agg(distinct to_char(rcs_staff.id, '9999'), ',' order by to_char(rcs_staff.id, '9999'))  as id_сотрудника,

       concat_ws(' ', arm03_call.PATIENT, arm03_call.PATIENT_FIRSTNAME,
                 arm03_call.PATIENT_MIDDLENAME, to_char(patient.birthday, 'DD-MM-YYYY'))               as string_key,

       CASE
         WHEN to_timestamp('$params.get("Дата начала")', 'DD.MM.YYYY HH24:MI:SS') > ce.TIME_REG THEN '1' --!!
       --!! WHEN TIMESTAMP '2021-08-19 00:00:00' > ce.TIME_REG THEN '1' --!!
         ELSE NULL END                                                                                 as вчера

from CALL_EVENT ce
       LEFT JOIN REF_CALL_EVENT_SOUND ref_call_event_sound on ce.id = ref_call_event_sound.ID_CALL_EVENT
       LEFT JOIN ARM03_PATIENT_ASSISTANCE apa on ce.ID = apa.ID
       LEFT JOIN ARM03_PATIENT_OBJECTIVE_DATA apod on apa.id = apod.id
       LEFT JOIN ARM03_PATIENT_INSTR_STUDY_DATA isdB on apod.id_instr_data_before = isdB.id
       LEFT JOIN ARM03_ICD_10 icd10_primary on apa.id_primary_icd10 = icd10_primary.id
       LEFT JOIN VW_SC_CALL_TECH_BRIGADE ct_b
                 on ce.ID = ct_b.ID_CALL AND (ct_b.TECH_DELETED is null OR ct_b.TECH_DELETED = 0)
       LEFT JOIN REF_CALL_STAFF ref_call_staff on ce.id = ref_call_staff.id_call
       LEFT JOIN VW_SC_REPAIR_ID_PULT vw_sc_repair_id_pult on ce.ID = vw_sc_repair_id_pult.ID
       LEFT JOIN VW_SC_STAFF_LIST vw_sc_staff_list on ce.id = vw_sc_staff_list.id_call
       LEFT JOIN TECHNIKA ct_brigade on ct_b.ID_TECH = ct_brigade.ID
       LEFT JOIN STAFF_TBL rcs_staff on ref_call_staff.ID_STAFF = rcs_staff.id
       LEFT JOIN PULT pult_take_call on vw_sc_repair_id_pult.ID_PULT = pult_take_call.id
       LEFT JOIN ARM03_CALL arm03_call on apa.ID = arm03_call.ID_CALL
       LEFT JOIN HOSPITAL hospital on apa.id_hospital = hospital.id
       LEFT JOIN STAFF_TBL a03_stf_doctor on apa.ID_DOCTOR = a03_stf_doctor.id
       LEFT JOIN HOSPITAL lpu_act on apa.ID_ACT_CALL_HOSPITAL = lpu_act.id
       LEFT JOIN ARM03_DEPARTURE_RESULT a03_depa_result on apa.ID_DEPARTURE_RESULT = a03_depa_result.id
       LEFT JOIN CALL_NAME ct_brigade_cn
                 on ct_brigade.ID = ct_brigade_cn.ID_TBL AND ct_brigade_cn.TABLE_NAME = 'TECHNIKA'
       LEFT JOIN ARM03_PATIENT patient on arm03_call.id_patient = patient.id

where (
          ce.TIME_REG BETWEEN --!!
              to_timestamp('$params.get("Дата начала")', 'DD.MM.YYYY HH24:MI:SS') - interval '1' DAY AND --!!
              to_timestamp('$params.get("Дата окончания")', 'DD.MM.YYYY HH24:MI:SS') --!!

            --!! ce.TIME_REG BETWEEN TIMESTAMP '2021-08-19 00:00:00' - interval '1' DAY AND TIMESTAMP '2021-08-20 00:00:00' --!!

              # if($params.get("Подразделение") && !$params.get("Подразделение").isEmpty() )
          AND vw_sc_repair_id_pult.id_pult IN ($params.get("Подразделение"))
            #end

          AND patient.birthday IS NOT NULL
          AND NOT (rcs_staff.ID_APPOINTMENT IN (2, 3))
          AND concat_ws(' ', arm03_call.PATIENT, arm03_call.PATIENT_FIRSTNAME, arm03_call.PATIENT_MIDDLENAME,
                        to_char(patient.birthday, 'DD-MM-YYYY')) IN (select concat_ws(' ', arm03_call.PATIENT,
                                                                                      arm03_call.PATIENT_FIRSTNAME,
                                                                                      arm03_call.PATIENT_MIDDLENAME,
                                                                                      to_char(patient.birthday, 'DD-MM-YYYY'))

                                                                     from CALL_EVENT ce
                                                                            LEFT JOIN ARM03_PATIENT_ASSISTANCE apa on ce.ID = apa.ID
                                                                            LEFT JOIN ARM03_CALL arm03_call on apa.ID = arm03_call.ID_CALL
                                                                            LEFT JOIN ARM03_PATIENT patient on arm03_call.id_patient = patient.id

                                                                     where (
                                                                        ce.TIME_REG BETWEEN  --!!
                                                                        to_timestamp('$params.get("Дата начала")', 'DD.MM.YYYY HH24:MI:SS') AND  --!!
                                                                        to_timestamp('$params.get("Дата окончания")', 'DD.MM.YYYY HH24:MI:SS')  --!!

                                                                       --!! ce.TIME_REG BETWEEN TIMESTAMP '2021-08-19 00:00:00' AND TIMESTAMP '2021-08-20 00:00:00' --!!

                                                                             )
              )
        )

GROUP BY время_регистрации, idcall, активный_вызов_в_лпу, аон, дата_рождения, заявитель, место_работы, расшифровка_од,
         простой_список_состава, телефон_заявителя, активный_вызов_в_лпу, код_од, основной_диагноз_по_карте_од,
         комментарий_для_поликлиники, сатурация_до, температура_до, чд_до, отказ_от_госпитализации, адрес_выз,
         квартира_выз, номер_вызова, фио_пациента, признак_повтора, возраст, од_по_карте, лпу_ктс, результат_вызова,
         страший_оперотдела, подразделение, позывной_бр, активный_в_лпу, пол, список_состава, string_key, вчера
