-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 21, 2026 at 06:04 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `remmitance`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `account_view_pro` ()   BEGIN
select acc_no as ID,acc_name as Account_Name,acc_type as Type,institution,blance from acounts order by acc_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `acounts_pro` (IN `acc_name_pro` VARCHAR(30), IN `acc_type_pro` VARCHAR(30), IN `institution_pro` TEXT, IN `blance_pro` DOUBLE, IN `oper` VARCHAR(30), IN `num` INT)   BEGIN
CASE
when oper="select" then
select * from acounts;

when oper="insert" then
if EXISTS(select * from acounts where acc_name=acc_name_pro and acc_type=acc_type_pro and institution=institution_pro and blance=blance_pro) THEN
select "this info is already exists" as msg;
ELSEIF blance_pro <> 0 THEN
    SELECT "Account balance must be 0 when creating a new account." AS msg;
ELSE
insert into acounts VALUES(null,acc_name_pro,acc_type_pro,institution_pro,blance_pro);
select "inserted success" as msg;
end if;

when oper="update" then
if EXISTS(select * from acounts where acc_no=num) THEN
update acounts set acc_name=acc_name_pro,acc_type=acc_type_pro,institution=institution_pro,blance=blance_pro where acc_no=num;
select "updated success" as msg;
else 
select "this id is not exists" as msg;
end if;


when oper="delete" then
if EXISTS(select * from acounts where acc_no=num) THEN
delete from acounts where acc_no=num;
select "deleted success" as msg;
else 
select "this id is not exists" as msg;
end if;

end case;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `countries_pro` (IN `con_name_sp` VARCHAR(50), IN `zip_code_sp` VARCHAR(50), IN `oper` VARCHAR(30), IN `num` INT)   BEGIN
CASE

when oper="insert" then
if exists (select * from countries where con_name=con_name_sp and zip_code=zip_code_sp) THEN
select concat(con_name_sp,', ',zip_code_sp,' already exist') as msg;
else 
insert into countries values(null,con_name_sp,zip_code_sp);
select "inserted success" as msg;
end if;


when oper="update" then
if exists (select * from countries where con_no=num) THEN
update countries set con_name=con_Name_sp,zip_code=zip_code_sp where con_no=num;
select "updated success" as msg;
else 
select concat('This id:',num,' is not exists') as msg;
end if;


when oper="delete" then
if exists (select * from countries where con_no=num) THEN
delete from countries where con_no=num;
select "deleted success" as msg;
else 
select concat('This id:',num,' is not exists') as msg;
end if;

end case;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `countries_report_all` ()   BEGIN

select con_no as ID,con_name as Country,zip_code as Postal_Code from countries order by con_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `countries_report_sin` (IN `num` INT)   BEGIN

