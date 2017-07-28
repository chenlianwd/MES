DROP TABLE TestTime;

CREATE TABLE TestTime(	
    ID int NOT NULL  PRIMARY KEY
    ,UpdateTime TIMESTAMP NULL default CURRENT_TIMESTAMP
    ,TestTime time
    );
    
-- INSERT INTO TestTime(ID,TestTime) values(2,'16:00');
UPDATE TestTime SET ID=50,UpdateTime=NULL WHERE ID=50;

set time_zone = '+2:00';
SELECT * FROM TestTime;

