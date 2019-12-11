-- sandlocal20190327functions

use sandlocal;

-- date only no time
select date(now());

select count(*)
from sandlocal.order
where add_dt >= date(now());

-- DROP FUNCTION fn_d_start;
DELIMITER //
CREATE  FUNCTION `fn_d_start`() RETURNS datetime
    DETERMINISTIC
BEGIN

DECLARE d_start datetime;
SET d_start = date(now());


RETURN d_start;
END//
DELIMITER ;


select fn_d_start();