select con_no as ID,con_name as Country,zip_code as Postal_Code from countries where con_no=num order by con_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Countries_view` ()   BEGIN

select con_no ID,con_name Country_Name,zip_code Postal_Code from countries order by con_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `forgot_password_pro` (IN `email_pro` VARCHAR(100))   BEGIN

SELECT
    u.user_name,
    u.Password
FROM users u
INNER JOIN people p
ON u.p_no = p.p_no
WHERE p.email = email_pro;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `loans_payment_pro` (IN `loan_no_pro` INT, IN `amount_pro` DOUBLE, IN `payment_date_pro` DATE, IN `acc_no_pro` INT, IN `oper` VARCHAR(30), IN `num` INT)   BEGIN
DECLARE loan_amount DOUBLE DEFAULT 0;
DECLARE paid_amount DOUBLE DEFAULT 0;
DECLARE remaining_amount DOUBLE DEFAULT 0;
DECLARE loan_date_value DATE;
DECLARE due_date_value DATE;
DECLARE old_amount DOUBLE DEFAULT 0;
DECLARE old_acc_no INT DEFAULT 0;

CASE

WHEN oper="select" THEN
SELECT * FROM loans_payment;

WHEN oper="insert" THEN

IF amount_pro<=0 THEN
SELECT "Payment amount must be greater than 0." AS msg;

ELSEIF payment_date_pro IS NULL THEN
SELECT "Payment date is required." AS msg;

ELSEIF NOT EXISTS(SELECT * FROM loans WHERE loan_no=loan_no_pro) THEN
SELECT "The selected loan does not exist." AS msg;

ELSE

SELECT amount,loan_date,due_date
INTO loan_amount,loan_date_value,due_date_value
FROM loans
WHERE loan_no=loan_no_pro;

SELECT IFNULL(SUM(amount),0)
INTO paid_amount
FROM loans_payment
WHERE loan_no=loan_no_pro;

SET remaining_amount=loan_amount-paid_amount;

IF EXISTS(
SELECT * FROM loans_payment
WHERE loan_no=loan_no_pro
AND amount=amount_pro
AND pyment_date=payment_date_pro
AND acc_no=acc_no_pro
) THEN

SELECT "This payment has already been recorded." AS msg;

ELSEIF payment_date_pro<loan_date_value THEN

SELECT "Payment date cannot be earlier than the loan date." AS msg;

ELSEIF payment_date_pro>CURDATE() THEN

SELECT "Payment date cannot be in the future." AS msg;

ELSEIF payment_date_pro>due_date_value THEN

SELECT "Payment date cannot be later than the loan due date." AS msg;

ELSEIF amount_pro>remaining_amount THEN

SELECT CONCAT("Payment cannot be greater than the remaining loan amount. Remaining amount: ",remaining_amount) AS msg;

ELSE

INSERT INTO loans_payment
VALUES(NULL,loan_no_pro,amount_pro,payment_date_pro,acc_no_pro);

UPDATE acounts
SET blance=blance+amount_pro
WHERE acc_no=acc_no_pro;

IF amount_pro=remaining_amount THEN
UPDATE loans
SET st_no=2
WHERE loan_no=loan_no_pro;
END IF;

SELECT "Loan payment recorded successfully." AS msg;

END IF;
END IF;

WHEN oper="update" THEN

IF NOT EXISTS(
SELECT * FROM loans_payment
WHERE loan_py=num
) THEN

SELECT "This payment does not exist." AS msg;

ELSEIF amount_pro<=0 THEN

SELECT "Payment amount must be greater than 0." AS msg;

ELSEIF payment_date_pro IS NULL THEN

SELECT "Payment date is required." AS msg;

ELSE

SELECT amount,acc_no
INTO old_amount,old_acc_no
FROM loans_payment
WHERE loan_py=num;

SELECT amount,loan_date,due_date
INTO loan_amount,loan_date_value,due_date_value
FROM loans
WHERE loan_no=loan_no_pro;

SELECT IFNULL(SUM(amount),0)-old_amount
INTO paid_amount
FROM loans_payment
WHERE loan_no=loan_no_pro;

SET remaining_amount=loan_amount-paid_amount;

IF payment_date_pro<loan_date_value THEN

SELECT "Payment date cannot be earlier than the loan date." AS msg;

ELSEIF payment_date_pro>CURDATE() THEN

SELECT "Payment date cannot be in the future." AS msg;

ELSEIF payment_date_pro>due_date_value THEN

SELECT "Payment date cannot be later than the loan due date." AS msg;

ELSEIF amount_pro>remaining_amount THEN

SELECT CONCAT("Payment cannot be greater than the remaining loan amount. Remaining amount: ",remaining_amount) AS msg;

ELSE

UPDATE acounts
SET blance=blance-old_amount
WHERE acc_no=old_acc_no;

UPDATE acounts
SET blance=blance+amount_pro
WHERE acc_no=acc_no_pro;

UPDATE loans_payment
SET loan_no=loan_no_pro,
amount=amount_pro,
pyment_date=payment_date_pro,
acc_no=acc_no_pro
WHERE loan_py=num;

IF amount_pro+paid_amount=loan_amount THEN
UPDATE loans
SET status="paid"
WHERE loan_no=loan_no_pro;
ELSE
UPDATE loans
SET status="unpaid"
WHERE loan_no=loan_no_pro;
END IF;

SELECT "Payment updated successfully." AS msg;

END IF;
END IF;

WHEN oper="delete" THEN

IF NOT EXISTS(
SELECT * FROM loans_payment
WHERE loan_py=num
) THEN

SELECT "This payment does not exist." AS msg;

ELSE

SELECT amount,acc_no
INTO old_amount,old_acc_no
FROM loans_payment
WHERE loan_py=num;

UPDATE acounts
SET blance=blance-old_amount
WHERE acc_no=old_acc_no;

DELETE FROM loans_payment
WHERE loan_py=num;

SELECT "Payment deleted successfully." AS msg;

END IF;

END CASE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `loans_pro` (IN `p_no_pro` INT, IN `acc_no_pro` INT, IN `amount_pro` DOUBLE, IN `loan_date_pro` DATE, IN `due_date_pro` DATE, IN `description_pro` TEXT, IN `status_pro` INT, IN `oper` VARCHAR(50), IN `num` INT)   BEGIN
DECLARE fee_pro double DEFAULT 0;
declare net_amount_pro double DEFAULT 0;
CASE
when oper="select" then
select * from loans;
when oper="insert" then
if amount_pro<=0 then
select "Loan amount must be greater than 0." as msg;
elseif due_date_pro<loan_date_pro then
select "Due date cannot be earlier than loan date." as msg;
elseif (select blance from acounts where acc_no=acc_no_pro)<amount_pro then
select "Insufficient balance in the company account." as msg;
elseif (select acc_type from acounts where acc_no=acc_no_pro)<>"company" then
select "Loans can only be issued from a company account." as msg;
ELSEIF EXISTS(select * from loans where p_no=p_no_pro and acc_no=acc_no_pro and 
              amount=amount_pro and loan_date=loan_date_pro and due_date=due_date_pro
              and description=description_pro and st_no=status_pro) THEN
              select "This Info Already Exists!" as msg;
ELSEIF amount_pro<10 THEN
select "The minimum amount allowed to send is $10" as masg;
else
set fee_pro=amount_pro*0.02;
set net_amount_pro=amount_pro-fee_pro;
insert into loans values(null,p_no_pro,acc_no_pro,amount_pro,fee_pro,net_amount_pro,loan_date_pro,due_date_pro,description_pro,status_pro);
update acounts set blance=blance-net_amount_pro where acc_no=acc_no_pro;
UPDATE acounts set blance=blance+fee_pro where acc_no=1;
select "Loan issued successfully." as msg;
end if;
when oper="update" then
update loans set p_no=p_no_pro,acc_no=acc_no_pro,amount=amount_pro,loan_date=loan_date_pro,due_date=due_date_pro,description=description_pro,st_no=status_pro where loan_no=num;
select "Loan updated successfully." as msg;
when oper="delete" then
delete from loans where loan_no=num;
select "Deleted successfully." as msg;
end case;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `loans_view` ()   BEGIN
select loan_no Loan_Id,p.name as Name,a.acc_name as Account,amount Amount,loan_date Loan_Date,due_date Due_Date,description,st.st_name as Status from people p,loans l,acounts a,status_loans st where p.p_no=l.p_no and a.acc_no=l.acc_no and st.st_no=l.st_no;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `people_pro` (IN `name_sp` VARCHAR(50), IN `tell_sp` VARCHAR(50), IN `sex_sp` ENUM('Male','Female'), IN `tow_no_sp` INT, IN `email_sp` VARCHAR(50), IN `oper` VARCHAR(50), IN `num` INT)   BEGIN
CASE

when oper="insert" then
if exists (select * from people where name=name_sp and tell=tell_sp and sex=sex_sp and tow_no=tow_no_sp and email=email_sp) THEN
select concat(name_sp,',',tell_sp,',',sex_sp,',',tow_no_sp,',',email_sp,' are already exists') as msg;
ELSE 
INSERT into people values(null,name_sp,tell_sp,sex_sp,tow_no_sp,email_sp);
select "inserted success" as msg;
end if;

when oper="update" then
if exists (select * from people where p_no=num) THEN
update people set name=name_sp,tell=tell_sp,sex=sex_sp,tow_no=tow_no_sp,email=email_sp where p_no=num;
select "Updated Success" as msg;
ELSE
select concat('This Id: ',num,' is not exist') as msg;
end if;

when oper="delete" then
if exists (select * from people where p_no=num) THEN
delete from people where p_no=num;
select "Deleted Success" as msg;
ELSE
select concat('This Id: ',num,' is not exist') as msg;
end if;
end case;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `people_report_all` ()   begin


select p_no as Id,name as Name,sex as Sex,town as Town,email as Email from towns t,people p where t.tow_no=p.tow_no order by p_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `people_report_sin` (IN `num` INT)   begin


select p_no as Id,name as Name,sex as Sex,town as Town,email as Email from towns t,people p where t.tow_no=p.tow_no and p_no=num order by p_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `people_view` ()   BEGIN

select p_no ID,name as Name,tell Tell,sex Sex,town Town,email Email from towns t,people p where t.tow_no=p.tow_no;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pyment_view` ()   BEGIN
SELECT loan_py Pyment_Id,p.name as Name,lp.amount Amount,pyment_date Py_Date,a.acc_name as Account from loans l,loans_payment lp,acounts a,people p where l.loan_no=lp.loan_no and a.acc_no=lp.acc_no and p.p_no=l.p_no;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receipt_pro` ()   begin
 
select s_no ID,p1.name Sender_Name,p2.name Receiver_Name,acc_name as Account,s.amount Amount,send_date Date,s.description Description,st_name as Status from people p1 join send_money s on p1.p_no=s.sender join people p2 on p2.p_no=s.reciver join status st on st.st_no=s.st_no join acounts ac on ac.acc_no=s.acc_no order by s_no desc LIMIT 1;

end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receive_money_pro` (IN `s_no_pro` INT, IN `amount_pro` DOUBLE, IN `rec_date_pro` DATE, IN `description_pro` TEXT, IN `oper` VARCHAR(40), IN `num` INT)   BEGIN
case

