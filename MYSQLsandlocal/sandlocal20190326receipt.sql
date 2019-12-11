-- sandlocal20190326receipt

use sandlocal;

-- get receipt details


DROP PROCEDURE GetReceipt
DELIMITER //
CREATE PROCEDURE GetReceipt(IN v_cnfrmtn_nbr INT)
BEGIN

select 
sandlocal.order.amount,
sandlocal.order.fee,
sandlocal.order.add_dt,
sandlocal.order_status.prod_cd,
sandlocal.order_status.cnfrmtn_nbr
from
sandlocal.order,
sandlocal.order_status
where
sandlocal.order.trnx_id = sandlocal.order_status.trnx_id
and
sandlocal.order_status.cnfrmtn_nbr = v_cnfrmtn_nbr;

END //
DELIMITER ;

CALL GetReceipt(22215);
