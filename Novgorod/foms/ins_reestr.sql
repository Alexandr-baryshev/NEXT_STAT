 SELECT
              AC.ID_CALL                                  NUSL,
              NULL                                        ID_PAC,
              AV.CODE                                     VPOLIS,
              AP.UNIFIED_POLICY_NUMBER                    NPOLIS,
              AP.SERIES_POLICY                            SPOLIS,
              AP.SNILS                                    SNILS,
              AP.LAST_NAME                                FAM,
              AP.FIRST_NAME                               IM,
              AP.MIDDLE_NAME                              OT,
              AP.SEX                                      W,
              AP.BIRTHDAY                                 DR,
              DT.CODE                                     doctype,
              AP.PASSPORT_SERIES                          docser,
              AP.PASSPORT_NUMBER                          docnum,
              PARENT_AP.LAST_NAME                         fam_p,
              PARENT_AP.FIRST_NAME                        im_p,
              PARENT_AP.MIDDLE_NAME                       ot_p,
              PARENT_AP.SEX                               w_p,
              PARENT_AP.BIRTHDAY                          dr_p,
              AIC.OKATO_OMS                               st_okato,
              AIC.CODE                                    smo,
              AP.id_insurance_company              id_insurance,
              MIN(CE.TIME_REG)                            date_1,
              MIN(CT.RETURN_TIME)                         date_2,
              CE.ID                                       idcall
            FROM ARM03_CALL AC
                INNER JOIN CALL_EVENT CE ON AC.ID_CALL = CE.ID
                INNER JOIN ARM03_PATIENT AP ON AC.ID_PATIENT = AP.ID
                LEFT JOIN ARM03_VPOLIS AV ON AP.ID_VPOLIS = AV.ID
                LEFT JOIN ARM03_INSURANCE_COMPANY AIC ON AP.ID_INSURANCE_COMPANY = AIC.ID
                LEFT JOIN ARM03_PATIENT PARENT_AP ON AP.ID_PARENT = PARENT_AP.ID
                LEFT JOIN CALL_TECH CT ON CE.ID = CT.ID_CALL
                LEFT JOIN DOCUMENT_TYPE DT ON AP.ID_DOCUMENT_TYPE = DT.ID
                LEFT JOIN DOCUMENT_TYPE PARENT_DT ON PARENT_AP.ID_DOCUMENT_TYPE = PARENT_DT.ID
                LEFT JOIN ARM03_PATIENT_ASSISTANCE APA ON AC.ID_CALL = APA.ID
                LEFT JOIN ARM03_IST_FIN AIF ON APA.ID_IST_FIN = AIF.ID
                LEFT JOIN ARM03_ICD_10 A03ICD ON A03ICD.ID = APA.ID_EXTRA_DIAGNOSIS_ICD10
            WHERE
              CT.RETREAT_TIME IS NULL
              AND (AP.unified_policy_number is not null AND NOT (AP.unified_policy_number = ''))
              AND (CT.TECH_DELETED = 0 OR CT.TECH_DELETED IS NULL)

              AND AC.FOMS_FILL = 1

              AND AC.IS_EXPORTED_TO_FOMS <> 1
              AND (CE.WRONG_CALL IS NULL OR CE.WRONG_CALL = 0)

          AND ce.TIME_REG BETWEEN TIMESTAMP '2023-01-11 00:00:00'
           AND TIMESTAMP '2023-01-12 00:00:00'

            GROUP BY
                AV.CODE, AP.UNIFIED_POLICY_NUMBER, AIC.OKATO_OMS, AIC.CODE, CE.ID,
                AP.BIRTHDAY, AP.SEX, DT.CODE, PARENT_AP.LAST_NAME, PARENT_AP.FIRST_NAME,
                PARENT_AP.MIDDLE_NAME, AP.LAST_NAME, AP.FIRST_NAME, AP.MIDDLE_NAME, PARENT_AP.SEX, PARENT_AP.BIRTHDAY,
                AP.PASSPORT_SERIES, AP.PASSPORT_NUMBER, AP.SERIES_POLICY, AP.SNILS, AC.ID_CALL, AP.id_insurance_company
            ORDER BY AC.ID_CALL