when oper="select" then
select * from receive_money;

when oper="insert" THEN
if exists (select * from receive_money where s_no=s_no_pro and amount=amount_pro and rec_date=rec_date_pro and description=description_pro) THEN
select "this Info Is Already Exists!" as msg;
ELSEIF amount_pro >
       (SELECT amount
        FROM send_money
        WHERE s_no=s_no_pro) THEN

    SELECT "Received amount can not be greater than sent amount!" AS msg;
ELSEIF amount_pro >
(
    SELECT a.blance
    FROM acounts a
    JOIN send_money s ON a.acc_no = s.acc_no
    WHERE s.s_no = s_no_pro
)
THEN

SELECT "the account blance is insufficient." AS msg;
ELSE
INSERT INTO receive_money (s_no, amount, rec_date, description)
VALUES (s_no_pro, amount_pro, rec_date_pro, description_pro);

update send_money
set st_no = 1
where s_no = s_no_pro;

UPDATE acounts a JOIN 
send_money s ON a.acc_no = s.acc_no 
SET a.blance = a.blance - amount_pro 
WHERE s.s_no = s_no_pro;

select "Received Successfully" as msg;
end if;

when oper="update" then
if exists (select * from receive_money where rc_no=num) THEN
update receive_money set s_no=s_no_pro,amount=amount_pro,rec_date=rec_date_pro,description=description_pro where rc_no=num;
select "updated success" as msg;
ELSE
select concat('This Id: ', num,' is Not Exist') as msg;
end if;

when oper="Delete" then
if exists (select * from receive_money where rc_no=num) THEN
Delete from receive_money where rc_no=num;
select "deleted success" as msg;
ELSE
select concat('This Id: ', num,' is Not Exist') as msg;
end if;

end case;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receive_money_report_all` ()   begin

select rc_no ID,p.name Reciver,r.amount Amount,r.rec_date Date,r.description Description from send_money s,receive_money r,people p where s.s_no=r.s_no and p.p_no=s.reciver order by rc_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receive_money_report_date` (IN `d1` DATE, IN `d2` DATE)   begin

select rc_no ID,p.name Reciever,r.amount Amount,r.rec_date Date,r.description Description from send_money s,receive_money r,people p where s.s_no=r.s_no and p.p_no=s.reciver and r.rec_date BETWEEN d1 and d2  order by rc_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receive_money_report_sin` (IN `num` INT)   begin

select rc_no ID,p.name Reciever,r.amount Amount,r.rec_date Date,r.description Description from send_money s,receive_money r,people p where s.s_no=r.s_no and p.p_no=s.reciver and rc_no=num;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `receive_money_view` ()   BEGIN

select rc_no ID,p.name Reciever,r.amount Amount,r.rec_date Date,r.description Description from send_money s,receive_money r,people p where s.s_no=r.s_no and p.p_no=s.reciver order by rc_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_money_proc` (IN `s_no_pro` INT, IN `amount_pro` DOUBLE, IN `rt_date_pro` DATE, IN `description_pro` TEXT, IN `oper` VARCHAR(50), IN `num` INT)   BEGIN
CASE
when oper="select" then
select * from return_money;

when oper="insert" then
if exists(select * from return_money where s_no=s_no_pro and amount=amount_pro and rt_date=rt_date_pro) THEN
select "this info is already exist" as msg;

ELSEIF amount_pro >
       (SELECT amount
        FROM send_money
        WHERE s_no=s_no_pro) THEN

    SELECT "Returned amount can not be greater than sent amount!" AS msg;
ELSEIF amount_pro >
(
    SELECT a.blance
    FROM acounts a
    JOIN send_money s ON a.acc_no = s.acc_no
    WHERE s.s_no = s_no_pro
)
THEN

SELECT "This Account Blance is insufficient" AS msg;

ELSE
insert into return_money values(null,s_no_pro,amount_pro,rt_date_pro,description_pro);

update send_money
set st_no = 3
where s_no = s_no_pro;

UPDATE acounts a JOIN send_money s 
ON a.acc_no = s.acc_no SET 
a.blance = a.blance - amount_pro WHERE 
s.s_no = s_no_pro;

select "Returned successfully" as msg;
end if;

when oper="update" then
if exists(select * from return_money where rm_no=num) THEN
update return_money set s_no=s_no_pro,amount=amount_pro,rt_date=rt_date_pro where rm_no=num;
select "updated success" as msg;
ELSE
select "this rm_no is not exist" as msg;
end if;

when oper="delete" then
if exists(select * from return_money where rm_no=num) THEN
delete from return_money where rm_no=num;
select "deleted success" as msg;
ELSE
select "this rm_no is not exist" as msg;
end if;
end case;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_money_report_all` ()   BEGIN


select rm_no as ID,p.name as Sender,r.amount as Amount,rt_date as Date,r.description as Description from send_money s,return_money r,people p where s.s_no=r.s_no and p.p_no=s.sender order by rm_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_money_report_date` (IN `d1` DATE, IN `d2` DATE)   BEGIN


select rm_no as ID,p.name as Sender,r.amount as Amount,rt_date as Date,r.description as Description from send_money s,return_money r,people p where s.s_no=r.s_no and p.p_no=s.sender and rt_date BETWEEN d1 and d2 order by rm_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_money_report_sin` (IN `num` INT)   BEGIN


select rm_no as ID,p.name as Sender,r.amount as Amount,rt_date as Date,r.description as Description from send_money s,return_money r,people p where s.s_no=r.s_no and rm_no=num and p.p_no=s.sender order by rm_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `return_money_view` ()   BEGIN

select rm_no ID,p.name Send_No,r.amount Amount,rt_date Date,r.description Description from send_money s,return_money r,people p where s.s_no=r.s_no and p.p_no=s.sender  order by rm_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_money_pro` (IN `sender_pro` INT, IN `reciver_pro` INT, IN `acc_no_pro` INT, IN `amount_pro` DOUBLE, IN `send_date_pro` DATE, IN `description_pro` TEXT, IN `oper` VARCHAR(40), IN `num` INT)   BEGIN
declare fee_pro double default 0;
declare net_amount_pro double default 0;
CASE

