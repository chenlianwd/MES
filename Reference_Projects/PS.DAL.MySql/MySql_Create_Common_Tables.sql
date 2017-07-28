DROP schema ps;
CREATE schema ps;
use ps;

-- 由于MySql的char默认使用的字符集为UTF-8,已经能直接支持多语言。故不需要使用nchar。且nchar在.net connector中还有兼容问题。
-- 为了不同客户端上传数据一致，所有时间写入数据数据时，应该先获取数据库的时间，再获取写入客户端的时间，写入数据库的时间应该补上两者之差后成数据库所用的本地时间。
-- 当向用户显示时，再将数据库的本地时间调整成用户喜好的时区。
-- 所有交叉外键在建表的位置写上并备注掉便于阅读。最后再追加交叉外键，减少在开发阶段的逻辑错误。
-- Employee和PartNumber通常需要集中关心，故使用BIGINT类型，以便在数据量大时采用发布/订阅式的分布系统时，子系统分别使用不同的主键_ID范围避免归集时的冲突。

CREATE TABLE ps_Site(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY  
    ,`Name` varchar(50) NOT NULL UNIQUE
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Site` FOREIGN KEY (_Last_History) REFERENCES ps_Site_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    );
CREATE TABLE ps_Site_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Site_History`(_Site)
		,CONSTRAINT `fk_Site@ps_Site_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
            
    ,`Name` varchar(50) NOT NULL UNIQUE
	,`Description` varchar(200)    
	
    ,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_Site_History`(_Employee_Owner)
		-- ,CONSTRAINT `fk_Employee_Owner@ps_Site_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NULL,INDEX `IDX_Employee_Update@ps_Site_History`(_Employee_Update)
		-- ,CONSTRAINT `fk_Employee_Update@ps_Site_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );
INSERT INTO ps_Site(`Name`) VALUES('Default');
SET @DefaultSiteID=last_insert_id();
INSERT INTO ps_Site_History(_Site,`Name`,`Description`,_Employee_Owner,_Employee_Update)
	SELECT _ID,`Name`,'Default Site',@nSystemID,@nSystemID FROM ps_Site WHERE `Name`='Default';
UPDATE ps_Site tbl INNER JOIN ps_Site_History tblHistory ON tbl._ID=tblHistory._Site AND tbl.`Name`='Default'
	SET tbl._Last_History=tblHistory._ID;

CREATE TABLE ps_Attachment(
	_ID BIGINT NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Attachment`(_Site)		
		 ,CONSTRAINT `fk_Site@ps_Attachment` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,FileName varchar(200)
    ,SavePathName varchar(500)
    ,FileMime varchar(100)
    ,CRC64 int, INDEX `IDX_CRC64@ps_Attachment`(CRC64)
    ,FileSize BIGINT ,INDEX `IDX_FileSize@ps_Attachment`(FileSize)
    ,ImgHeight int ,INDEX `IDX_ImgHeight@ps_Attachment`(ImgHeight)
    ,ImgWidth int ,INDEX `IDX_ImgWidth@ps_Attachment`(ImgWidth)
    ,_Employee_Create BIGINT NULL,INDEX `IDX_Employee_Create@ps_Attachment`(_Employee_Create)
		-- ,CONSTRAINT `fk_Employee_Create@ps_Attachment` FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE 
	,Create_Time Timestamp NULL default CURRENT_TIMESTAMP
	);
SET @Sql=CONCAT('ALTER TABLE ps_Attachment ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

CREATE TABLE ps_Employee(
	_ID BIGINT NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Employee`(_Site)		
		 ,CONSTRAINT `fk_Site@ps_Employee` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
    ,`Name` varchar(50) NOT NULL
		,CONSTRAINT `UNI(_Site,Name)@ps_Employee` UNIQUE(_Site,`Name`)
	,_Last_History BIGINT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Employee` FOREIGN KEY (_Last_History) REFERENCES ps_Employee_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Last_Login_History BIGINT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_Login_History@ps_Employee` FOREIGN KEY (_Last_Login_History) REFERENCES ps_Login_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    );
