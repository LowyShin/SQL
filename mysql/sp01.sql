/*-- KPI Table */
create table tkpi(
  regdate datetime
  , loandb_amount bigint
  , loandb_account bigint
  , newloan_amount bigint
  , newdxtra_account bigint
  , newdana_amount bigint
  , newdana_account bigint
  , probacc_amount bigint
  , probacc_account bigint
  , npl_amount bigint
  , npl_account bigint
)

/* Base date table */
create table tDefDate(
  regdt varchar(8)
)

/* KPI Query */

select dd.regdt, l.*
from tDefDate dd 
left outer join (
  SELECT DATE_FORMAT(loan_update_date,'%Y/%m/%d') as lregdt
      , sum(ls.loan_amount) as loandb_amount , sum(case when ls.loan_amount > 0 then 1 else 0 end) as loandb_account
      , sum(l.loan_amount) as newdxtra_amount , sum(case when l.loan_amount > 0 then 1 else 0 end) as loandb_account
      , sum(ls.loan_amount) as newdana_amount , sum(case when ls.loan_amount > 0 then 1 else 0 end) as loandb_account
      , sum(case when Xpast_day > 3 then ls.loan_amout else 0 end ) as probacc_amount , sum(case when ls.loan_amount > 0 then 1 else 0 end) as loandb_account
      , sum(ls.loan_amount) as npl_amount , sum(case when ls.loan_amount > 0 then 1 else 0 end) as loandb_account
  from payment_history_tbl ph
  left outer join loan_status_tbl ls on ph.loan_idx = ls.loan_idx
  left outer join loan_tbl l on ph.loan_idx = l.loan_idx
  group by DATE_FORMAT(loan_update_date,'%Y/%m/%d')
 ) l on dd.regdt = l.lregdt



/*-- not recommand example ----------*/
DELIMITER //  
CREATE PROCEDURE proc_payment_fill_onprogress()   
BEGIN
DECLARE Xloan_idx int(11);
DECLARE Xloan_code varchar(50);
DECLARE Xproduct_name varchar(255);
DECLARE Xinterest_cking_min float;
DECLARE Xloan_period smallint(4);
DECLARE Xinterest_over_per float;
DECLARE Xinterest_over_rp int(11);
DECLARE Xinterest_over int(11);
DECLARE Xprincipal int(11);
DECLARE Xinterest int(11);
DECLARE Xoverdue_interest int(11);
DECLARE Xprincipal_before int(11);
DECLARE Xinterest_before int(11);
DECLARE Xoverdue_interest_before int(11);
DECLARE Xprincipal_repay int(11);
DECLARE Xinterest_repay int(11);
DECLARE Xoverdue_interest_repay int(11);
DECLARE Xgrace_day tinyint(2);
DECLARE Xpast_day int(11);
DECLARE Xloan_start_date varchar(30);
DECLARE Xloan_end_date varchar(30);
DECLARE Xloan_update_date varchar(30);
DECLARE Xloan_status varchar(3);
DECLARE Xloan_comment varchar(255);

DECLARE idx_now int(11);
DECLARE idx_total int(11);

SET idx_now = 1055;
SELECT count(*) INTO idx_total from
  (SELECT *
  FROM payment_history_tbl A
  WHERE A.loan_code in (
    SELECT loan_code 
    FROM payment_history_tbl
    WHERE loan_status in (40, 41, 50, 51, 52))
  GROUP BY A.loan_code having count(*) = 1) AA;

WHILE (idx_now < idx_total) DO
  SELECT loan_idx, loan_code, product_name, interest_cking_min, loan_period, interest_over_per, interest_over_rp, interest_over, 
    principal, interest, overdue_interest, principal_before, interest_before, overdue_interest_before, principal_repay, 
    interest_repay, overdue_interest_repay, grace_day, past_day, loan_start_date, loan_end_date, loan_update_date, 
    loan_status, loan_comment
  INTO Xloan_idx, Xloan_code, Xproduct_name, Xinterest_cking_min, Xloan_period, Xinterest_over_per, Xinterest_over_rp, Xinterest_over, 
    Xprincipal, Xinterest, Xoverdue_interest, Xprincipal_before, Xinterest_before, Xoverdue_interest_before, Xprincipal_repay, 
    Xinterest_repay, Xoverdue_interest_repay, Xgrace_day, Xpast_day, Xloan_start_date, Xloan_end_date, Xloan_update_date, 
    Xloan_status, Xloan_comment
  FROM payment_history_tbl A
  WHERE A.loan_code in (
    SELECT loan_code 
    FROM payment_history_tbl
    WHERE loan_status in (40, 41, 50, 51, 52) GROUP BY A.loan_code having count(*) = 1)
    ORDER BY idx
  LIMIT idx_now, 1;

  SET Xinterest_before = 0;
  SET Xinterest_repay = 0;
  SET Xloan_update_date = DATE_ADD(Xloan_update_date, INTERVAL 1 DAY);
  SET Xpast_day = DATEDIFF(Xloan_update_date, Xloan_end_date);

  WHILE (DATEDIFF(Xloan_update_date, CURDATE()) < 1) DO

    SET Xoverdue_interest_before = Xoverdue_interest;
    IF Xpast_day > 3 THEN
      SET Xloan_status = "57";
      SET Xoverdue_interest = Xpast_day * Xinterest_over;
    ELSEIF Xpast_day < 4 and Xpast_day > 0 THEN
      SET Xloan_status = "56";
      SET Xoverdue_interest = 0;
    ELSEIF Xpast_day < 1 THEN
      SET Xloan_status = "55";
      SET Xoverdue_interest = 0;
    END IF;

    IF Xpast_day > -4 THEN
      INSERT INTO payment_history_tbl 
        (loan_idx, loan_code, product_name, interest_cking_min, loan_period, interest_over_per, interest_over_rp, interest_over, 
        principal, interest, overdue_interest, principal_before, interest_before, overdue_interest_before, principal_repay, 
        interest_repay, overdue_interest_repay, grace_day, past_day, loan_start_date, loan_end_date, loan_update_date, 
        loan_status, loan_comment)
      VALUES 
        (Xloan_idx, Xloan_code, Xproduct_name, Xinterest_cking_min, Xloan_period, Xinterest_over_per, Xinterest_over_rp, Xinterest_over, 
        Xprincipal, Xinterest, Xoverdue_interest, Xprincipal_before, Xinterest_before, Xoverdue_interest_before, Xprincipal_repay, 
        Xinterest_repay, Xoverdue_interest_repay, Xgrace_day, Xpast_day, Xloan_start_date, Xloan_end_date, Xloan_update_date, 
        Xloan_status, Xloan_comment);
    END IF;
    SET Xloan_update_date = DATE_ADD(Xloan_update_date, INTERVAL 1 DAY);
    SET Xpast_day = DATEDIFF(Xloan_update_date, Xloan_end_date);

  END WHILE;
    
  SET idx_now = idx_now + 1;
END WHILE;
END;
//


select *
  FROM payment_history_tbl A
  WHERE A.loan_code in (
    SELECT loan_code 
    FROM payment_history_tbl
    WHERE loan_status in (40, 41, 50, 51, 52) GROUP BY A.loan_code having count(*) = 1)
    ORDER BY idx


// 론코드 중복인거 찾기
SELECT loan_code, count(1)
FROM payment_history_tbl A
WHERE loan_status in (40, 41, 50, 51, 52) 
GROUP BY A.loan_code having count(*) > 1



