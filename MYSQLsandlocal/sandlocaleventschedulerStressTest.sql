use sandlocal;


SHOW PROCESSLIST;

-- By default, the event scheduler thread is not enabled.
SET GLOBAL event_scheduler = ON;

-- turn it off later
-- SET GLOBAL event_scheduler = OFF;


CREATE EVENT test_event_01
ON SCHEDULE EVERY 1 MINUTE
ON COMPLETION PRESERVE
DO
   CALL StressGenerateOrder(2);
   
   
ALTER EVENT test_event_01
ON SCHEDULE EVERY 1 MINUTE;
   
   
-- totals
select count(*) from sandlocal.order;   
-- 978878
   
   

DROP EVENT  test_event_01;