CREATE TABLE ps_Employee_History(
	_ID BIGINT NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Employee BIGINT NOT NULL,INDEX `IDX_Employee@ps_Employee_History`(_Employee)
		,CONSTRAINT `fk_Employee@ps_Employee_History` FOREIGN KEY (_Employee) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Employee_History`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Employee_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_BU INT NULL,INDEX `IDX_BU@ps_Employee_History`(_BU)
		 -- ,CONSTRAINT `fk_BU@ps_Employee_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Project INT NULL,INDEX `IDX_Project@ps_Employee_History`(_Project)
		 -- ,CONSTRAINT `fk_Project@ps_Employee_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Department INT NULL,INDEX `IDX_Department@ps_Employee_History`(_Department)
		 -- ,CONSTRAINT `fk_Department@ps_Employee_History` FOREIGN KEY (_Department) REFERENCES ps_Department (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    
    ,`Name` varchar(50) NOT NULL
    ,`Password` varchar(50) NULL
    ,_Attachment_Gravatar BIGINT null,INDEX `IDX_Attachment_Gravatar@ps_Employee_History`(_Attachment_Gravatar)
		 ,CONSTRAINT `fk_Attachment_Gravatar@ps_Employee_History` FOREIGN KEY (_Attachment_Gravatar) REFERENCES ps_Attachment (_ID) ON DELETE RESTRICT ON UPDATE CASCADE	
	,Fullname varchar(100) NULL
	,Description varchar(800) NULL
	,Email_Address varchar(200) NULL
    ,Telphone_Number varchar(200) NULL
    ,AD_Account varchar(50) NULL
	,Use_AD_Login tinyint NULL default 0    
    ,`Language` varchar(10) default 'eng'    
    ,Time_Zone int -- 用户喜好的时区
	,Change_Pwd_When_Next_Login tinyint default 0
    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Employee_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Employee_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
	);
SET @Sql=CONCAT('ALTER TABLE ps_Employee ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Employee_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

INSERT INTO ps_Employee(`Name`) VALUES('System');
SET @nSystemID=last_insert_id();
INSERT INTO ps_Employee(`Name`) VALUES('Guest');
SET @nGuestID=last_insert_id();
INSERT INTO ps_Employee(`Name`) VALUES('Admin');
SET @nAdminID=last_insert_id();
-- System和Guest账号不允许直接登录,不允许编辑更改
-- 添加System的默认History
INSERT INTO ps_Employee_History(_Employee,`Name`,Change_Pwd_When_Next_Login,_Employee_Update) VALUES(@nSystemID,'System',0,@nSystemID);
SET @nLastID=last_insert_id();
UPDATE ps_Employee SET _Last_History= @nLastID WHERE _ID=@nSystemID;
-- 添加Guest的默认History
INSERT INTO ps_Employee_History(_Employee,`Name`,Change_Pwd_When_Next_Login,_Employee_Update) VALUES(@nGuestID,'Guest',0,@nSystemID);
SET @nLastID=last_insert_id();
UPDATE ps_Employee SET _Last_History= @nLastID WHERE _ID=@nGuestID;
-- Admin默认密码123456
INSERT INTO ps_Employee_History(_Employee,`Name`,Change_Pwd_When_Next_Login,`Password`,_Employee_Update) VALUES(@nAdminID,'Administrator',1,'ea8753722c0e8ecde195d6adb8ba7c0d',@nSystemID);
SET @nLastID=last_insert_id();
UPDATE ps_Employee SET _Last_History= @nLastID WHERE _ID=@nAdminID;


CREATE TABLE ps_Login_History(
	_ID BIGINT NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Employee BIGINT NOT NULL,INDEX `IDX_Employee@ps_Login_History`(_Employee)
		,CONSTRAINT `fk_Employee@ps_Login_History` FOREIGN KEY (_Employee) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    ,Login_Attempt int NOT NULL
    ,Login_Time Timestamp NOT NULL default CURRENT_TIMESTAMP
	,From_IP varchar(16) NOT NULL
    ,From_Host varchar(50) NOT NULL
    ,From_MAC varchar(20) NULL    
    ,_Login_Result tinyint NOT NULL -- 0:Locked, 1:Noraml, 2:Reject
	);
    

CREATE TABLE ps_Group(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Group`(_Site)		
		 ,CONSTRAINT `fk_Site@ps_Group` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
         
    ,`Name` varchar(50) NOT NULL 
		,CONSTRAINT `UNI(_Site,Name)@ps_Group` UNIQUE(_Site,`Name`)
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Group` FOREIGN KEY (_Last_History) REFERENCES ps_Group_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    );
CREATE TABLE ps_Group_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Group INT NOT NULL,INDEX `IDX_Group@ps_Group_History`(_Group)
		,CONSTRAINT `fk_Group@ps_Group_History` FOREIGN KEY (_Group) REFERENCES ps_Group (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
            
    ,`Name` varchar(50) NOT NULL UNIQUE
	,`Description` varchar(200) 
    
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Group_History`(_Site)
		 ,CONSTRAINT `fk_Site@ps_Group_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Workshop INT NULL,INDEX `IDX_Workshop@ps_Group_History`(_Workshop)
		 -- ,CONSTRAINT `fk_Workshop@ps_Group_History` FOREIGN KEY (_Workshop) REFERENCES ps_Workshop(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Line INT NULL,INDEX `IDX_Line@ps_Group_History`(_Line)
		 -- ,CONSTRAINT `fk_Line@ps_Group_History` FOREIGN KEY (_Line) REFERENCES ps_Line(_ID) ON DELETE RESTRICT ON UPDATE CASCADE        
	
    ,_BU INT NULL,INDEX `IDX_BU@ps_Group_History`(_BU)
		-- ,CONSTRAINT `fk_BU@ps_Group_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Project INT NULL,INDEX `IDX_Project@ps_Group_History`(_Project)
		-- ,CONSTRAINT `fk_Project@ps_Group_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	
    ,_Employee_Owner BIGINT NOT NULL,INDEX `IDX_Employee_Owner@ps_Group_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Group_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Group_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Group_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NOT NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );
