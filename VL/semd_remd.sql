select remd_info_short.document_version  as short_remd_document_version,
       remd_info_short.semd_id           as short_remd_semd_id,
       remd_info_short.semd_ts           as short_remd_semd_ts,
       remd_info_short.remd_id           as short_remd_remd_id,
       remd_info_short.remd_ts           as short_remd_remd_ts,
       remd_info_short.remd_status_short as short_remd_remd_status_short
from CALL_EVENT ce
       LEFT JOIN DWORKER.REMD_INFO_SHORT remd_info_short on ce.id = remd_info_short.id_call
where (ce.TIME_REG BETWEEN TIMESTAMP '2023-01-01 00:00:00' AND TIMESTAMP '2023-01-16 00:00:00')