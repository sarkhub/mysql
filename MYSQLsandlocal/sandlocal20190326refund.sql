-- sandlocal20190326refund

use sandlocal;

CREATE TABLE order_modified
(
trnx_id varchar(22) NOT NULL,
order_id varchar(50) NOT NULL,
modified_dt datetime DEFAULT NULL,
primary key(trnx_id),
key order_id(order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


DROP PROCEDURE GenerateRefund
DELIMITER //
CREATE PROCEDURE GenerateRefund(IN v_order_id varchar(50))
BEGIN

DECLARE trnx_id varchar(22);

SET trnx_id = fn_key_gen();

insert into sandlocal.order_modified
(
trnx_id,
order_id,
modified_dt
)
values
(
trnx_id,
v_order_id,
now()
);

END //
DELIMITER ;

CALL GenerateRefund('order_190326113717024EB92D');

select * from sandlocal.order_modified;


-- show modified orders

CREATE VIEW orders_modified_vw
AS
select 
sandlocal.order.amount,
sandlocal.order.fee,
sandlocal.order.add_dt,
sandlocal.order_status.prod_cd,
sandlocal.order_status.cnfrmtn_nbr
from
sandlocal.order,
sandlocal.order_status,
sandlocal.order_modified
where
sandlocal.order.trnx_id = sandlocal.order_status.trnx_id
and
sandlocal.order.order_id = sandlocal.order_modified.order_id;


select * from orders_modified_vw;

