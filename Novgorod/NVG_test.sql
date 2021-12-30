select a03_assistance_result.caption as результат_помощи

from CALL_EVENT ce
       LEFT JOIN ARM03_PATIENT_ASSISTANCE apa on ce.ID = apa.ID
       LEFT JOIN ARM03_ASSISTANCE_RESULT a03_assistance_result on apa.ID_ASSISTANCE_RESULT = a03_assistance_result.id

where (ce.TIME_REG BETWEEN TIMESTAMP '2021-12-01 00:00:00' AND TIMESTAMP '2021-12-30 00:00:00')
group by a03_assistance_result.caption;

---------- // ----------

select a03_depa_result.caption as результат_вызова

from CALL_EVENT ce

       LEFT JOIN ARM03_PATIENT_ASSISTANCE apa on ce.ID = apa.ID
       LEFT JOIN ARM03_DEPARTURE_RESULT a03_depa_result on apa.ID_DEPARTURE_RESULT = a03_depa_result.id

where (ce.TIME_REG BETWEEN TIMESTAMP '2021-10-01 00:00:00' AND TIMESTAMP '2021-12-30 00:00:00'
  and lower(a03_depa_result.caption) like '%смерть%'
  )
group by a03_depa_result.caption;