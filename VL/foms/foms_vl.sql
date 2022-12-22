
            SELECT
              CE.REG_NO,
              substring(CE.ID::varchar, 1, 8) NUSL,
              NULL                                        ID_PAC,
              AV.CODE                                     VPOLIS,
              AP.UNIFIED_POLICY_NUMBER                    NPOLIS,
              AP.SERIES_POLICY                            SPOLIS,
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
              ADR.CODE                                    adr_code,
              ADR.CAPTION                                 adr_cap,
              APD.CAPTION                                 apd_cap,
              ADC.CAPTION                                 adc_cap,
              ACDO.CAPTION                                acdo_cap,
              ACC.CAPTION                                 acc_cap,
              ACR.CAPTION                                 acr_cap,
              APD.IS_LPU                                  delivery_is_lpu,
              ACP.CODE                                    kateg,
              APA.IS_PERFORM_CPR                          cpr,
              AV12.CODE                                   ishod,
              ACM.CODE                                    char_main,
              ART.CODE                                    result_tre,
              AIC.OKATO_OMS                               st_okato,
              AIC.CODE                                    smo,
              MIN(CE.TIME_REG)                            timereg,
              ACPF.CODE                                   place,
              AC.ACCOMPANYING_SHEET                       nsndshop,
              APA.IS_NOT_HOSPITALIZED                     nhosp,
              AC.YEARS                                    age,
              ACC.CODE                                    for_pom,
              ST.CODE                                     docfic,
              ASFFOMS.CODE                                prvs,
              AIP1.CODE                                   ds1,
              AIP2.CODE                                   ds2,
              AIP3.CODE                                   ds3,
              ASTFOMS.CODE                                specfic,
              ASTFOMS.IS_CHILD_PROFIL                     is_child_profil,
              REPLACE(REPLACE(ST.PENSION_NUMBER, '-', ''), ' ', '') iddokt,
              (
                SELECT string_agg(ASC1.CODE,'|') code
                FROM ARM03_CALL_SPECIAL_CASES ACSC
                  LEFT JOIN ARM03_SPECIAL_CASES ASC1 ON ACSC.ID_SPECIAL_CASE = ASC1.ID
                WHERE ACSC.ID_CALL = CE.ID ORDER BY code
              )                                           d_type,
              (
                SELECT ASC1.CODE
                FROM ARM03_CALL_SPECIAL_CASES ACSC
                  LEFT JOIN ARM03_SPECIAL_CASES ASC1 ON ACSC.ID_SPECIAL_CASE = ASC1.ID
                WHERE ACSC.ID_CALL = CE.ID LIMIT 1
              )                                           os_sluch,
              APA.IS_NOT_HOSPITALIZED                     type_hosp,
              MIN(CE.TIME_REG)                            date_1,
              MIN(ct_b.RETURN_TIME)                         date_2,
              MIN(CE.TIME_REG)                            inc_time,
              (
                CASE WHEN MIN(ct_b.RECEIVE_TIME) IS NULL THEN
                  MIN(CE.TIME_REG)
                ELSE
                  MIN(ct_b.RECEIVE_TIME)
                END
              )                                           br_time,
              (
                CASE WHEN MIN(ct_b.AT_PLACE_TIME) IS NULL THEN
                  MIN(CE.TIME_REG)
                ELSE
                  MIN(ct_b.AT_PLACE_TIME)
                END
              )                                           arr_time,
              (
                CASE WHEN MIN(ct_b.RETURN_TIME) IS NULL THEN
                  MIN(CE.TIME_REG)
                ELSE
                  MIN(ct_b.RETURN_TIME)
                END
              )                                           end_time,
              (
                CASE WHEN APA.IS_NOT_HOSPITALIZED = 0
                THEN 2 ELSE 1 END
              )                                           extr,
              (
                CASE WHEN AC.YEARS < 18
                THEN 1 ELSE 0 END
              )                                           det,
              AIF.CODE                                    ist_fin,
              (
                CASE WHEN ACPF.CODE IS NULL
                THEN '0' ELSE ACPF.CODE END
              )                                           place,
              (
                CASE WHEN AC.CALL_MILEAGE_KM IS NULL
                THEN 0 ELSE AC.CALL_MILEAGE_KM END
              )                                           zona,
              4                                           usl_ok,
              2                                           vidpom,
              0                                           det,
             ASTFOMS.id_spec_profil                       profil,
              1                                           purp,
              2                                           urgent,
              7                                           typ_preb,
              APA.IS_ALREADY_EXPORTED_TO_FOMS             pr_nov,
              36                                          idsp,
              0                                           sumv,
              0                                           visit_hs,
              0                                           visit_ds,
              1                                           type_pay,
              1                                           k_pr,
              1                                           idvizov,
              0                                           novor,
              0                                           visit_pol,
              0                                           visit_hom,
              CE.ID                                       idcall,
              AP.DOC_DATE_ISSUE                           docdate,
              pult_take_call.caption                      подразделение,
              AP.DOC_ORGANIZATION_ISSUE                   docorg
            FROM ARM03_CALL AC
            INNER JOIN CALL_EVENT CE ON AC.ID_CALL = CE.ID
            INNER JOIN ARM03_PATIENT AP ON AC.ID_PATIENT = AP.ID

            LEFT JOIN VW_SC_REPAIR_ID_PULT vw_sc_repair_id_pult on ce.ID = vw_sc_repair_id_pult.ID
            LEFT JOIN PULT pult_take_call on vw_sc_repair_id_pult.ID_PULT = pult_take_call.id

            LEFT JOIN ARM03_VPOLIS AV ON AP.ID_VPOLIS = AV.ID
            LEFT JOIN ARM03_INSURANCE_COMPANY AIC ON AP.ID_INSURANCE_COMPANY = AIC.ID
            LEFT JOIN ARM03_CATEGORY_CALL ACC ON AC.ID_CATEG_CALL_RESULT = ACC.ID
            LEFT JOIN ARM03_PATIENT PARENT_AP ON AP.ID_PARENT = PARENT_AP.ID
            LEFT JOIN ARM03_PATIENT_ASSISTANCE APA ON AC.ID_CALL = APA.ID
            LEFT JOIN ARM03_ASSISTANCE_RESULT AAR ON APA.ID_ASSISTANCE_RESULT = AAR.ID
            LEFT JOIN ARM03_RESULT_TRE ART ON AAR.ID_ARM03_RESULT_TRE = ART.ID
            LEFT JOIN ARM03_V012 AV12 ON AAR.ID_ARM03_V012 = AV12.ID

            LEFT JOIN CALL_TECH CT ON CE.ID = CT.ID_CALL

            LEFT JOIN VW_SC_CALL_TECH_BRIGADE ct_b
                 on ce.ID = ct_b.ID_CALL AND (ct_b.TECH_DELETED is null OR ct_b.TECH_DELETED = 0)

            LEFT JOIN STAFF_TBL ST ON APA.ID_DOCTOR = ST.ID
            LEFT JOIN ARM03_SPEC_TFOMS ASTFOMS ON ST.ID_SPEC_TFOMS = ASTFOMS.ID
            LEFT JOIN ARM03_SPEC_FFOMS ASFFOMS ON ASTFOMS.ID_SPEC_FFOMS = ASFFOMS.ID
            LEFT JOIN ARM03_DEPARTURE_RESULT ADR ON APA.ID_DEPARTURE_RESULT = ADR.ID
            LEFT JOIN ARM03_PLACE_DELIVERY APD ON APA.ID_PLACE_DELIVERY = APD.ID
            LEFT JOIN ARM03_DEPARTURE_CAUSE ADC ON APA.ID_RESULT_DEP_CAUSE = ADC.ID
            LEFT JOIN ARM03_CPR_DEAD_OCCURED ACDO ON APA.ID_DEATH_OCCURRED = ACDO.ID
            LEFT JOIN ARM03_CPR_RESULT ACR ON APA.ID_RESULT_CPR = ACR.ID
            LEFT JOIN DOCUMENT_TYPE DT ON AP.ID_DOCUMENT_TYPE = DT.ID
            LEFT JOIN DOCUMENT_TYPE PARENT_DT ON PARENT_AP.ID_DOCUMENT_TYPE = PARENT_DT.ID
            LEFT JOIN ARM03_CATEGORY_PATIENT ACP ON AP.ID_CATEGORY_PATIENT = ACP.ID
            LEFT JOIN ARM03_IST_FIN AIF ON APA.ID_IST_FIN = AIF.ID
            LEFT JOIN ARM03_RESULT_ILL ARI ON APA.ID_RESULT_ILL = ARI.ID
            LEFT JOIN ARM03_CHAR_MAIN ACM ON ADC.ID_ARM03_CHAR_MAIN = ACM.ID
            LEFT JOIN CALL_PLACE CP ON AC.ID_CALL_PLACE = CP.ID
            LEFT JOIN ARM03_CALL_PLACE_FOMS ACPF ON CP.FOMS = ACPF.ID
            LEFT JOIN ARM03_ICD_10 AIP1 ON APA.ID_PRIMARY_ICD10 = AIP1.ID
            LEFT JOIN ARM03_ICD_10 AIP2 ON APA.ID_ACCOMPANYING_ICD10 = AIP2.ID
            LEFT JOIN ARM03_ICD_10 AIP3 ON APA.ID_COMPLICATION_ICD10 = AIP3.ID
            LEFT JOIN RANK R ON CE.ID_RANK = R.ID
            LEFT JOIN TECHNIKA T ON ct_b.ID_TECH = T.ID

            WHERE

              (CE.WRONG_CALL IS NULL OR CE.WRONG_CALL = 0)

             -- AND ct_b.RETREAT_TIME IS NULL
             -- AND (ct_b.TECH_DELETED = 0 OR ct_b.TECH_DELETED IS NULL)