when oper="select" then
select * from send_money;

when oper="insert" then
if exists(select * from send_money where sender=sender_pro and reciver=reciver_pro and acc_no=acc_no_pro and amount=amount_pro and send_date=send_date_pro and description=description_pro   ) THEN
select "this info is alraedy exist" as msg;
elseif amount_pro<10 THEN
select "Transaction amount can not be less than $10" as msg;

ELSE
set fee_pro=amount_pro*0.02;
set net_amount_pro=amount_pro - fee_pro;
insert into send_money values(null,sender_pro,reciver_pro,acc_no_pro,amount_pro,fee_pro,net_amount_pro,send_date_pro,description_pro,(SELECT st_no FROM status WHERE st_name = 'Bending'));

update acounts
set blance = blance + (amount_pro-fee_pro)
where acc_no = acc_no_pro;
select "Sent successfully" as msg;

update acounts
set blance=blance + fee_pro 
where acc_no=1;
end if;

when oper="update" then
if exists(select * from send_money where s_no=num) THEN
update send_money set sender=sender_pro,reciver=reciver_pro,acc_no=acc_no_pro,amount=amount_pro,send_date=send_date_pro,description=description_pro where s_no=num;
select "updated success" as msg;
ELSE
select "this s_no is not exist" as mag;
end if;

when oper="delete" then
if exists(select * from send_money where s_no=num and st_no=(select st_no from status where st_name='Bending')) THEN
delete from send_money where s_no=num;
select "deleted success" as msg;
ELSEIF EXISTS(select * from send_money where s_no=num) then
select "This Transaction Has already Taken or Returned" as msg;
ELSE
select "this s_no is not exists" as mag;
end if;



end case;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_money_report_all` ()   BEGIN


select s_no ID,p1.name Sender_Name,p2.name Receiver_Name,acc_name as Account,s.amount Amount,send_date Date,s.description Description,st_name as Status from people p1 join send_money s on p1.p_no=s.sender join people p2 on p2.p_no=s.reciver join status st on st.st_no=s.st_no join acounts ac on ac.acc_no=s.acc_no order by s_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_money_report_date` (IN `d1` DATE, IN `d2` DATE)   BEGIN


select s_no ID,p1.name Sender_Name,p2.name Receiver_Name,s.amount Amount,send_date Date,s.description Description,st_name as Status from people p1 join send_money s on p1.p_no=s.sender join people p2 on p2.p_no=s.reciver join status st on st.st_no=s.st_no where send_date BETWEEN d1 and d2 order by s_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_money_report_sin` (IN `num` INT)   BEGIN


select s_no ID,p1.name Sender_Name,p2.name Receiver_Name,acc_name as Account,s.amount Amount,send_date Date,s.description Description,st_name as Status from people p1 join send_money s on p1.p_no=s.sender join people p2 on p2.p_no=s.reciver join status st on st.st_no=s.st_no  join acounts ac on ac.acc_no=s.acc_no where s_no=num order by s_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_money_view` ()   begin

select s_no,p1.name as sender_Name,p2.name as reciver_Name,amount as Amount,fee Fee,net_amount Net_amount,send_date Date,description Description,st_name as Status from send_money s join people p1 on p1.p_no=s.sender join people p2 on p2.p_no=s.reciver join status st on st.st_no=s.st_no order by s_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `status_pro` (IN `st_name_pro` VARCHAR(30), IN `oper` VARCHAR(30), IN `num` INT)   BEGIN
CASE
when oper="select" THEN
select * from status;

when oper="insert" then
insert into status values(null,st_name_pro);
SELECT "inserted success" as msg;


when oper="update" then
if EXISTS(select * from status where st_no=num) THEN
update status SET st_name=st_name_pro where st_no=num;
SELECT "updates success" as msg;
ELSE
select concat('This id:', num,' is not exist')  as msg;
end if;

when oper="delete" then
if EXISTS(select * from status where st_no=num) THEN
delete from status where st_no=num;
SELECT "deleted success" as msg;
ELSE
select concat('This id:', num,' is not exist')  as msg;
end if;
end case;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `status_view` ()   BEGIN

select st_no ID,st_name Staus_Type from status order by st_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `towns_pro` (IN `town_pro` VARCHAR(30), IN `con_no_pro` INT, IN `oper` VARCHAR(30), IN `num` INT)   BEGIN
CASE
when oper="select" then
select * from towns;

when oper="insert" then
if EXISTS(select * from towns where town=town_pro and con_no=con_no_pro)THEN
select "this info is already exists" as msg;
ELSE
insert into towns VALUES(null,town_pro,con_no_pro);
select "inserted success" as msg;
end if;

when oper="update" then
if exists(select * from towns where tow_no=num) THEN
update towns set town=town_pro,con_no=con_no_pro where tow_no=num;
select "updated success" as msg;
else 
select concat('This Id:', num, 'is Not exist') as msg;
end if;

when oper="delete" then
if exists(select * from towns where tow_no=num) THEN
if exists(select * from towns t where t.con_no=num) then
select "this Data is Related To Other data" as msg;
else
delete from towns where tow_no=num;
end if;
select "deleted success" as msg;
else 
select concat('This Id:', num, 'is Not exist') as msg;
end if;
end case;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `towns_report_all` ()   BEGIN

select tow_no as ID,town as Town,con_name Country from countries c,towns t where c.con_no=t.con_no order by tow_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `towns_report_sin` (IN `num` INT)   BEGIN

select tow_no as ID,town as Town,con_name Country from countries c,towns t where c.con_no=t.con_no and tow_no=num order by tow_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `towns_view` ()   BEGIN

select tow_no ID,town Town,con_name as country from countries c,towns t where c.con_no=t.con_no order by tow_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `TRANSACTION_times` (IN `num` INT)   BEGIN
SELECT
    s.s_no,
    p1.name AS Sender,
    p2.name AS Receiver,
    a.institution,
    s.amount,
    s.send_date,
    st.st_name,
    s.description
FROM send_money s
INNER JOIN people p1
    ON s.sender = p1.p_no
INNER JOIN people p2
    ON s.reciver = p2.p_no
INNER JOIN acounts a
    ON s.acc_no = a.acc_no
INNER JOIN status st
    ON s.st_no = st.st_no
