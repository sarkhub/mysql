-- sandlocal20190329isAlive
USE sandlocal;

DELIMITER //
CREATE PROCEDURE isAlive()
BEGIN


 select fn_key_gen() as keyout;


END //
DELIMITER ;


CALL isAlive();


CREATE USER someuser IDENTIFIED BY 'somepass';

GRANT EXECUTE ON PROCEDURE sandlocal.isAlive TO 'someuser';

