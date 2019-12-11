-- sandlocal20190328cards

use sandlocal;


CREATE TABLE `order_card` (
  `trnx_id` varchar(22) NOT NULL,
  `masked_cc` varchar(50) NOT NULL,
  PRIMARY KEY (`trnx_id`),
  KEY `masked_cc` (`masked_cc`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


INSERT INTO ORDER_CARD
VALUES('E','E_ORDER',
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

select * from ORDER_CARD
LIMIT 50;

select count(*) from ORDER_CARD;


-- DELETE  FROM ORDER_CARD;

-- backload all orders
INSERT INTO ORDER_CARD
select trnx_id,
CONCAT(
'4'
,
substring(rand(),4,5)
,
'XXXXXX'
,
substring(rand(),4,4)
)
from sandlocal.order
where substring(trnx_id,1,6) = '190326';

select count(*) from ORDER_CARD;

select count(*) from sandlocal.order;

select * from sandlocal.order_card
order by trnx_id desc
LIMIT 20;

