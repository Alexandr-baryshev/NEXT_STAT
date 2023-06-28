select r.id,
       m.caption || ' ' || mc.caption caption_car,
       tdg.number_plate,
       trw.caption                    repair_caption,
       (select odometer_arrival
        from waybill w
        where w.deleted = 0
          and w.id_status_waybill <> 3
          and w.id_car = r.id_car
          and w.date_time_arrival <= r.dt_start
        order by w.date_time_arrival desc
        limit 1)                      odometer,
       r.dt_start,
       r.dt_end,
       trw.ignore_timeout
from repair r
         left join type_repair_work trw on r.id_type_work = trw.id
         left join technika t on r.id_car = t.id
         left join tech_data_garage tdg on t.id = tdg.id_technika
         left join model_car mc on tdg.id_model = mc.id
         left join mark_car m on mc.id_mark_car = m.id
where r.dt_start::date
    BETWEEN TIMESTAMP '2022-01-01 00:00:00' AND TIMESTAMP '2023-08-08 00:00:00'
  and r.deleted = 0
  --  #if ( $params.get("Фильтр автомобилей") && !$params.get("Фильтр автомобилей").isEmpty() )
  --      and t.id in (#foreach( $id in $params.get("Фильтр автомобилей").split(", ") )$id #if( $foreach.hasNext ), #end #end )
  --  #end
order by r.dt_start