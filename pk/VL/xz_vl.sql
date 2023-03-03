select count(distinct semd_id)

from call_event ce
       left join dworker.remd_info_short ri on ce.id = ri.id_call
where ri.semd_ts between '2023-01-10 12:00:00' and '2023-01-18 12:00:00';






select count(distinct semd_id)                                                                        semd_count,
       count(distinct case when semd_id is not null and remd_status_short is null then semd_id end)   without_answer,
       count(distinct case when semd_id is not null and remd_status_short = 'Ok' then semd_id end)    ok,
       count(distinct case when semd_id is not null and remd_status_short = 'Error' then semd_id end) error
from call_event ce
       left join dworker.remd_info_short ri on ce.id = ri.id_call
where ri.semd_ts between '2023-01-10 12:00:00' and '2023-01-18 12:00:00';