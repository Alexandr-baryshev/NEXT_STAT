-- Общий отчет по операциям

select
       '#_#'                                                                                           as город,
       ce.id                                                                                           as идентификатор_происшествия,
       ce.REG_NO                                                                                       as регистрационный_номер,
       ce.call_numb                                                                                    as номер_вызова,
       ce.TIME_REG                                                                                     as время_регистрации,
       concat_ws(' ', arm03_call.PATIENT, arm03_call.PATIENT_FIRSTNAME, arm03_call.PATIENT_MIDDLENAME) as фио_пациента,
       CASE
           WHEN patient.sex = 1 THEN 'Ìóæñêîé'
           WHEN patient.sex = 2 THEN 'Æåíñêèé'
           WHEN patient.sex = 0 THEN 'Íå îïðåäåëåí'
           ELSE NULL END                                                                               as пол_пациента,
       arm03_call.YEARS                                                                                as лет,
       arm03_call.MONTHS                                                                               as месяцев,
       arm03_call.DAYS                                                                                 as дней,
       hospital.caption                                                                                as лпу_по_ктс,
       hospital_dt.caption                                                                             as лпу_по_ктс_dt,
       icd10_primary.caption                                                                           as основной_диагноз,
       icd10_acc.caption                                                                               as сопутствующий_диагноз,
       rank.caption                                                                                    as тип_происшествия,
       a03_cmc_accepting_hospital.caption                                                              as лпу_место_предоставлено_наименование,
       a03_cmc_accepting_hospital_type.caption                                                         as лпу_место_предоставлено_тип,
       a03_cmc_evacuation_type.caption                                                                 as тип_эвакуации_наименование,
       ce.is_repeated                                                                                  as признак_повторного_вызова,
       user_ce_reg.caption                                                                             as имя_диспетчера_зарегистрировший_вызов,
       ct_technika_cn.caption                                                                          as позывной_тех
    -- medical_profile.caption                                                                         as профиль_мед_помощи_наименование
from CALL_EVENT ce
         LEFT JOIN ARM03_PATIENT_ASSISTANCE apa on ce.ID = apa.ID
         LEFT JOIN VW_SC_CALL_TECH_TECHNIKA ct
                   on ce.ID = ct.ID_CALL AND (ct.TECH_DELETED is null OR ct.TECH_DELETED = 0)
         LEFT JOIN RANK rank on ce.ID_RANK = rank.id
         LEFT JOIN USERS user_ce_reg on ce.oper_reg = user_ce_reg.id
         LEFT JOIN ARM03_CMC_ACCIDENT a03_cmc_accident on ce.id = a03_cmc_accident.id_call
         LEFT JOIN ARM03_CALL arm03_call on apa.ID = arm03_call.ID_CALL
         LEFT JOIN HOSPITAL hospital on apa.id_hospital = hospital.id
         LEFT JOIN ARM03_ICD_10 icd10_primary on apa.id_primary_icd10 = icd10_primary.id
         LEFT JOIN ARM03_ICD_10 icd10_acc on apa.ID_ACCOMPANYING_ICD10 = icd10_acc.id
         LEFT JOIN TECHNIKA ct_technika on ct.ID_TECH = ct_technika.ID
         LEFT JOIN arm03_cmc_evacuation_type a03_cmc_evacuation_type
                   on a03_cmc_accident.id_evacuation_type = a03_cmc_evacuation_type.id
      --   LEFT JOIN MEDICAL_PROFILE medical_profile on a03_cmc_accident.id_medical_profile = medical_profile.id
         LEFT JOIN HOSPITAL a03_cmc_accepting_hospital
                   on a03_cmc_accident.id_accepting_hospital = a03_cmc_accepting_hospital.id
         LEFT JOIN HOSPITAL hospital_dt on arm03_call.id_hospital = hospital_dt.id
         LEFT JOIN ARM03_PATIENT patient on arm03_call.id_patient = patient.id
         LEFT JOIN CALL_NAME ct_technika_cn
                   on ct_technika.ID = ct_technika_cn.ID_TBL AND ct_technika_cn.TABLE_NAME = 'TECHNIKA'
         LEFT JOIN HOSPITAL_TYPE a03_cmc_accepting_hospital_type
                   on a03_cmc_accepting_hospital.id_hospital_type = a03_cmc_accepting_hospital_type.id



where (
          -- Дада для запроса в DataGrip
           ce.TIME_REG BETWEEN TIMESTAMP '2023-07-01 00:00:00' AND TIMESTAMP '2023-07-02 00:00:00'

          -- Дада для запроса в rest_query
          --   ce.TIME_REG
          --       BETWEEN to_timestamp('$date1', 'DD.MM.YYYY HH24:MI:SS')
          --       AND to_timestamp('$date2', 'DD.MM.YYYY HH24:MI:SS')

              -- Фиксированые условия
              AND (ce.call_numb > 0.0)
          )