-- sandlocal20190326

use sandlocal;

-- GOAL IS TO GENERATE ORDER AND ORDER_STATUS

DROP PROCEDURE GenerateOrder
DELIMITER //
CREATE PROCEDURE GenerateOrder()
BEGIN

DECLARE trnx_id varchar(22);
DECLARE amt decimal(13,2);
DECLARE fee decimal(13,2);
DECLARE prod_cd varchar(2);

SET trnx_id = fn_key_gen();
SET amt = substring(rand(),4,4);
SET fee = amt*.03;
SET prod_cd = substring(rand(),4,2);

insert into sandlocal.order
(
trnx_id,
order_id,
cdf0,
amount,
fee,
add_dt
)
values
(
trnx_id,
CONCAT('order_',trnx_id),
'testuser',
amt,
fee,
now()
);

insert into sandlocal.order_status
(
-- cnfrmtn_nbr is automatic
trnx_id,
order_id,
prod_cd,
status,
add_dt
)
values
(
trnx_id,
CONCAT('order_',trnx_id),
prod_cd,
'1',
now()
);

insert into sandlocal.order_card
(
trnx_id,
masked_cc)
values
(
trnx_id,
	CONCAT(
	'4'
	,
	substring(rand(),4,5)
	,
	'XXXXXX'
	,
	substring(rand(),4,4)
	)
);

END //
DELIMITER ;

CALL GenerateOrder();

select * from sandlocal.order;

truncate table sandlocal.order;  -- can not do this because of foreign key

select * from sandlocal.order_status;

-- now create stress tester procedure

DROP PROCEDURE StressGenerateOrder
DELIMITER //
CREATE PROCEDURE StressGenerateOrder(IN order_cnt INT)
BEGIN

DECLARE count INT DEFAULT 0;

WHILE count < order_cnt DO
	CALL GenerateOrder();
    SET count = count + 1;
END WHILE;

END //
DELIMITER ;


CALL StressGenerateOrder(700);

select count(*) from sandlocal.order_status;

-- now by date
select date(add_dt) as order_dt, count(*) as total
from sandlocal.order_status
group by 1
order by 1;

-- filter by date
select date(add_dt) as order_dt, count(*) as total
from sandlocal.order_status
where add_dt < '2019-03-29'
group by 1
order by 1;


-- sum all records
select count(*)
from sandlocal.order_status;

-- max confirmation number
select max(cnfrmtn_nbr) 
from sandlocal.order_status;



-- counts based on product codes
select prod_cd, count(*)
from sandlocal.order_status
group by prod_cd;

-- counts based on product codes (by date)
select prod_cd, date(add_dt) as order_dt, count(*)
from sandlocal.order_status
group by prod_cd, date(add_dt)
order by 1,2;

-- filtered search by confirmation number
select sandlocal.order.*,
sandlocal.order_status.*
from
sandlocal.order,
sandlocal.order_status
where
sandlocal.order.trnx_id = sandlocal.order_status.trnx_id
-- and
-- sandlocal.order_status.cnfrmtn_nbr = 22523
LIMIT 50;



select 
sandlocal.order_status.prod_cd,
SUM(sandlocal.order.amount) as amount_total,
count(*)
from
sandlocal.order,
sandlocal.order_status
where
sandlocal.order.trnx_id = sandlocal.order_status.trnx_id
group by sandlocal.order_status.prod_cd
order by 1;


-- create view for powerBI analysis

CREATE VIEW orders_vw
AS
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
sandlocal.order_status.order_id NOT IN
(
select order_id from sandlocal.order_modified -- exclude refunds
);


select * from orders_vw;



