drop table Views;
drop table Users;
drop table Content;



/*Q1*/
/**Creating Tables**/

create table Users
(
    name varchar2(1),
country varchar2(15)  check(country='Italy' OR country='Spain' OR country='Portugal' OR country='Korea' OR country='Singapore' OR country='UK' OR country='Belgium' OR country = 'China' OR country = 'Taiwan'),
    year number(4),
    userlimit number(2)NOT NULL,
  price number(2) NOT NULL,
    views number(2) default 0,
  primary key(name,country,year)

   
);


create table Content
(
    cname varchar2(50),
  type varchar2(50),
    episodes number(3),
country varchar2(15)  check(country='Italy' OR country='Spain' OR country='Portugal' OR country='Korea' OR country='Singapore' OR country='UK' OR country='Belgium' OR country = 'China' OR country = 'Taiwan'),
    language varchar2(15),
    releasedate DATE,

    PRIMARY key(cname,type)
);

create table Views
(
    name varchar2(1),
country varchar2(15) check(country='Italy' OR country='Spain' OR country='Portugal' OR country='Korea' OR country='Singapore' OR country='UK' OR country='Belgium' OR country = 'China' OR country = 'Taiwan'),
    year number (4),
    cname varchar2(1),
    type varchar2(15),
    viewdate DATE check(viewdate>= ('01/01/2020' ) ,
    FOREIGN KEY (name,country,year) REFERENCES Users(name,country, year),
    FOREIGN KEY (cname,type) REFERENCES Content(cname,type)

);

ALTER TABLE Views
ADD CONSTRAINT new_pk PRIMARY KEY (name, country, year, cname, type, viewdate);
/*Q2*/


CREATE OR REPLACE TRIGGER ViewTrigger
AFTER UPDATE ON Views
FOR EACH ROW
BEGIN
    UPDATE Users
    SET views = views + 1
    WHERE name = :NEW.name AND country = :NEW.country AND year = :NEW.year;
END;
/

/*Q3*/
/**Insert Data**/


INSERT INTO Users VALUES('X','Spain',2021,2,40,NULL);
INSERT INTO Users VALUES('Y','UK',2021,2,40,NULL);
INSERT INTO Users VALUES('Z','UK',2021,4,60,NULL);
INSERT INTO Users VALUES('X','Spain',2022,1,35,NULL);
INSERT INTO Users VALUES('Y','Italy',2022,1,35,NULL);
INSERT INTO Users VALUES('Z','UK',2022,1,35,NULL);
INSERT INTO Users VALUES('X','Portugal',2022,4,60,NULL);
INSERT INTO Users VALUES('Y','Belgium',2021,2,40,NULL);
INSERT INTO Users VALUES('Z','Portugal',2022,2,40,NULL);




INSERT INTO Content VALUES('A','film',1,'China','Mandarin', '3.10.2022');
INSERT INTO Content VALUES('B','film',1,'Taiwan','Cantonese','30.10.2022');
INSERT INTO Content VALUES('C','film',1,'Singapore','Malay','15.09.2022');
INSERT INTO Content VALUES('A','series',8,'Korea','Korean', '28.09.2022');
INSERT INTO Content VALUES('B','series',10,'China','Mandarin''3.10.2022');
INSERT INTO Content VALUES('C','series',18,'Korea','Korean',  '1.11.2022');
INSERT INTO Content VALUES('D','series',8,'Korea','Korean',  '16.09.2022');
INSERT INTO Content VALUES('D','documentary',3,'China','Mandarin',  '18.10.2022');
INSERT INTO Content VALUES('E','documentary',6,'Taiwan','Mandarin',  '17.10.2022');



INSERT INTO Views VALUES('X','Spain',2022,'A','film',  '4.10.2022');
INSERT INTO Views VALUES('X','Spain',2022,'A','film', '8.10.2022');
INSERT INTO Views VALUES('X','Spain',2022,'E','documentary','18.10.2022');
INSERT INTO Views VALUES('Y','Italy',2022,'B','series', '15.10.2022');
INSERT INTO Views VALUES('Y','Italy',2022,'B','series', '18.10.2022' );
INSERT INTO Views VALUES('Y','Italy',2022,'B','series','19.10.2022'  );
INSERT INTO Views VALUES('Z','Portugal',2022,'A','film', '6.10.2022'  );
INSERT INTO Views VALUES('Z','Portugal',2022,'C','series', '1.11.2022'  );
INSERT INTO Views VALUES('Z','Portugal',2022,'D','documentary', '30.10.2022');
INSERT INTO Views VALUES('X','Spain', 2022, 'C','series',  '2.11.2022'  );
INSERT INTO Views VALUES('X','Spain',2022,'C','series', '3.11.2022'  );
INSERT INTO Views VALUES('X','Spain',2022,'D','documentary', '29.10.2022'  );




/*Q4*/
/**Block with cursor**/

DECLARE 
 
    subscription_name varchar2(1); 
    subscription_country varchar2(15); 
    subscription_year number(4); 
    CURSOR subscription_cursor IS 
        SELECT cname, type, viewdate 
        FROM Views 
        WHERE name = subscription_name AND country = subscription_country AND year = subscription_year; 
    subscription_cname varchar2(1); 
    subscription_ctype varchar2(15); 
    subscription_cviewdate date; 
BEGIN 
    subscription_name :='&subscription_name';
    subscription_country :='&subscription_country';
    subscription_year :='&subscription_year';
    
    -- display report header 
    DBMS_OUTPUT.PUT_LINE('This report for name='||subscription_name||' , country='||subscription_country||' , year='||subscription_year||':'); 
    
    -- open cursor 
    OPEN subscription_cursor; 
    LOOP
        FETCH subscription_cursor INTO subscription_cname, subscription_ctype, subscription_cviewdate;
            EXIT WHEN subscription_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(subscription_cname || ' | ' || subscription_ctype || ' | ' || subscription_cviewdate); 
    END LOOP;
    CLOSE subscription_cursor; 
END Viewblock; 
/



/**Block with for**/

DECLARE
    subscription_name varchar2(1);
    subscription_country varchar2(15);
    subscription_year number(4);
BEGIN
    subscription_name :='&subscription_name';
    subscription_country :='&subscription_country';
    subscription_year :='&subscription_year';
   
    DBMS_OUTPUT.PUT_LINE('This report for name='||subscription_name||' , country='||subscription_country||' , year='||subscription_year||':');

    FOR views_record IN (
        SELECT cname, type, viewdate
        FROM Views
        WHERE name = subscription_name AND country = subscription_country AND year = subscription_year
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(views_record.cname || ' | ' || views_record.type || ' | ' || views_record.viewdate);
    END LOOP;
END;
/ 

/*Q5*/

CREATE OR REPLACE FUNCTION Viewsfunc (p_country IN VARCHAR2)
RETURN BOOLEAN
AS
  v_views NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_views
  FROM Views
  WHERE country = p_country;
  if v_views = 0 then
    RAISE_APPLICATION_ERROR(-20001, 'Country not found');
    return false;
  else
    return true;
  end if;
END Viewsfunc;

/
DECLARE
  v_country VARCHAR2(30) :='&v_country';
  v_result VARCHAR2(30);
  v_views NUMBER;
  
BEGIN
    if Viewsfunc(v_country) then
        SELECT COUNT(*) INTO v_views
        FROM Views
        WHERE country = v_country;
        DBMS_OUTPUT.PUT_LINE('Report for '||v_country||' : Total '||v_views||' views');
    end if;
END;

/

/*Q6*/


CREATE OR REPLACE PROCEDURE ViewsProc(p_viewdate date) 
AS
BEGIN
    DBMS_OUTPUT.PUT_LINE ('Report for date :'|| p_viewdate||':');

    FOR views_records IN (
        SELECT name,country,year,cname,type
        FROM Views
        WHERE viewdate = p_viewdate 
    )
        LOOP
            DBMS_OUTPUT.PUT_LINE(views_records.name || ' | ' || views_records.country || ' | ' || views_records.year || ' | ' ||views_records.cname || ' | '|| views_records.type);
        END LOOP;
END;

/

DECLARE
v_viewdate date:='&v_viewdate' ;
BEGIN
    ViewsProc(v_viewdate); 
END;
/