/*        #if ($params.get("Выгружено для ФОМС").equals("1"))
              AND AC.FOMS_FILL = 1
        #end*/

AND
              CE.TIME_REG BETWEEN TIMESTAMP '2022-12-03 00:00:00' AND TIMESTAMP '2022-12-04 00:00:00'

/*       AND  (
                    ( CE.TIME_REG::DATE >= TO_DATE('2022-10-03 00:00:00', 'DD.MM.YYYY') ) AND
                    ( CE.TIME_REG::DATE <= TO_DATE('$params.get("дата2")', 'DD.MM.YYYY') ) AND
                    ( ct_b.RECEIVE_TIME IS NULL OR ct_b.RECEIVE_TIME::DATE <= TO_DATE('$params.get("дата2")', 'DD.MM.YYYY') ) AND
                    ( ct_b.AT_PLACE_TIME IS NULL OR ct_b.AT_PLACE_TIME::DATE <= TO_DATE('$params.get("дата2")', 'DD.MM.YYYY') ) AND
                    ( ct_b.RETURN_TIME IS NULL OR ct_b.RETURN_TIME::DATE <= TO_DATE('$params.get("дата2")', 'DD.MM.YYYY') )
              )
*/
/*
#if ($params.get("Только по причине завершения") && !$params.get("Только по причине завершения").isEmpty())
              AND ( #foreach( $retreat in $params.get("Только по причине завершения").split(", ") ) CE.RETREAT_REASON = '$retreat' #if( $foreach.hasNext )OR #end #end )
#end


#if ($params.get("Источник финансирования") && !$params.get("Источник финансирования").isEmpty())
              AND AIF.ID IN (#foreach( $id in $params.get("Источник финансирования").split(", ") )$id #if( $foreach.hasNext ), #end #end )
#end

#if ($params.get("Включая диагнозы") && !$params.get("Включая диагнозы").isEmpty())
              AND AIP1.ID IN (#foreach( $id in $params.get("Включая диагнозы").split(", ") )$id #if( $foreach.hasNext ), #end #end )
            #end

#if ($params.get("Исключая диагнозы") && !$params.get("Исключая диагнозы").isEmpty())
              AND AIP1.ID NOT IN (#foreach( $id in $params.get("Исключая диагнозы").split(", ") )$id #if( $foreach.hasNext ), #end #end )
#end

#if ($params.get("Исключая поводы вызова") && !$params.get("Исключая поводы вызова").isEmpty())
              AND R.ID NOT IN (#foreach( $id in $params.get("Исключая поводы вызова").split(", ") )$id #if( $foreach.hasNext ), #end #end )
#end


#if ($params.get("Исключая коды специалистов") && !$params.get("Исключая коды специалистов").isEmpty())
              AND ASTFOMS.CODE::numeric NOT IN (#foreach( $id in $params.get("Исключая коды специалистов").split(",") )$id #if( $foreach.hasNext ), #end #end )
#end

#if ($params.get("Включая коды специалистов") && !$params.get("Включая коды специалистов").isEmpty())
              AND ASTFOMS.CODE::numeric IN (#foreach( $id in $params.get("Включая коды специалистов").split(",") )$id #if( $foreach.hasNext ), #end #end )
#end


#if ($params.get("Подразделения") && !$params.get("Подразделения").isEmpty())
                  and T.ID_PULT  in ($params.get("Подразделения"))
#end

#if($params.get("Только рег. номера") && !$params.get("Только рег. номера").isEmpty() )
   AND ce.REG_NO IN ($params.get("Только рег. номера"))
#end

#if($params.get("Рег. номера кроме") && !$params.get("Рег. номера кроме").isEmpty() )
   AND ce.REG_NO NOT IN ($params.get("Рег. номера кроме"))
#end*/

            GROUP BY
              AV.CODE, AP.UNIFIED_POLICY_NUMBER, AIC.OKATO_OMS, AIC.CODE, AC.ID_CALL, ACC.CODE, CE.ID,
              AV12.CODE, APA.IS_NOT_HOSPITALIZED, AC.YEARS, ASFFOMS.CODE, ADR.CAPTION, ADC.CAPTION, ACDO.CAPTION,
              ACC.CAPTION, ACR.CAPTION, AP.BIRTHDAY, AP.SEX, DT.CODE, ACP.CODE, AIF.CODE, ART.CODE, ACM.CODE,
              ACPF.CODE, AC.ACCOMPANYING_SHEET, ST.CODE, ASTFOMS.CODE, ct_b.RETREAT_TIME, PARENT_AP.LAST_NAME, PARENT_AP.FIRST_NAME,
              PARENT_AP.MIDDLE_NAME, AP.LAST_NAME, AP.FIRST_NAME, AP.MIDDLE_NAME, PARENT_AP.SEX, PARENT_AP.BIRTHDAY,
              AP.PASSPORT_SERIES, AP.PASSPORT_NUMBER, AP.SERIES_POLICY, AC.ID_CATEG_CALL_RESULT, AC.CALL_MILEAGE_KM,
              APA.IS_ACT_CALL_FROM_BRIGADE, APA.IS_ACT_CALL_ACTIVE, APA.IS_ALREADY_EXPORTED_TO_FOMS, APA.IS_PERFORM_CPR, CE.CALL_NUMB, APA.IS_HOSPITALIZED,
              AIP1.CODE, AIP2.CODE, AIP3.CODE, APD.CAPTION, APD.IS_LPU, CE.REG_NO, AP.ID, ST.PENSION_NUMBER, ASTFOMS.IS_CHILD_PROFIL, ASTFOMS.id_spec_profil,
              AP.DOC_DATE_ISSUE, AP.DOC_ORGANIZATION_ISSUE,  ADR.CODE, pult_take_call.caption
            ORDER BY AC.ID_CALL
