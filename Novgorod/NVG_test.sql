
            SELECT
              CE.CALL_NUMB                nusl,
              AHC.ID                      idserv,
              CE.ID                       idcall,
              (
                CASE WHEN MIN(CT.AT_PLACE_TIME) IS NULL
                THEN CE.TIME_REG
                ELSE MIN(CT.AT_PLACE_TIME)
                END
              )                           date_in,
              (
                CASE WHEN MIN(CT.RETURN_TIME) IS NULL
                THEN CE.TIME_REG
                ELSE MIN(CT.RETURN_TIME)
                END
              )                           date_out,
              AHC.AMOUNT                  kol_usl,
              0                           tarif,
              0                           sumv_usl,
              ASF.CODE                    prvs,
              ST.PENSION_NUMBER           code_md,
              AES.TRUD                    uet_fakt,
              AST.CODE                    executor,
              AES.TERRCODE                code_usl,
              (
                SELECT LIST_MED FROM
                (
                  SELECT
                    idserv,
                    listagg(FULL_CATION, '|')
                    WITHIN GROUP (
                      ORDER BY idserv) LIST_MED
                  FROM (
                         SELECT
                           AHC.ID idserv,
                           MED.CAPTION || '::' ||
                           (
                             SELECT ATX.CODE
                             FROM WAREHOUSE_ATX ATX
                               INNER JOIN WAREHOUSE_REF_MED_ATX_V2 REF_ATX ON REF_ATX.ATX_ID = ATX.ID
                             WHERE REF_ATX.MEDICAMENT_ID = MED.ID AND ROWNUM <= 1
                           ) || '::' || AHCM.amount FULL_CATION
                         FROM ARM03_HELP_CALL_MED AHCM
                           LEFT JOIN ARM03_HELP_CALL AHC ON AHCM.ID_HELP_CALL = AHC.ID
                           LEFT JOIN WAREHOUSE_RFOF_MEDICAMENT_V2 RFOF_MED ON AHCM.ID_MEDICAMENT = RFOF_MED.ID
                           LEFT JOIN WAREHOUSE_MEDICAMENT_V2 MED ON RFOF_MED.MEDICAMENT_ID = MED.ID
                         ORDER BY AHC.ID DESC
                       ) MED_FULL
                  GROUP BY idserv
                  ORDER BY idserv DESC
                ) WHERE idserv = AHC.ID AND ROWNUM <= 1
              ) rl
            FROM ARM03_HELP_CALL AHC
              INNER JOIN CALL_EVENT CE ON AHC.ID_CALL = CE.ID
              LEFT JOIN CALL_TECH CT ON CT.ID_CALL = CE.ID
              LEFT JOIN ARM03_CALL AC ON AC.ID_CALL = CE.ID
              LEFT JOIN ARM03_EASY_SERVICE AES ON AHC.ID_EASY_SERVICE = AES.ID
              LEFT JOIN ARM03_PATIENT_ASSISTANCE APA ON AC.ID_CALL = APA.ID
              LEFT JOIN STAFF_TBL ST ON APA.ID_DOCTOR = ST.ID
              LEFT JOIN ARM03_SPEC_TFOMS AST ON ST.ID_SPEC_TFOMS = AST.ID
              LEFT JOIN ARM03_SPEC_FFOMS ASF ON AST.ID_SPEC_FFOMS = ASF.ID
              LEFT JOIN ARM03_IST_FIN AIF ON APA.ID_IST_FIN = AIF.ID
            WHERE
              CT.RETREAT_TIME IS NULL
              AND (CT.TECH_DELETED = 0 OR CT.TECH_DELETED IS NULL)
            #if ($params.get("Выгружено для ФОМС").equals("1"))
              AND AC.FOMS_FILL = 1
            #end
              AND AC.IS_EXPORTED_TO_FOMS <> 1
              AND (CE.WRONG_CALL IS NULL OR CE.WRONG_CALL = 0)
              AND (TRUNC(CE.TIME_REG) >= TO_TIMESTAMP('$params.get("дата1")', 'DD.MM.YYYY')) AND (TRUNC(CE.TIME_REG) <= TO_TIMESTAMP('$params.get("дата2")', 'DD.MM.YYYY'))
            #if ($params.get("Только по причине завершения") && !$params.get("Только по причине завершения").isEmpty())
              AND ( #foreach( $retreat in $params.get("Только по причине завершения").split(", ") ) CE.RETREAT_REASON = '$retreat' #if( $foreach.hasNext )OR #end #end )
            #end
            #if ($params.get("Источник финансирования") && !$params.get("Источник финансирования").isEmpty())
              AND AIF.ID IN (#foreach( $id in $params.get("Источник финансирования").split(", ") )$id #if( $foreach.hasNext ), #end #end )
            #end
            GROUP BY AHC.ID, AES.CODE, AHC.AMOUNT, ASF.CODE, ST.PENSION_NUMBER, CE.ID, AES.TRUD, AST.CODE, AES.TERRCODE, CE.TIME_REG, CE.CALL_NUMB
            ORDER BY CE.ID