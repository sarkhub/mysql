-- 191210eventscheduler

use sandlocal;


SHOW PROCESSLIST;

-- By default, the event scheduler thread is not enabled.
SET GLOBAL event_scheduler = ON;

-- turn it off later
-- SET GLOBAL event_scheduler = OFF;


CREATE EVENT test_event_02
ON SCHEDULE EVERY 1 MINUTE
ON COMPLETION PRESERVE
DO
   CALL StressGenerateOrder_1(10000);
   
   
ALTER EVENT test_event_02
ON SCHEDULE EVERY 1 MINUTE;
   
   
-- totals
select count(*) from order_1;   
-- 978878
   
   

DROP EVENT  test_event_02;
