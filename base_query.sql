select --
       ce.id        as id_call,
       ce.REG_NO    as рег_номер,
       ce.call_numb as номер_вызова,
       ce.TIME_REG  as вр_регистрации

from CALL_EVENT ce

where (
              ce.TIME_REG BETWEEN TIMESTAMP '2023-07-11 00:00:00' AND TIMESTAMP '2023-07-12 00:00:00'
              AND (ce.call_numb > 0.0)
          )