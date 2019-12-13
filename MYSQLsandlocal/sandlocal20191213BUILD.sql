-- sandlocal20190328BUILD
USE sandlocal

-- BUILD ALL sandlocal to cloud DB


-- PERFORM BUILD

CREATE TABLE sandlocal.order
(
trnx_id varchar(22),
order_id varchar(50),
cdf0 varchar(50),
amount decimal(13,2),
fee decimal(13,2),
add_dt datetime,
primary key(trnx_id),
index(order_id)
);

CREATE TABLE sandlocal.order_status
(
cnfrmtn_nbr int NOT NULL AUTO_INCREMENT,
trnx_id varchar(22),
order_id varchar(50),
prod_cd varchar(50),
status varchar(1),
add_dt datetime,
primary key(cnfrmtn_nbr),
key trnx_id(trnx_id),
key order_id(order_id)
);

CREATE TABLE sandlocal.order_card (
trnx_id varchar(22) NOT NULL,
masked_cc varchar(50) NOT NULL,
PRIMARY KEY (trnx_id),
KEY masked_cc (masked_cc)
);


--- try using a function ------------




DELIMITER //
CREATE FUNCTION fn_key_gen()
  RETURNS VARCHAR(22)
  deterministic
BEGIN

DECLARE new_key VARCHAR(22);
SET new_key =
CONCAT(SUBSTRING(YEAR(now()),3,2)
,
LPAD(MONTH(now()),2,'0')
,
LPAD(DAY(now()),2,'0')
,
LPAD(HOUR(now()),2,'0')
,
LPAD(MINUTE(now()),2,'0')
,
LPAD(SECOND(now()),2,'0')
,
SUBSTRING(rand(),5,3) -- number
,
UPPER(SUBSTRING(MD5(RAND()) FROM 1 FOR 5))  -- Alpha Numeric Mix
);

RETURN new_key;
END //
DELIMITER ;


------------------------------------

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

------------

CALL GenerateOrder();

select * from sandlocal.order;

------------


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



--------------------------------------------------------------

CREATE TABLE order_modified
(
trnx_id varchar(22) NOT NULL,
order_id varchar(50) NOT NULL,
modified_dt datetime DEFAULT NULL,
primary key(trnx_id),
key order_id(order_id)
);


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

-------------------------------------------------------------------------------



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



------------------------------


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

CALL GetReceipt(22);


-----------------------------------------------------------


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

-------------------------------------------------------------





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