SET @Sql=CONCAT('ALTER TABLE ps_Group ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Group_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

INSERT INTO ps_Group(`Name`) VALUES('System'),('Guests'),('Admins');
INSERT INTO ps_Group_History(_Group,`Name`,_Employee_Owner,_Employee_Update)
	SELECT _ID, `Name`,@nSystemID,@nSystemID FROM ps_Group;
UPDATE ps_Group INNER JOIN ps_Group_History tblHistory ON ps_Group._ID=tblHistory._Group
  SET ps_Group._Last_History=tblHistory._ID; 
  

CREATE TABLE ps_Employee_In_Group_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
  
	,_Group INT NOT NULL,INDEX `IDX_Group@ps_Employee_In_Group_History`(_Group)
		,CONSTRAINT `fk_Group@ps_Employee_In_Group_History` FOREIGN KEY (_Group) REFERENCES ps_Group(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Employee BIGINT NOT NULL,INDEX `IDX_Employee@ps_Employee_In_Group_History`(_Employee)    
		,CONSTRAINT `fk_Employee@ps_Employee_In_Group_History` FOREIGN KEY (_Employee) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
	,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Employee_In_Group_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Employee_In_Group_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NOT NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml -- 每个用户所在的组记录，始终使用按_Group,_Employee分组最后一条记录，不需要状态标记 
    );
INSERT INTO ps_Employee_In_Group_History(_Group,_Employee,_Employee_Update)
	SELECT tblGrp._ID,tblEmp._ID,@nSystemID FROM ps_Employee tblEmp,ps_Group tblGrp WHERE tblGrp.`Name`='System' AND tblEmp.`Name`='System'
    UNION SELECT tblGrp._ID,tblEmp._ID,@nSystemID FROM ps_Employee tblEmp,ps_Group tblGrp WHERE tblGrp.`Name`='Guests' AND tblEmp.`Name`='Guest'
    UNION SELECT tblGrp._ID,tblEmp._ID,@nSystemID FROM ps_Employee tblEmp,ps_Group tblGrp WHERE tblGrp.`Name`='Admins' AND tblEmp.`Name`='Admin';
     
 
CREATE TABLE ps_Preference(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY  
    ,`Name` varchar(50) NOT NULL UNIQUE
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Preference` FOREIGN KEY (_Last_History) REFERENCES ps_Preference_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    );
CREATE TABLE ps_Preference_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Preference INT NOT NULL,INDEX `IDX_Preference@ps_Preference_History`(_Preference)
		,CONSTRAINT `fk_Preference@ps_Preference_History` FOREIGN KEY (_Preference) REFERENCES ps_Preference (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    
    ,`Value` varchar(200)    
	,`Description` varchar(200)    
	
    ,_Employee_Update BIGINT NOT NULL ,INDEX `IDX_Employee_Update@ps_Preference_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Preference_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time TIMESTAMP NOT NULL default CURRENT_TIMESTAMP
    );    
INSERT INTO ps_Preference(`Name`)
	values('Default_Language')
    ,('Home_Page_Title')
    ,('Must_Login')
    ,('Logo_Picture')
    ,('Max_Login_Attempt')
    ,('Lock_Minute_After_Max_Login_Attempt');
INSERT INTO ps_Preference_History(_Preference,`Value`,_Employee_Update)
	SELECT _ID,'eng',@nSystemID FROM ps_Preference WHERE `Name`='Default_Language'
    UNION SELECT _ID,'Dashboard',@nSystemID FROM ps_Preference WHERE `Name`='Home_Page_Title'
    UNION SELECT _ID,'False',@nSystemID FROM ps_Preference WHERE `Name`='Must_Login'
    UNION SELECT _ID,'images/test.log',@nSystemID FROM ps_Preference WHERE `Name`='Logo_Picture'
    UNION SELECT _ID,'10',@nSystemID FROM ps_Preference WHERE `Name`='Max_Login_Attempt'
    UNION SELECT _ID,'30',@nSystemID FROM ps_Preference WHERE `Name`='Lock_Minute_After_Max_Login_Attempt';
UPDATE ps_Preference INNER JOIN ps_Preference_History tblHistory ON ps_Preference._ID=tblHistory._Preference
  SET ps_Preference._Last_History=tblHistory._ID; 

   
CREATE TABLE ps_Department(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Department`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Department` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
         
    ,`Name` varchar(50) NOT NULL
		,CONSTRAINT `UNI(_Site,Name)@ps_Department` UNIQUE(_Site,`Name`)
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Department` FOREIGN KEY (_Last_History) REFERENCES ps_Department_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    );
CREATE TABLE ps_Department_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Department INT NOT NULL ,INDEX `IDX_Department@ps_Department_History`(_Department)
		,CONSTRAINT `fk_Department@ps_Department_History` FOREIGN KEY (_Department) REFERENCES ps_Department (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
     
     ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Department_History`(_Site)
		  ,CONSTRAINT `fk_Site_ID@ps_Department_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
          
    ,`Name` varchar(50) NOT NULL
	,`Description` varchar(200)    
	
    ,_Employee_Owner BIGINT NOT NULL,INDEX `IDX_Employee_Owner@ps_Department_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Department_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Department_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Department_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NOT NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );
SET @Sql=CONCAT('ALTER TABLE ps_Department ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Department_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

INSERT INTO ps_Department(`Name`) VALUES('Default');
INSERT INTO ps_Department_History(_Department,`Name`,`Description`,_Employee_Owner,_Employee_Update)
	SELECT _ID,`Name`,'Default Department',@nSystemID,@nSystemID FROM ps_Department WHERE `Name`='Default';
UPDATE ps_Department tbl INNER JOIN ps_Department_History tblHistory ON tbl._ID=tblHistory._Department AND tbl.`Name`='Default'
	SET tbl._Last_History=tblHistory._ID;
       
       
CREATE TABLE ps_Building(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Building`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Building` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
          
    ,`Name` varchar(50) NOT NULL
		,CONSTRAINT `UNI(_Site,Name)@ps_Building` UNIQUE(_Site,`Name`)
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Building` FOREIGN KEY (_Last_History) REFERENCES ps_Building_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    );
CREATE TABLE ps_Building_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Building INT NOT NULL,INDEX `IDX_Building@ps_Buiding_History`(_Building)
		,CONSTRAINT `fk_Building@ps_Buiding_History` FOREIGN KEY (_Building) REFERENCES ps_Building (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Buiding_History`(_Site)
		,CONSTRAINT `fk_Site@ps_Buiding_History` FOREIGN KEY (_Site) REFERENCES ps_Site(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    
    ,`Name` varchar(50) NOT NULL
	,`Description` varchar(200)    
	
    ,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_Buiding_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Buiding_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Buiding_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Buiding_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );
SET @Sql=CONCAT('ALTER TABLE ps_Building ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Building_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

INSERT INTO ps_Building(`Name`) VALUES('Default');
SET @DefaultBuildingID=last_insert_id();
INSERT INTO ps_Building_History(_Building,`Name`,`Description`,_Employee_Owner,_Employee_Update)
	SELECT _ID,`Name`,'Default Building',@nSystemID,@nSystemID FROM ps_Building WHERE `Name`='Default';
UPDATE ps_Building tbl INNER JOIN ps_Building_History tblHistory ON tbl._ID=tblHistory._Building AND tbl.`Name`='Default'
	SET tbl._Last_History=tblHistory._ID;
    
    
CREATE TABLE ps_Workshop(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Workshop`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Workshop` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Building INT NOT NULL,INDEX `IDX_Building@ps_Workshop`(_Building)
		,CONSTRAINT `fk_Building@ps_Workshop` FOREIGN KEY (_Building) REFERENCES ps_Building (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
    ,`Name` varchar(50) NOT NULL
		,CONSTRAINT `UNI(_Site,Name)@ps_Workshop` UNIQUE(_Site,`Name`)
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Workshop` FOREIGN KEY (_Last_History) REFERENCES ps_Workshop_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    );
CREATE TABLE ps_Workshop_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Workshop INT NOT NULL,INDEX `IDX_Workshop@ps_Workshop_History`(_Workshop)
		,CONSTRAINT `fk_Workshop@ps_Workshop_History` FOREIGN KEY (_Workshop) REFERENCES ps_Workshop (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Workshop_History`(_Site)
		,CONSTRAINT `fk_Site@ps_Workshop_History` FOREIGN KEY (_Site) REFERENCES ps_Site(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Building INT NOT NULL,INDEX `IDX_Building@ps_Workshop_History`(_Building)
		,CONSTRAINT `fk_Building@ps_Workshop_History` FOREIGN KEY (_Building) REFERENCES ps_Building (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
    ,`Name` varchar(50) NOT NULL
	,`Description` varchar(200)    
	
    ,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_Workshop_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Workshop_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Workshop_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Workshop_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );
SET @Sql=CONCAT('ALTER TABLE ps_Workshop ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Workshop_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

INSERT INTO ps_Workshop(_Building,`Name`) VALUES(@DefaultBuildingID,'Default');
INSERT INTO ps_Workshop_History(_Building,_Workshop,`Name`,`Description`,_Employee_Owner,_Employee_Update)
	SELECT @DefaultBuildingID,_ID,`Name`,'Default Workshop',@nSystemID,@nSystemID FROM ps_Workshop WHERE `Name`='Default';
UPDATE ps_Workshop tbl INNER JOIN ps_Workshop_History tblHistory ON tbl._ID=tblHistory._Workshop AND tbl.`Name`='Default'
	SET tbl._Last_History=tblHistory._ID;
 
 
CREATE TABLE ps_Shift(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Shift`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Shift` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,`Name` varchar(50) NOT NULL UNIQUE
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Shift` FOREIGN KEY (_Last_History) REFERENCES ps_Shift_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    );
CREATE TABLE ps_Shift_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Workshop`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Shift_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
          
    ,_Shift INT NOT NULL,INDEX `IDX_Line@ps_Shift_History`(_Shift)
		,CONSTRAINT `fk_Line@ps_Shift_History` FOREIGN KEY (_Shift) REFERENCES ps_Shift (_ID) ON DELETE RESTRICT ON UPDATE CASCADE

	,`Name` varchar(50) NOT NULL
	,`Description` varchar(200)        
    
    ,Start_Time Time NOT NULL -- 本地时间
    ,End_Time Time NOT NULL -- 本地时间
    
     ,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_Shift_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Shift_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Shift_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Shift_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml    
    );
INSERT INTO ps_Shift(`Name`,_Site) VALUES('Day',@DefaultSiteID),('Night',@DefaultSiteID);
INSERT INTO ps_Shift_History(_Shift,_Site,`Name`,`Description`,Start_Time,End_Time,_Employee_Owner,_Employee_Update)
	SELECT _ID,@DefaultSiteID,`Name`,'Shift Day','8:00','20:00',@nSystemID,@nSystemID FROM ps_Shift WHERE `Name`='Day'
    UNION SELECT _ID,@DefaultSiteID,`Name`,'Shift Day','20:00','8:00',@nSystemID,@nSystemID FROM ps_Shift WHERE `Name`='Night';
UPDATE ps_Shift tbl INNER JOIN ps_Shift_History tblHistory ON tbl._ID=tblHistory._Shift
	SET tbl._Last_History=tblHistory._ID;

CREATE TABLE ps_Line(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Line`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Line` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
          
	,`Name` varchar(50) NOT NULL 
		,CONSTRAINT `UNI(_Site,Name)@ps_Line` UNIQUE(_Site,`Name`)
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Line` FOREIGN KEY (_Last_History) REFERENCES ps_Line_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    );
CREATE TABLE ps_Line_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Line INT NOT NULL,INDEX `IDX_Line@ps_Line_History`(_Line)
		,CONSTRAINT `fk_Line@ps_Line_History` FOREIGN KEY (_Line) REFERENCES ps_Line (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Line_History`(_Site)
		,CONSTRAINT `fk_Site@ps_Line_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Workshop INT NULL,INDEX `IDX_Workshop@ps_Line_History`(_Workshop)
		,CONSTRAINT `fk_Workshop@ps_Line_History` FOREIGN KEY (_Workshop) REFERENCES ps_Workshop(_ID) ON DELETE RESTRICT ON UPDATE CASCADE        
	
    ,_BU INT NULL,INDEX `IDX_BU@ps_Line_History`(_BU)
		-- ,CONSTRAINT `fk_BU@ps_Line_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Project INT NULL,INDEX `IDX_Project@ps_Line_History`(_Project)
		-- ,CONSTRAINT `fk_Project@ps_Line_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE

	,`Name` varchar(50) NOT NULL
	,`Description` varchar(200)        
    
     ,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_Line_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Line_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Line_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Line_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml    
    );
SET @Sql=CONCAT('ALTER TABLE ps_Line ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Line_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

INSERT INTO ps_Line(`Name`) VALUES('Default');
INSERT INTO ps_Line_History(_Line,_Site,_Workshop,`Name`,`Description`,_Employee_Owner,_Employee_Update)
	SELECT tblA._ID,tblB._ID,tblC._ID,tblA.`Name`,'Default Line',@nSystemID,@nSystemID FROM ps_Line tblA,ps_Site tblB,ps_Workshop tblC
		WHERE tblA.`Name`='Default' AND tblB.`Name`='Default' AND tblC.`Name`='Default';
UPDATE ps_Line tbl INNER JOIN ps_Line_History tblHistory ON tbl._ID=tblHistory._Line AND tbl.`Name`='Default'
	SET tbl._Last_History=tblHistory._ID;


CREATE TABLE ps_Shift_In_Line_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
  
	,_Line INT NOT NULL,INDEX `IDX_Line@ps_Shift_In_Line_History`(_Line)
		,CONSTRAINT `fk_Line@ps_Shift_In_Line_History` FOREIGN KEY (_Line) REFERENCES ps_Line(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Shift INT NOT NULL,INDEX `IDX_Shift@ps_Shift_In_Line_History`(_Shift)    
		,CONSTRAINT `fk_Shift@ps_Shift_In_Line_History` FOREIGN KEY (_Shift) REFERENCES ps_Shift (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
	,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Shift_In_Line_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Shift_In_Line_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NOT NULL default CURRENT_TIMESTAMP
    -- 每个Line所使用的Shift记录，始终使用按_Line,_Shift分组最后一条记录，不需要状态标记 ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );
INSERT INTO ps_Shift_In_Line_History(_Line,_Shift,_Employee_Update)
	SELECT tblLine._ID,tblShift._ID,@nSystemID FROM ps_Line tblLine,ps_Shift tblShift WHERE tblLine.`Name`='Default' AND tblShift.`Name`='Day'
    UNION SELECT tblLine._ID,tblShift._ID,@nSystemID FROM ps_Line tblLine,ps_Shift tblShift WHERE tblLine.`Name`='Default' AND tblShift.`Name`='Night';
      
   
CREATE TABLE ps_BU(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_BU`(_Site)
		  ,CONSTRAINT `fk_Site@ps_BU` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
          
    ,`Name` varchar(50) NOT NULL
		,CONSTRAINT `UNI(_Site,Name)@ps_BU` UNIQUE(_Site,`Name`)
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_BU` FOREIGN KEY (_Last_History) REFERENCES ps_BU_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    );
CREATE TABLE ps_BU_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_BU INT NOT NULL,INDEX `IDX_Project@ps_BU_History`(_BU)
		,CONSTRAINT `fk_Project@ps_BU_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
    ,`Name` varchar(50) NOT NULL
	,`Description` varchar(200)
    
	,_Site INT NOT NULL,INDEX `IDX_Site@ps_BU_History`(_Site)
		,CONSTRAINT `fk_Site@ps_BU_History` FOREIGN KEY (_Site) REFERENCES ps_Site(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Workshop INT NULL,INDEX `IDX_Workshop@ps_BU_History`(_Workshop)
		,CONSTRAINT `fk_Workshop@ps_BU_History` FOREIGN KEY (_Workshop) REFERENCES ps_Workshop (_ID) ON DELETE RESTRICT ON UPDATE CASCADE            
	
    ,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_BU_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_BU_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_BU_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_BU_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );
SET @Sql=CONCAT('ALTER TABLE ps_BU ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_BU_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

INSERT INTO ps_BU(`Name`) VALUES('Default');
INSERT INTO ps_BU_History(_BU,`Name`,`Description`,_Employee_Owner,_Employee_Update)
	SELECT _ID,`Name`,'Default BU',@nSystemID,@nSystemID FROM ps_BU WHERE `Name`='Default';
UPDATE ps_BU tbl INNER JOIN ps_BU_History tblHistory ON tbl._ID=tblHistory._BU AND tbl.`Name`='Default'
	SET tbl._Last_History=tblHistory._ID;

    
CREATE TABLE ps_Project(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Project`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Project` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
          
    ,`Name` varchar(50) NOT NULL
		,CONSTRAINT `UNI(_Site,Name)@ps_Project` UNIQUE(_Site,`Name`)
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Project` FOREIGN KEY (_Last_History) REFERENCES ps_Project_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE	
    );
CREATE TABLE ps_Project_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
     ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Project_History`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Project_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE          
    ,_Project INT NOT NULL,INDEX `IDX_Project@ps_Project_History`(_Project)
		,CONSTRAINT `fk_Project@ps_Project_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    
    ,_BU INT NOT NULL,INDEX `IDX_BU@ps_Project_History`(_BU)
		,CONSTRAINT `fk_BU@ps_Project_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE        
    ,`Name` varchar(50) NOT NULL
	,`Description` varchar(200)    
	
    ,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_Project_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Project_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
	,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Project_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Project_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );
SET @Sql=CONCAT('ALTER TABLE ps_Project ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Project_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

INSERT INTO ps_Project(`Name`) VALUES('Default');
INSERT INTO ps_Project_History(_Project,_BU,`Name`,`Description`,_Employee_Owner,_Employee_Update)
	SELECT tblA._ID,tblB._ID,tblA.`Name`,'Default Project',@nSystemID,@nSystemID FROM ps_Project tblA,ps_BU tblB WHERE tblA.`Name`='Default' AND tblB.`Name`='Default';
UPDATE ps_Project tbl INNER JOIN ps_Project_History tblHistory ON tbl._ID=tblHistory._Project AND tbl.`Name`='Default'
	SET tbl._Last_History=tblHistory._ID;
    
    
CREATE TABLE ps_Page(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,`Name` varchar(50) NOT NULL UNIQUE
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Page` FOREIGN KEY (_Last_History) REFERENCES ps_Page_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE	
    );
CREATE TABLE ps_Page_History(
	_ID int NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Page INT NOT NULL,INDEX `IDX_Page@ps_Page_History`(_Page)
		,CONSTRAINT `fk_Page@ps_Page_History` FOREIGN KEY (_Page) REFERENCES ps_Page (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
    ,_Site INT NULL,INDEX `IDX_Site@ps_Page_History`(_Site)
		,CONSTRAINT `fk_Site@ps_Page_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_BU INT NULL,INDEX `IDX_BU@ps_Page_History`(_BU)
		,CONSTRAINT `fk_BU@ps_Page_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Project INT NULL,INDEX `IDX_Project@ps_Page_History`(_Project)
		,CONSTRAINT `fk_Project@ps_Page_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
    ,`Name` varchar(50) NOT NULL
	,`Description` varchar(200) 
    
	,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_Page_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Page_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Page_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Page_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );  
INSERT INTO ps_Page(`Name`) VALUES('Default');
INSERT INTO ps_Page_History(_Page,`Name`,`Description`,_Employee_Owner,_Employee_Update)
	SELECT _ID,`Name`,'Default BU',@nSystemID,@nSystemID FROM ps_Page WHERE `Name`='Default';
UPDATE ps_Page tbl INNER JOIN ps_Page_History tblHistory ON tbl._ID=tblHistory._Page AND tbl.`Name`='Default'
	SET tbl._Last_History=tblHistory._ID;
    
    
CREATE TABLE ps_Line_In_Page(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY
   ,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Line_In_Page` FOREIGN KEY (_Last_History) REFERENCES ps_Line_In_Page_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE	
    );
CREATE TABLE ps_Line_In_Page_History(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,_Line_In_Page INT NOT NULL
		 ,CONSTRAINT `fk_Line_In_Page@ps_Line_In_Page_History` FOREIGN KEY (_Line_In_Page) REFERENCES ps_Line_In_Page (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
         
    ,_Page INT NOT NULL,INDEX `IDX_Page@ps_Line_In_Page_History`(_Page)
		,CONSTRAINT `fk_Page@ps_Line_In_Page_History` FOREIGN KEY (_Page) REFERENCES ps_Page (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Line INT NOT NULL,INDEX `IDX_Line@ps_Line_In_Page_History`(_Line)
		,CONSTRAINT `fk_Line@ps_Line_In_Page_History` FOREIGN KEY (_Line) REFERENCES ps_Line(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,X int not NULL
    ,Y int not null	
        
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Line_In_Page_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Line_In_Page_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );
    
    
CREATE TABLE ps_Group_Access_By_Line(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Group_Access_By_Line` FOREIGN KEY (_Last_History) REFERENCES ps_Group_Access_By_Line_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE	
);
CREATE TABLE ps_Group_Access_By_Line_History(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,_Group_Access_By_Line INT NOT NULL
		 ,CONSTRAINT `fk_Group_Access_By_Line@ps_Group_Access_By_Line_History` FOREIGN KEY (_Group_Access_By_Line) REFERENCES ps_Group_Access_By_Line (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
         
	,_Group INT NOT NULL,INDEX `IDX_Group@ps_Group_Access_By_Line_History`(_Group)
		,CONSTRAINT `fk_Group@ps_Group_Access_By_Line_History` FOREIGN KEY (_Group) REFERENCES ps_Group(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Line INT NOT NULL,INDEX `IDX_Line@ps_Group_Access_By_Line_History`(_Line)
		,CONSTRAINT `fk_Line@ps_Group_Access_By_Line_History` FOREIGN KEY (_Line) REFERENCES ps_Line(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	
    ,AccessType INT NOT NULL default -1 -- -1:Full Access, 0x01:View Report, 0x02:Add Report, 0x04:Add partner with same permission 
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Group_Access_By_Line_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Group_Access_By_Line_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
);


CREATE TABLE ps_Group_Access_By_Page(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Group_Access_By_Page` FOREIGN KEY (_Last_History) REFERENCES ps_Group_Access_By_Page_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE ps_Group_Access_By_Page_History(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,_Group_Access_By_Page INT NOT NULL
		 ,CONSTRAINT `fk_Group_Access_By_Page@ps_Group_Access_By_Page_History` FOREIGN KEY (_Group_Access_By_Page) REFERENCES ps_Group_Access_By_Page (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
         
	,_Group INT NOT NULL,INDEX `IDX_Employee_Group_ID@ps_Group_Access_By_Page_History`(_Group)
		,CONSTRAINT `fk_Employee_Group@ps_Group_Access_By_Page_History` FOREIGN KEY (_Group) REFERENCES ps_Group (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Page INT NOT NULL,INDEX `IDX_Page@ps_Group_Access_By_Page_History`(_Page)
		,CONSTRAINT `fk_Page@ps_Group_Access_By_Page_History` FOREIGN KEY (_Page) REFERENCES ps_Page (_ID) ON DELETE RESTRICT ON UPDATE CASCADE	
  
	,AccessType INT NOT NULL default -1 -- -1:Full Access, 0x01:View Report, 0x02:Add Report, 0x04:Add partner with same permission 
   ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Group_Access_By_Page_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Group_Access_By_Page_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
);

/* 站位用途Template，常见的用途Template及特点:
	1. Creating:	产品开始投入，可能需要输入序列号，以及所在的拼板状态。    
    
    2. Feeding:		将物料添加到机器上，并由另一站消耗。能跟踪物料添加历史记录。并可能需要记录物料的SN,Datecode等信息。
    3. Consuming:	消耗另一站添加的物料，物料可能意外损耗。 可能需要记录【何】物料用到到了【何】产品上。
    4. Feeding and Consuming:	结合以上2&3，可能需要计算结余。
    5. Assemly:		仅组装，不需要任何物料(不包括工具)，可能需要记录每个产品经过的记录。
    6. Assemly and Consuming:	组装并需要物料。结合3&4&5的功能。
    
    7. Testing:		有Pass/Fail之别，甚至可能有NDF这种第三态，可能需要按站位类型统计整体的First Pass Yield,Final Pass Yield,GR&R; 按Item统计Top N Failure，CPK,GR&R等。
			整体统计时，可能需要按Part,PartFamily,Fixture,Station,StaitonType,Line,WorkShop,Site,Project,BU,Hour,Shift,Day,Week,Month等分组。
	8. Debug:	分析不良品，标出不良信息与位置。
    9. Repair:	修理已经分析好的不良品。更换物料。可能需要记录更换的物料信息，统计更换的物料(PN,Datecode,SN等)。
    10. Debug and Repair: 结合上面8&9。
    
	10. Acquiring:	没有Pass/Fail之别，通常比较关心最后的数值及最近的趋势。

    12. Packaging:	需要包装物料，可能需要先装小包装，再装大包装。可能需要记录包装的SN,Datecode等信息。
*/
CREATE TABLE ps_Station_Template(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,`Name` varchar(100) NOT NULL UNIQUE
    ,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Station_Template` FOREIGN KEY (_Last_History) REFERENCES ps_Station_Template_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE ps_Station_Template_History(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,_Station_Template INT NOT NULL,INDEX `IDX_Station_Template@ps_Station_Template_History`(_Station_Template)
		 ,CONSTRAINT `fk_Station_Template@ps_Station_Template_History` FOREIGN KEY (_Station_Template) REFERENCES ps_Station_Template (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
         
    ,`Name` varchar(100) NOT NULL 
	,`Description` varchar(200)
    ,Handle_Assembly varchar(100) NULL
    
	,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_Station_Template_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Station_Template_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Station_Template_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Station_Template_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
);

CREATE TABLE ps_Station_Type(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Station_Type`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Station_Type` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
          
    ,`Name` varchar(100) NOT NULL
		,CONSTRAINT `UNI(_Site,Name)@ps_Station_Type` UNIQUE(_Site,`Name`)
    ,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Station_Type` FOREIGN KEY (_Last_History) REFERENCES ps_Station_Type_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
);
CREATE TABLE ps_Station_Type_History(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Station_Type_History`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Station_Type_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
          
    ,_Station_Type INT NOT NULL 
		 ,CONSTRAINT `fk_Station_Type@ps_Station_Type_History` FOREIGN KEY (_Station_Type) REFERENCES ps_Station_Type (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    
    ,_Station_Template INT NOT NULL 
		 ,CONSTRAINT `fk_Station_Template@ps_Station_Type_History` FOREIGN KEY (_Station_Template) REFERENCES ps_Station_Template (_ID) ON DELETE RESTRICT ON UPDATE CASCADE         
    ,`Name` varchar(100) NOT NULL 
	,`Description` varchar(200)
	,Handle_Assembly varchar(100) NULL
    
	,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_Station_Type_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Station_Type_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Station_Type_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Station_Type_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
);
SET @Sql=CONCAT('ALTER TABLE ps_Station_Type ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Station_Type_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;


CREATE TABLE ps_Station(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Station`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Station` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	
    ,`Name` varchar(100) NOT NULL
		,CONSTRAINT `UNI(_Site,Name)@ps_Station` UNIQUE(_Site,`Name`)
    ,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Station` FOREIGN KEY (_Last_History) REFERENCES ps_Station_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE        
);
CREATE TABLE ps_Station_History(
	_ID int NOT NULL AUTO_INCREMENT PRIMARY KEY     
     ,_Station INT NOT NULL,INDEX `IDX_Station@ps_Station_In_Line_History`(_Station)
		,CONSTRAINT `fk_Station@ps_Station_In_Line_History` FOREIGN KEY (_Station) REFERENCES ps_Station (_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
        
     ,_Line INT NOT NULL,INDEX `IDX_Line@ps_Station_In_Line_History`(_Line)
		,CONSTRAINT `fk_Line@ps_Station_In_Line_History` FOREIGN KEY (_Line) REFERENCES ps_Line (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	 ,_Station_Type INT NOT NULL,INDEX `IDX_Station_Type@ps_Station_History`(_Station_Type)
		,CONSTRAINT `fk_Station_Type@ps_Station_History` FOREIGN KEY (_Station_Type) REFERENCES ps_Station_Type (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
   
    ,`Name` varchar(100) NOT NULL 
	,`Description` varchar(200)
	,HostName varchar(100)
    ,MAC_Address varchar(20)
    ,Guid_ID varchar(50)
    
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Station_History`(_Site)
		,CONSTRAINT `fk_Site@ps_Station_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_BU INT NULL,INDEX `IDX_BU@ps_Station_History`(_BU)
		,CONSTRAINT `fk_BU@ps_Station_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Project INT NULL,INDEX `IDX_Project@ps_Station_History`(_Project)
		,CONSTRAINT `fk_Project@ps_Station_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    
    ,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_Station_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Station_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Station_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Station_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
);
SET @Sql=CONCAT('ALTER TABLE ps_Station ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Station_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;


CREATE TABLE ps_Fixture(
	_ID BIGINT NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Fixture`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Fixture` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
          
    ,`Name` varchar(50) NOT NULL
		,CONSTRAINT `UNI(_Site,Name)@ps_Fixture` UNIQUE(_Site,`Name`)
	,_Last_History BIGINT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Fixture` FOREIGN KEY (_Last_History) REFERENCES ps_Fixture_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    );
CREATE TABLE ps_Fixture_History(
	_ID BIGINT NOT NULL  AUTO_INCREMENT PRIMARY KEY
    ,_Fixture BIGINT NOT NULL,INDEX `IDX_Fixture@ps_Fixture_History`(_Fixture)
		,CONSTRAINT `fk_Fixture@ps_Fixture_History` FOREIGN KEY (_Fixture) REFERENCES ps_Fixture (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
    ,Guid_ID varchar(50) NULL
    ,`Name` varchar(50) NOT NULL
	,`Description` varchar(200)
    
	,_Site INT NOT NULL,INDEX `IDX_Site@ps_Fixture_History`(_Site)
		,CONSTRAINT `fk_Site@ps_Fixture_History` FOREIGN KEY (_Site) REFERENCES ps_Site(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Workshop INT NULL,INDEX `IDX_Workshop@ps_Fixture_History`(_Workshop)
		,CONSTRAINT `fk_Workshop@ps_Fixture_History` FOREIGN KEY (_Workshop) REFERENCES ps_Workshop (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Line INT NULL,INDEX `IDX_Line@ps_Fixture_History`(_Line)
		,CONSTRAINT `fk_Line@ps_Fixture_History` FOREIGN KEY (_Line) REFERENCES ps_Line (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Station INT NULL,INDEX `IDX_Station@ps_Fixture_History`(_Station)
		,CONSTRAINT `fk_Station@ps_Fixture_History` FOREIGN KEY (_Station) REFERENCES ps_Station (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
        
    ,_BU INT NULL,INDEX `IDX_BU@ps_Fixture_History`(_BU)
		,CONSTRAINT `fk_BU@ps_Fixture_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Project INT NULL,INDEX `IDX_Project@ps_Fixture_History`(_Project)
		,CONSTRAINT `fk_Project@ps_Fixture_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	
    ,_Employee_Owner BIGINT NULL,INDEX `IDX_Employee_Owner@ps_Fixture_History`(_Employee_Owner)
		,CONSTRAINT `fk_Employee_Owner@ps_Fixture_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Fixture_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Fixture_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );
SET @Sql=CONCAT('ALTER TABLE ps_Fixture ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Fixture_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

INSERT INTO ps_Fixture(`Name`) VALUES('Default');
INSERT INTO ps_Fixture_History(_Fixture,`Name`,`Description`,_Employee_Owner,_Employee_Update)
	SELECT _ID,`Name`,'Default Fixture',@nSystemID,@nSystemID FROM ps_Fixture WHERE `Name`='Default';
UPDATE ps_Fixture tbl INNER JOIN ps_Fixture_History tblHistory ON tbl._ID=tblHistory._Fixture AND tbl.`Name`='Default'
	SET tbl._Last_History=tblHistory._ID;

CREATE TABLE ps_Part_Family(
	_ID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Part_Family`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Part_Family` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	
    ,`Name` varchar(100) NOT NULL
		,CONSTRAINT `UNI(_Site,Name)@ps_Part_Family` UNIQUE(_Site,`Name`)
    ,_Last_History BIGINT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Part_Family` FOREIGN KEY (_Last_History) REFERENCES ps_Part_Family_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE        
);
CREATE TABLE ps_Part_Family_History(
	_ID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY     
    ,_Part_Family BIGINT NOT NULL,INDEX `IDX_Part_Family@ps_Part_Family_History`(_Part_Family)
		,CONSTRAINT `fk_Part_Family@ps_Part_Family_History` FOREIGN KEY (_Part_Family) REFERENCES ps_Part_Family (_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
       
    ,`Name` varchar(100) NOT NULL 
	,`Description` varchar(200)
    ,_External_Part_Family INT NULL
    
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Part_Family_History`(_Site)
		,CONSTRAINT `fk_Site@ps_Part_Family_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_BU INT NULL,INDEX `IDX_BU@ps_Part_Family_History`(_BU)
		,CONSTRAINT `fk_BU@ps_Part_Family_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Project INT NULL,INDEX `IDX_Project@ps_Part_Family_History`(_Project)
		,CONSTRAINT `fk_Project@ps_Part_Family_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Part_Family_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Part_Family_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
);
SET @Sql=CONCAT('ALTER TABLE ps_Part_Family ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Part_Family_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

INSERT INTO ps_Part_Family(`Name`) VALUES('Default');
INSERT INTO ps_Part_Family_History(_Part_Family,`Name`,`Description`,_Employee_Update)
	SELECT _ID,`Name`,'Default Part Family',@nSystemID FROM ps_Part_Family WHERE `Name`='Default';
UPDATE ps_Part_Family tbl INNER JOIN ps_Part_Family_History tblHistory ON tbl._ID=tblHistory._Part_Family AND tbl.`Name`='Default'
	SET tbl._Last_History=tblHistory._ID;


CREATE TABLE ps_Part_Number(
	_ID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Part_Number`(_Site)
		  ,CONSTRAINT `fk_Site@ps_Part_Number` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	
    ,`Name` varchar(100) NOT NULL
		,CONSTRAINT `UNI(_Site,Name)@ps_Part_Number` UNIQUE(_Site,`Name`)
    ,_Last_History BIGINT NULL UNIQUE
		 -- ,CONSTRAINT `fk_Last_History@ps_Part_Number` FOREIGN KEY (_Last_History) REFERENCES ps_Part_Number_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE        
);
CREATE TABLE ps_Part_Number_History(
	_ID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY     
    ,_Part_Number BIGINT NOT NULL,INDEX `IDX_Part_Number@ps_Part_Number_History`(_Part_Number)
		,CONSTRAINT `fk_Part_Number@ps_Part_Number_History` FOREIGN KEY (_Part_Number) REFERENCES ps_Part_Family (_ID) ON DELETE RESTRICT ON UPDATE CASCADE    
       
    ,`Name` varchar(100) NOT NULL 
	,`Description` varchar(200)
    ,_External_Part_Number BIGINT NULL
    ,UOM varchar(50) NULL
	,IsUnit smallint NOT NULL default 0
    
    ,_Site INT NOT NULL,INDEX `IDX_Site@ps_Part_Number_History`(_Site)
		,CONSTRAINT `fk_Site@ps_Part_Number_History` FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_BU INT NULL,INDEX `IDX_BU@ps_Part_Number_History`(_BU)
		,CONSTRAINT `fk_BU@ps_Part_Number_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,_Project INT NULL,INDEX `IDX_Project@ps_Part_Number_History`(_Project)
		,CONSTRAINT `fk_Project@ps_Part_Number_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
    
    ,_Employee_Update BIGINT NOT NULL,INDEX `IDX_Employee_Update@ps_Part_Number_History`(_Employee_Update)
		,CONSTRAINT `fk_Employee_Update@ps_Part_Number_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Update_Time Timestamp NULL default CURRENT_TIMESTAMP
    ,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
);
SET @Sql=CONCAT('ALTER TABLE ps_Part_Number ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;
SET @Sql=CONCAT('ALTER TABLE ps_Part_Number_History ALTER _Site SET default ',@DefaultSiteID);
PREPARE stmt FROM @Sql;EXECUTE stmt;deallocate prepare stmt;

INSERT INTO ps_Part_Number(`Name`) VALUES('Default');
INSERT INTO ps_Part_Number_History(_Part_Number,`Name`,`Description`,_Employee_Update)
	SELECT _ID,`Name`,'Default Part Number',@nSystemID FROM ps_Part_Number WHERE `Name`='Default';
UPDATE ps_Part_Number tbl INNER JOIN ps_Part_Number_History tblHistory ON tbl._ID=tblHistory._Part_Number AND tbl.`Name`='Default'
	SET tbl._Last_History=tblHistory._ID;
    

    
-- 追加交叉外键的约束
ALTER TABLE ps_Site ADD CONSTRAINT `fk_Last_History@ps_Site` FOREIGN KEY (_Last_History) REFERENCES ps_Site_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Site_History ADD CONSTRAINT `fk_Employee_Owner@ps_Site_History` FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Site_History ADD CONSTRAINT `fk_Employee_Update@ps_Site_History` FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Attachment ADD CONSTRAINT `fk_Employee_Create@ps_Attachment` FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee(_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Employee ADD CONSTRAINT `fk_Last_History@ps_Employee` FOREIGN KEY (_Last_History) REFERENCES ps_Employee_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Employee ADD CONSTRAINT `fk_Last_Login_History@ps_Employee` FOREIGN KEY (_Last_Login_History) REFERENCES ps_Login_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Employee_History ADD CONSTRAINT `fk_BU@ps_Employee_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Employee_History ADD CONSTRAINT `fk_Project@ps_Employee_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Employee_History ADD CONSTRAINT `fk_Department@ps_Employee_History` FOREIGN KEY (_Department) REFERENCES ps_Department (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Group ADD CONSTRAINT `fk_Last_History@ps_Group` FOREIGN KEY (_Last_History) REFERENCES ps_Group_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Group_History ADD CONSTRAINT `fk_Workshop@ps_Group_History` FOREIGN KEY (_Workshop) REFERENCES ps_Workshop(_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Group_History ADD CONSTRAINT `fk_Line@ps_Group_History` FOREIGN KEY (_Line) REFERENCES ps_Line(_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Group_History ADD CONSTRAINT `fk_BU@ps_Group_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Group_History ADD CONSTRAINT `fk_Project@ps_Group_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Preference ADD CONSTRAINT `fk_Last_History@ps_Preference` FOREIGN KEY (_Last_History) REFERENCES ps_Preference_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Department ADD CONSTRAINT `fk_Last_History@ps_Department` FOREIGN KEY (_Last_History) REFERENCES ps_Department_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Building ADD CONSTRAINT `fk_Last_History@ps_Building` FOREIGN KEY (_Last_History) REFERENCES ps_Building_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Workshop ADD CONSTRAINT `fk_Last_History@ps_Workshop` FOREIGN KEY (_Last_History) REFERENCES ps_Workshop_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Shift ADD CONSTRAINT `fk_Last_History@ps_Shift` FOREIGN KEY (_Last_History) REFERENCES ps_Shift_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Line ADD CONSTRAINT `fk_Last_History@ps_Line` FOREIGN KEY (_Last_History) REFERENCES ps_Line_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Line_History ADD CONSTRAINT `fk_BU@ps_Line_History` FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Line_History ADD CONSTRAINT `fk_Project@ps_Line_History` FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_BU ADD CONSTRAINT `fk_Last_History@ps_BU` FOREIGN KEY (_Last_History) REFERENCES ps_BU_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Project ADD CONSTRAINT `fk_Last_History@ps_Project` FOREIGN KEY (_Last_History) REFERENCES ps_Project_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Page ADD CONSTRAINT `fk_Last_History@ps_Page` FOREIGN KEY (_Last_History) REFERENCES ps_Page_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Line_In_Page ADD CONSTRAINT `fk_Last_History@ps_Line_In_Page` FOREIGN KEY (_Last_History) REFERENCES ps_Line_In_Page_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Group_Access_By_Line ADD CONSTRAINT `fk_Last_History@ps_Group_Access_By_Line` FOREIGN KEY (_Last_History) REFERENCES ps_Group_Access_By_Line_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Group_Access_By_Page ADD CONSTRAINT `fk_Last_History@ps_Group_Access_By_Page` FOREIGN KEY (_Last_History) REFERENCES ps_Group_Access_By_Page_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Station_Template ADD CONSTRAINT `fk_Last_History@ps_Station_Template` FOREIGN KEY (_Last_History) REFERENCES ps_Station_Template_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Station_Type ADD CONSTRAINT `fk_Last_History@ps_Station_Type` FOREIGN KEY (_Last_History) REFERENCES ps_Station_Type_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Station ADD CONSTRAINT `fk_Last_History@ps_Station` FOREIGN KEY (_Last_History) REFERENCES ps_Station_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Fixture ADD CONSTRAINT `fk_Last_History@ps_Fixture` FOREIGN KEY (_Last_History) REFERENCES ps_Fixture_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Part_Family ADD CONSTRAINT `fk_Last_History@ps_Part_Family` FOREIGN KEY (_Last_History) REFERENCES ps_Part_Family_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;
ALTER TABLE ps_Part_Number ADD CONSTRAINT `fk_Last_History@ps_Part_Number` FOREIGN KEY (_Last_History) REFERENCES ps_Part_Number_History (_ID) ON DELETE RESTRICT ON UPDATE CASCADE;



