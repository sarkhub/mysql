-- sandlocal20190409compresstest

use sandlocal;

create table test_compress
(
trnx_id varchar(22) primary key,
cnfrmtn_nbr varchar(50)
)
ROW_FORMAT=COMPRESSED;


DELIMITER //
CREATE  PROCEDURE StressGenerateCompress(IN order_cnt INT)
BEGIN

DECLARE count INT DEFAULT 0;
DECLARE v_trnx_id varchar(22);
DECLARE v_cnfrmtn_nbr varchar(50);



WHILE count < order_cnt DO
    SET v_trnx_id = fn_key_gen();
    SET v_cnfrmtn_nbr = fn_key_gen();
	insert into test_compress(trnx_id, cnfrmtn_nbr)
    values(v_trnx_id,v_cnfrmtn_nbr);
    SET count = count + 1;
END WHILE;

END //
DELIMITER ;

-- ---------------------------------------------------------------------------

CALL StressGenerateCompress(3000);


select * from test_compress;

select count(*) from test_compress;



