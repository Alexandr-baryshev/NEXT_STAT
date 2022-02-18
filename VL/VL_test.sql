select a03_assistance_result.caption as c03_assistance_result
from CALL_EVENT ce
       LEFT JOIN ARM03_PATIENT_ASSISTANCE apa on ce.ID = apa.ID
       LEFT JOIN ARM03_ASSISTANCE_RESULT a03_assistance_result on apa.ID_ASSISTANCE_RESULT = a03_assistance_result.id
where (ce.TIME_REG BETWEEN TIMESTAMP '2022-01-01 00:00:00' AND TIMESTAMP '2022-02-01 00:00:00')
group by a03_assistance_result.caption