WHERE s.sender =num;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `users_pro` (IN `user_name_pro` VARCHAR(30), IN `Password_pro` INT, IN `user_type_pro` VARCHAR(30), IN `p_no_pro` INT, IN `oper` VARCHAR(30), IN `num` INT)   BEGIN
CASE
when oper="select" then
select * from users;

when oper="insert" then
if EXISTS(select * from users where user_name=user_name_pro and Password=Password_pro and user_type=user_type_pro and p_no=p_no_pro)THEN
select "this info is already exists" as msg;
ELSE
insert into users VALUES(null,user_name_pro,Password_pro,user_type_pro,p_no_pro);
select "inserted success" as msg;
end if;

when oper="update" then
if exists(select * from users where user_no=num) THEN
update users set user_name=user_name_pro,Password=Password_pro,user_type=user_type_pro,p_no=p_no_pro where user_no=num;
select "updated success" as msg;
else 
select concat('This Id:', num, 'is Not exist') as msg;
end if;

when oper="delete" then
if exists(select * from users where user_no=num) THEN
delete from users where user_no=num;
select "deleted success" as msg;
else 
select concat('This Id:', num, 'is Not exist') as msg;
end if;
end case;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `users_report_all` ()   BEGIN

select user_no as ID,user_name as User_Name,Password,user_type as Type,name as Full_Name from people p,users u where p.p_no=u.p_no order by user_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `users_report_sin` (IN `num` INT)   BEGIN

select user_no as ID,user_name as User_Name,Password,user_type as Type,name as Full_Name from people p,users u where p.p_no=u.p_no and user_no=num order by user_no asc;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `users_view` ()   begin

select user_no ID,user_name User_Name,Password ,user_type, name as Full_Name from people p,users u where p.p_no=u.p_no order by user_no asc;
end$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `getBlance` (`num` INT) RETURNS DOUBLE  begin
SELECT sum(amount) into @Total  from people p,loans l,status_loans st where p.p_no=l.p_no and st.st_no=l.st_no and p.p_no=num;
select sum(lp.amount) into @paid from people p,loans l,loans_payment lp,acounts a where l.loan_no=lp.loan_no and p.p_no=l.p_no and a.acc_no=lp.acc_no and p.p_no=num;
set @bal=ifnull(@total,0)-ifnull(@paid,0);
return @bal;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `acounts`
--

CREATE TABLE `acounts` (
  `acc_no` int(11) NOT NULL,
  `acc_name` varchar(30) DEFAULT NULL,
  `acc_type` enum('company','customer') NOT NULL,
  `institution` text DEFAULT NULL,
  `blance` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `acounts`
--

INSERT INTO `acounts` (`acc_no`, `acc_name`, `acc_type`, `institution`, `blance`) VALUES
(1, 'ACC0002', 'company', 'eDahab', 863),
(2, 'ACC0002', 'company', 'jeeb', 53),
(4, 'ACC0003', 'customer', 'zaad plus', 1790),
(5, 'ACC0005', 'customer', 'EVC_PLUS', 98),
(6, 'ACC0006', 'customer', 'eJEEP', 0),
(7, 'ACC0007', 'customer', 'zaad plus', 0),
(8, 'ACC0987', 'customer', 'eDahab', 0);

-- --------------------------------------------------------

--
-- Table structure for table `countries`
--

CREATE TABLE `countries` (
  `con_no` int(11) NOT NULL,
  `con_name` varchar(50) NOT NULL,
  `zip_code` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `countries`
--

INSERT INTO `countries` (`con_no`, `con_name`, `zip_code`) VALUES
(8, 'algeria', '16000'),
(12, 'canada', 'K1A 0B1'),
(14, 'china', '100000'),
(20, 'cupa', '456k5'),
(10, 'Djibouti', '00000'),
(9, 'egypt', '11511'),
(17, 'ethopia', 'K1234'),
(13, 'france', '75001'),
(18, 'Japan', '543A'),
(7, 'kenya', '00100'),
(2, 'Saudi Arabia', '11564'),
(21, 'somalia', '+252'),
(1, 'somalia', '252'),
(23, 'Somaliland', 'som18'),
(19, 'uganda', '3453R'),
(11, 'united states', '10001'),
(24, 'USA', '+1');

-- --------------------------------------------------------

--
-- Table structure for table `loans`
--

CREATE TABLE `loans` (
  `loan_no` int(11) NOT NULL,
  `p_no` int(11) NOT NULL,
  `acc_no` int(11) NOT NULL,
  `amount` double NOT NULL,
  `loan_fee` double NOT NULL,
  `net_amount` double NOT NULL,
  `loan_date` date NOT NULL,
  `due_date` date NOT NULL,
  `description` text DEFAULT NULL,
  `st_no` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `loans`
--

INSERT INTO `loans` (`loan_no`, `p_no`, `acc_no`, `amount`, `loan_fee`, `net_amount`, `loan_date`, `due_date`, `description`, `st_no`) VALUES
(1, 1, 1, 200, 0, 0, '2026-07-02', '2026-07-10', 'pills', 2),
(2, 1, 1, 100, 0, 0, '2026-07-02', '2026-07-10', 'pills', 1),
(3, 2, 1, 500, 0, 0, '2026-08-01', '2026-08-10', 'home cash', 1),
(4, 3, 1, 100, 0, 0, '2026-08-23', '2026-08-23', 'bills', 1),
(5, 15, 2, 100, 0, 0, '2026-08-23', '2026-08-23', 'blls', 2),
(6, 3, 2, 100, 2, 98, '2026-08-01', '2026-08-31', 'home cash', 1),
(7, 2, 2, 50, 1, 49, '2026-08-02', '2026-08-31', 'pills', 1);

-- --------------------------------------------------------

--
-- Table structure for table `loans_payment`
--

CREATE TABLE `loans_payment` (
  `loan_py` int(11) NOT NULL,
  `loan_no` int(11) NOT NULL,
  `amount` double NOT NULL,
  `pyment_date` date NOT NULL,
  `acc_no` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `loans_payment`
--

INSERT INTO `loans_payment` (`loan_py`, `loan_no`, `amount`, `pyment_date`, `acc_no`) VALUES
(2, 3, 500, '2026-08-10', 1),
(3, 4, 50, '2026-08-23', 1),
(4, 5, 100, '2026-08-23', 2),
(5, 1, 100, '2026-07-10', 2);

-- --------------------------------------------------------

--
-- Table structure for table `people`
--

CREATE TABLE `people` (
  `p_no` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `tell` varchar(50) NOT NULL,
  `sex` enum('male','female') NOT NULL,
  `tow_no` int(11) NOT NULL,
  `email` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `people`
--

INSERT INTO `people` (`p_no`, `name`, `tell`, `sex`, `tow_no`, `email`) VALUES
(1, 'abdirahim abdi', '613094734', 'male', 1, 'abdi2550@gmail.com'),
(2, 'husein abdi', '610482528', 'male', 2, 'mahadmahad2550@gmail.com'),
(3, 'hassan farah', '615455434', 'male', 3, 'hass677@gmail.com'),
(4, 'sheikh hassan', '613433212', 'male', 1, 'hasa12@gmal.com'),
(5, 'fariido abdi', '3455678', 'female', 5, 'farido432@gmail.com'),
(6, 'daahir moha', '5654534', 'male', 6, 'dahir342@gmail.com'),
(7, 'ali abdi', '6765645', 'male', 7, 'ali564@gmail.com'),
(8, 'gacal hassan  ', '2344567', 'male', 8, 'gaal765@gmail.com'),
(9, 'rahmo hassan', '4534232', 'female', 9, 'rahmo987@gmail.com'),
(10, 'yuusuf jimale', '4566787', 'male', 10, 'yousf098@gmail.com'),
(11, 'abdirahim abdi', '3094734', 'male', 1, 'abdi2550@gmail.com'),
(12, 'hassan isse', '345423', 'male', 2, 'hasan342@gmail.com'),
(13, 'ali yare', '3425343', 'male', 7, 'ali3452@gmail.com'),
(14, 'sheikh hassan', '613433212', 'male', 1, 'hasa12@gmal.com'),
(15, 'abdirahim axmed', '6134243242', 'male', 1, 'abdi2550@gmail.com'),
(20, 'abdirahiim daahir fiigsane', '613643721', 'male', 15, 'abdi@gmail.com'),
(21, 'maido abdi yusuf', '616962142', 'female', 3, 'maidoabdi@gmail.com'),
(22, 'cabdiwali cali xasan', '51232321', 'male', 12, 'cabdixasan@Gmail.com'),
(23, 'xiinak', '52452121', 'male', 3, 'xiinka@gmail.com');

-- --------------------------------------------------------

--
-- Stand-in structure for view `receipt_view`
-- (See below for the actual view)
--
CREATE TABLE `receipt_view` (
`s_no` int(11)
,`sender` varchar(50)
,`reciver` varchar(50)
,`acc_name` varchar(30)
,`institution` text
,`amount` double
,`Tarikh` date
,`st_name` varchar(50)
);

-- --------------------------------------------------------

--
-- Table structure for table `receive_money`
--

CREATE TABLE `receive_money` (
  `rc_no` int(11) NOT NULL,
  `s_no` int(11) NOT NULL,
  `amount` double NOT NULL,
  `rec_date` date NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `receive_money`
--

INSERT INTO `receive_money` (`rc_no`, `s_no`, `amount`, `rec_date`, `description`) VALUES
(1, 1, 300, '2026-01-20', 'pills'),
(2, 2, 400, '2026-01-20', ' '),
(3, 3, 200, '2026-02-20', ' '),
(4, 4, 290, '2026-02-20', ' '),
(5, 5, 300, '2026-01-21', ' '),
(6, 6, 100, '2025-01-20', ' '),
(7, 9, 400, '2026-02-20', ' '),
(9, 8, 400, '2026-03-20', ' '),
(10, 7, 900, '2026-01-10', ' '),
(27, 22, 200, '2026-02-23', 'pills'),
(29, 26, 290, '2026-06-02', ''),
(30, 27, 500, '2025-09-10', 'home cash'),
(33, 11, 200, '2026-01-20', ''),
(35, 30, 200, '2026-02-03', 'pills'),
(38, 34, 300, '2026-06-21', ''),
(39, 35, 100, '2026-06-21', ''),
(40, 38, 90, '2026-06-21', ''),
(41, 37, 30, '2026-06-21', ''),
(42, 39, 100, '2026-06-22', 'bills'),
(43, 40, 200, '2026-06-22', ''),
(44, 45, 300, '2026-01-05', 'pills'),
(45, 46, 100, '2026-01-05', ''),
(46, 47, 200, '2025-09-10', ''),
(47, 51, 500, '2026-01-05', 'pills'),
(48, 53, 100, '2026-07-01', 'bills'),
(49, 54, 100, '2026-07-01', ''),
(50, 57, 500, '2026-01-05', 'home cash');

-- --------------------------------------------------------

--
-- Table structure for table `return_money`
--

CREATE TABLE `return_money` (
  `rm_no` int(11) NOT NULL,
  `s_no` int(11) NOT NULL,
  `amount` double NOT NULL,
  `rt_date` date NOT NULL,
  `description` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `return_money`
--

INSERT INTO `return_money` (`rm_no`, `s_no`, `amount`, `rt_date`, `description`) VALUES
(1, 1, 250, '2026-01-23', ''),
(2, 2, 300, '2026-02-23', ''),
(3, 3, 150, '2025-09-29', ''),
(4, 4, 250, '2026-05-19', ''),
(5, 5, 290, '2023-12-26', ''),
(6, 6, 300, '2025-04-24', ''),
(7, 7, 50, '2026-01-09', ''),
(8, 8, 250, '2026-09-08', ''),
(9, 9, 390, '2026-02-23', ''),
(14, 23, 300, '2026-03-20', 'pills'),
(16, 28, 700, '2026-01-20', ''),
(23, 32, 500, '2026-01-23', ''),
(26, 33, 200, '2026-06-21', ''),
(27, 36, 100, '2026-06-21', ''),
(28, 37, 30, '2026-06-21', ''),
(29, 38, 90, '2026-06-21', ''),
(30, 39, 100, '2026-06-22', 'bills'),
(31, 43, 100, '2026-06-27', 'bill'),
(32, 46, 100, '2026-03-20', ''),
(33, 47, 100, '2026-01-23', '');

-- --------------------------------------------------------

--
-- Table structure for table `send_money`
--

CREATE TABLE `send_money` (
  `s_no` int(11) NOT NULL,
  `sender` int(11) NOT NULL,
  `reciver` int(11) NOT NULL,
  `acc_no` int(11) NOT NULL,
  `amount` double NOT NULL,
  `fee` double NOT NULL,
  `net_amount` double DEFAULT NULL,
  `send_date` date NOT NULL,
  `description` text DEFAULT NULL,
  `st_no` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `send_money`
--

INSERT INTO `send_money` (`s_no`, `sender`, `reciver`, `acc_no`, `amount`, `fee`, `net_amount`, `send_date`, `description`, `st_no`) VALUES
(1, 1, 6, 1, 1, 0, 0, '2026-02-20', ' home bill', 1),
(2, 3, 4, 1, 150, 0, 0, '2026-02-10', ' school bill', 3),
(3, 5, 6, 1, 300, 0, 0, '2026-01-10', ' liabilitty bill', 3),
(4, 7, 8, 1, 150, 0, 0, '2026-02-11', ' private money', 3),
(5, 9, 10, 1, 400, 0, 0, '2026-01-09', ' internet bill', 2),
(6, 3, 4, 1, 150, 0, 0, '2026-02-06', ' Employee bill', 2),
(7, 3, 4, 1, 150, 0, 0, '2026-02-06', ' ', 2),
(8, 5, 4, 1, 150, 0, 0, '2025-02-06', ' ', 3),
(9, 4, 5, 1, 450, 0, 0, '2024-10-23', '', 3),
(11, 4, 5, 1, 500, 0, 0, '2023-03-12', 'charity', 1),
(22, 4, 2, 1, 200, 0, 0, '2026-02-20', 'pills', 1),
(23, 7, 6, 1, 300, 0, 0, '2026-02-20', 'pills', 3),
(26, 20, 10, 1, 290, 0, 0, '2026-06-02', '', 4),
(27, 4, 6, 1, 500, 0, 0, '2026-02-20', 'home cash', 1),
(28, 5, 6, 1, 700, 0, 0, '2026-06-04', '', 3),
(29, 1, 3, 1, 350, 0, 0, '2026-06-10', '', 4),
(30, 7, 1, 1, 300, 0, 0, '2026-06-04', 'bill', 1),
(32, 5, 1, 1, 200, 0, 0, '2026-06-21', '', 3),
(33, 6, 2, 1, 190, 0, 0, '2026-06-21', '', 3),
(34, 1, 4, 1, 300, 0, 0, '2026-06-21', '', 1),
(35, 3, 4, 1, 100, 0, 0, '2026-06-21', '', 1),
(36, 5, 6, 1, 100, 0, 0, '2026-06-21', '', 3),
(37, 1, 20, 1, 30, 0, 0, '2026-06-21', '', 1),
(38, 2, 6, 1, 90, 0, 0, '2026-06-21', '', 3),
(39, 3, 4, 1, 100, 0, 0, '2026-06-22', 'bills', 3),
(40, 6, 7, 1, 200, 0, 0, '2026-06-22', '', 1),
(41, 1, 3, 1, 100, 0, 0, '2026-06-22', '', 4),
(42, 4, 2, 1, 500, 0, 0, '2026-02-20', 'pills', 4),
(43, 3, 5, 1, 200, 0, 0, '2026-06-27', 'bill', 3),
(44, 4, 7, 1, 200, 0, 0, '2024-07-23', 'pills', 4),
(45, 1, 2, 1, 500, 0, 0, '2026-02-20', 'pills', 1),
(46, 5, 2, 2, 200, 0, 0, '2026-02-20', '', 3),
(47, 5, 2, 2, 200, 0, 0, '2026-02-20', '', 3),
(51, 5, 2, 4, 500, 0, 0, '2026-02-20', 'pills', 1),
(52, 1, 2, 2, 200, 0, 0, '2026-06-30', '', 4),
(53, 1, 3, 5, 100, 0, 0, '2026-07-01', 'bill', 1),
(54, 1, 2, 6, 100, 0, 0, '2026-07-01', 'pill', 1),
(56, 5, 6, 1, 250, 0, 0, '2026-03-20', 'pills', 4),
(57, 5, 6, 4, 500, 0, 0, '2026-02-20', 'home cash', 1),
(58, 3, 1, 1, 90, 0, 0, '2026-07-02', '', 4),
(59, 5, 1, 4, 300, 0, 0, '2026-07-15', '', 4),
(60, 23, 10, 2, 100, 0, 0, '2026-06-22', 'bills', 4),
(61, 2, 3, 4, 1000, 0, 0, '2026-07-22', '', 4),
(62, 4, 2, 4, 500, 10, 510, '2026-02-20', 'pills', 4),
(63, 4, 2, 5, 100, 2, 98, '2024-07-23', 'home cash', 4);

-- --------------------------------------------------------

--
-- Table structure for table `status`
--

CREATE TABLE `status` (
  `st_no` int(11) NOT NULL,
  `st_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `status`
--

INSERT INTO `status` (`st_no`, `st_name`) VALUES
(4, 'Bending'),
(2, 'Partial'),
(3, 'Return'),
(1, 'Taken');

-- --------------------------------------------------------

--
-- Table structure for table `status_loans`
--

CREATE TABLE `status_loans` (
  `st_no` int(11) NOT NULL,
  `st_name` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `status_loans`
--

INSERT INTO `status_loans` (`st_no`, `st_name`) VALUES
(1, 'unpaid'),
(2, 'paid');

-- --------------------------------------------------------

--
-- Table structure for table `towns`
--

CREATE TABLE `towns` (
  `tow_no` int(11) NOT NULL,
  `town` varchar(50) NOT NULL,
  `con_no` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `towns`
--

INSERT INTO `towns` (`tow_no`, `town`, `con_no`) VALUES
(1, 'baldge', 7),
(2, 'riyad', 2),
(3, 'nairobi', 7),
(4, 'algeris', 8),
(5, 'qahira', 9),
(6, 'Ali sabieh', 10),
(7, 'new york', 11),
(8, 'troneo', 12),
(9, 'paris', 13),
(10, 'shanghi', 14),
(12, 'kismaayo', 1),
(14, 'Badioa', 1),
(15, 'cadaado', 1),
(16, 'hargaysa', 23),
(17, 'los angles', 24);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_no` int(11) NOT NULL,
  `user_name` varchar(50) NOT NULL,
  `Password` varchar(50) DEFAULT NULL,
  `user_type` varchar(50) NOT NULL,
  `p_no` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_no`, `user_name`, `Password`, `user_type`, `p_no`) VALUES
(2, 'husein', '525252', 'admin', 2),
(3, 'hassan', '2343', 'user', 3),
(4, 'jamilo', '2312', 'user', 4),
(5, 'farido', '7898', 'user', 5),
(6, 'dahir', '3245', 'user', 6),
(7, 'ali abdi', '8765', 'user', 7),
(8, 'gacal', '4235', 'user', 8),
(9, 'rahmo', '5678', 'admin', 9),
(10, 'yousuf', '5432', 'admin', 10),
(13, 'hassan', '78654', 'admin', 14),
(14, 'ali ade', '1111', 'admin', 13);

-- --------------------------------------------------------

--
-- Structure for view `receipt_view`
--
DROP TABLE IF EXISTS `receipt_view`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `receipt_view`  AS SELECT `s`.`s_no` AS `s_no`, `p1`.`name` AS `sender`, `p2`.`name` AS `reciver`, `a`.`acc_name` AS `acc_name`, `a`.`institution` AS `institution`, `s`.`amount` AS `amount`, `s`.`send_date` AS `Tarikh`, `st`.`st_name` AS `st_name` FROM ((((`send_money` `s` left join `people` `p1` on(`p1`.`p_no` = `s`.`sender`)) left join `people` `p2` on(`p2`.`p_no` = `s`.`reciver`)) left join `acounts` `a` on(`a`.`acc_no` = `s`.`acc_no`)) left join `status` `st` on(`st`.`st_no` = `s`.`st_no`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `acounts`
--
ALTER TABLE `acounts`
  ADD PRIMARY KEY (`acc_no`),
  ADD KEY `const_fk_acc` (`acc_name`);

--
-- Indexes for table `countries`
--
ALTER TABLE `countries`
  ADD PRIMARY KEY (`con_no`),
  ADD KEY `index_coun` (`con_name`,`zip_code`);

--
-- Indexes for table `loans`
--
ALTER TABLE `loans`
  ADD PRIMARY KEY (`loan_no`),
  ADD KEY `con_fk1_loa` (`p_no`),
  ADD KEY `con_fk2_loa` (`acc_no`),
  ADD KEY `const_fk_loa` (`st_no`);

--
-- Indexes for table `loans_payment`
--
ALTER TABLE `loans_payment`
  ADD PRIMARY KEY (`loan_py`),
  ADD KEY `con_fk1_lop` (`acc_no`),
  ADD KEY `con_fk2_lop` (`loan_no`);

--
-- Indexes for table `people`
--
ALTER TABLE `people`
  ADD PRIMARY KEY (`p_no`),
  ADD KEY `index_peop` (`name`,`tell`,`email`),
  ADD KEY `cons_fk_peop` (`tow_no`);

--
-- Indexes for table `receive_money`
--
ALTER TABLE `receive_money`
  ADD PRIMARY KEY (`rc_no`),
  ADD KEY `const_fk_rece` (`s_no`);

--
-- Indexes for table `return_money`
--
ALTER TABLE `return_money`
  ADD PRIMARY KEY (`rm_no`),
  ADD KEY `const_fk_retu` (`s_no`);

--
-- Indexes for table `send_money`
--
ALTER TABLE `send_money`
  ADD PRIMARY KEY (`s_no`),
  ADD KEY `const_fk1_send` (`sender`),
  ADD KEY `const_fk2_send` (`reciver`),
  ADD KEY `const_fk3_send` (`st_no`),
  ADD KEY `const_fk1` (`acc_no`);

--
-- Indexes for table `status`
--
ALTER TABLE `status`
  ADD PRIMARY KEY (`st_no`),
  ADD KEY `index_stat` (`st_name`);

--
-- Indexes for table `status_loans`
--
ALTER TABLE `status_loans`
  ADD PRIMARY KEY (`st_no`);

--
-- Indexes for table `towns`
--
ALTER TABLE `towns`
  ADD PRIMARY KEY (`tow_no`),
  ADD KEY `index_town` (`town`),
  ADD KEY `const_fk_town` (`con_no`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_no`),
  ADD KEY `const_fk_user` (`p_no`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `acounts`
--
ALTER TABLE `acounts`
  MODIFY `acc_no` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `countries`
--
ALTER TABLE `countries`
  MODIFY `con_no` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `loans`
--
ALTER TABLE `loans`
  MODIFY `loan_no` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `loans_payment`
--
ALTER TABLE `loans_payment`
  MODIFY `loan_py` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `people`
--
ALTER TABLE `people`
  MODIFY `p_no` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `receive_money`
--
ALTER TABLE `receive_money`
  MODIFY `rc_no` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `return_money`
--
ALTER TABLE `return_money`
  MODIFY `rm_no` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT for table `send_money`
--
ALTER TABLE `send_money`
  MODIFY `s_no` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `status`
--
ALTER TABLE `status`
  MODIFY `st_no` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `status_loans`
--
ALTER TABLE `status_loans`
  MODIFY `st_no` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `towns`
--
ALTER TABLE `towns`
  MODIFY `tow_no` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `user_no` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `loans`
--
ALTER TABLE `loans`
  ADD CONSTRAINT `con_fk1_loa` FOREIGN KEY (`p_no`) REFERENCES `people` (`p_no`),
  ADD CONSTRAINT `con_fk2_loa` FOREIGN KEY (`acc_no`) REFERENCES `acounts` (`acc_no`),
  ADD CONSTRAINT `const_fk_loa` FOREIGN KEY (`st_no`) REFERENCES `status_loans` (`st_no`);

--
-- Constraints for table `loans_payment`
--
ALTER TABLE `loans_payment`
  ADD CONSTRAINT `con_fk1_lop` FOREIGN KEY (`acc_no`) REFERENCES `acounts` (`acc_no`),
  ADD CONSTRAINT `con_fk2_lop` FOREIGN KEY (`loan_no`) REFERENCES `loans` (`loan_no`);

--
-- Constraints for table `people`
--
ALTER TABLE `people`
  ADD CONSTRAINT `cons_fk_peop` FOREIGN KEY (`tow_no`) REFERENCES `towns` (`tow_no`);

--
-- Constraints for table `receive_money`
--
ALTER TABLE `receive_money`
  ADD CONSTRAINT `const_fk_rece` FOREIGN KEY (`s_no`) REFERENCES `send_money` (`s_no`);

--
-- Constraints for table `return_money`
--
ALTER TABLE `return_money`
  ADD CONSTRAINT `const_fk_retu` FOREIGN KEY (`s_no`) REFERENCES `send_money` (`s_no`);

--
-- Constraints for table `send_money`
--
ALTER TABLE `send_money`
  ADD CONSTRAINT `const_fk1` FOREIGN KEY (`acc_no`) REFERENCES `acounts` (`acc_no`),
  ADD CONSTRAINT `const_fk1_send` FOREIGN KEY (`sender`) REFERENCES `people` (`p_no`),
  ADD CONSTRAINT `const_fk2_send` FOREIGN KEY (`reciver`) REFERENCES `people` (`p_no`),
  ADD CONSTRAINT `const_fk3_send` FOREIGN KEY (`st_no`) REFERENCES `status` (`st_no`);

--
-- Constraints for table `towns`
--
ALTER TABLE `towns`
  ADD CONSTRAINT `const_fk_town` FOREIGN KEY (`con_no`) REFERENCES `countries` (`con_no`);

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `const_fk_user` FOREIGN KEY (`p_no`) REFERENCES `people` (`p_no`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
