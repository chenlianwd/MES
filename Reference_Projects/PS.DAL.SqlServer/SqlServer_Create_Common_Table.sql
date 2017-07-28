USE master;
GO

ALTER DATABASE PIS_Test SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE PIS_Test;
GO

CREATE DATABASE PIS_Test;
GO

USE PIS_Test;
GO

-- 由于MySql的char默认使用的字符集为UTF-8,已经能直接支持多语言。故不需要使用nchar。且nchar在.net connector中还有兼容问题。
-- 为了不同客户端上传数据一致，所有时间写入数据数据时，应该先获取数据库的时间，再获取写入客户端的时间，写入数据库的时间应该补上两者之差后成数据库所用的本地时间。
-- 当向用户显示时，再将数据库的本地时间调整成用户喜好的时区。
-- 所有交叉外键在建表的位置写上并备注掉便于阅读。最后再追加交叉外键，减少在开发阶段的逻辑错误。
-- Employee和PartNumber通常需要集中关心，故使用BIGINT类型，以便在数据量大时采用发布/订阅式的分布系统时，子系统分别使用不同的主键_ID范围避免归集时的冲突。

CREATE TABLE ps_Site(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY  
    ,Name nvarchar(50) NOT NULL UNIQUE
	,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Site] FOREIGN KEY (_Last_History) REFERENCES ps_Site_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Site ON ps_Site(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Site_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL 
		-- ,INDEX [IDX_Site@ps_Site_History](_Site)
		,CONSTRAINT [fk_Site@ps_Site_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
            
    ,[Name] nvarchar(50) NOT NULL UNIQUE
	,[Description] nvarchar(200)    
	,Time_Zone int --用四位整数表示的时区

    ,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Site_History](_Employee_Owner)
		-- ,CONSTRAINT [fk_Employee_Owner@ps_Site_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Site_History](_Employee_Update)
		-- ,CONSTRAINT [fk_Employee_Update@ps_Site_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
    );

DECLARE  @DefaultSiteID INT
INSERT INTO ps_Site(Name) VALUES('Default');
SET @DefaultSiteID=SCOPE_IDENTITY();


CREATE TABLE ps_Attachment(
	_ID BIGINT NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Attachment](_Site)		
		 ,CONSTRAINT [fk_Site@ps_Attachment] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,FileName nvarchar(200)
    ,SavePathName nvarchar(500)
    ,FileMime nvarchar(100)
    ,CRC64 int
		--, INDEX [IDX_CRC64@ps_Attachment](CRC64)
    ,FileSize BIGINT
		-- ,INDEX [IDX_FileSize@ps_Attachment](FileSize)
    ,ImgHeight int
		-- ,INDEX [IDX_ImgHeight@ps_Attachment](ImgHeight)
    ,ImgWidth int
		-- ,INDEX [IDX_ImgWidth@ps_Attachment](ImgWidth)
    ,_Employee_Create BIGINT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Attachment](_Employee_Create)
		-- ,CONSTRAINT [fk_Employee_Create@ps_Attachment] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee(_ID) ON DELETE CASCADE ON UPDATE CASCADE 
	,Create_Time datetimeoffset NULL default(SYSDATETIMEOFFSET())
	);
DECLARE @sSql nvarchar(2000)
EXEC('ALTER TABLE ps_Attachment ADD default('+@DefaultSiteID+') FOR _Site');

CREATE TABLE ps_Employee(
	_ID BIGINT NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Employee](_Site)		
		 ,CONSTRAINT [fk_Site@ps_Employee] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
        
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(_Site,Name)@ps_Employee] UNIQUE(_Site,[Name])
	,_Last_History BIGINT NULL UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Employee] FOREIGN KEY (_Last_History) REFERENCES ps_Employee_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,_Last_Login_History BIGINT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_Login_History@ps_Employee] FOREIGN KEY (_Last_Login_History) REFERENCES ps_Login_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Employee ON ps_Employee(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE UNIQUE INDEX UNI_Last_Login_History@ps_Employee ON ps_Employee(_Last_Login_History) WHERE _Last_Login_History IS NOT NULL;
CREATE TABLE ps_Employee_History(
	_ID BIGINT NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Employee BIGINT NOT NULL
		-- ,INDEX [IDX_Employee@ps_Employee_History](_Employee)
		,CONSTRAINT [fk_Employee@ps_Employee_History] FOREIGN KEY (_Employee) REFERENCES ps_Employee (_ID) ON DELETE CASCADE ON UPDATE CASCADE
        
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Employee_History](_Site)
		,CONSTRAINT [fk_Site@ps_Employee_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_BU INT NULL
		-- ,INDEX [IDX_BU@ps_Employee_History](_BU)
		-- ,CONSTRAINT [fk_BU@ps_Employee_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,_Project INT NULL
		-- ,INDEX [IDX_Project@ps_Employee_History](_Project)
		-- ,CONSTRAINT [fk_Project@ps_Employee_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Department INT NULL
		-- ,INDEX [IDX_Department@ps_Employee_History](_Department)
		-- ,CONSTRAINT [fk_Department@ps_Employee_History] FOREIGN KEY (_Department) REFERENCES ps_Department (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
	,_Employee_Leader BIGINT NULL
		-- ,INDEX [IDX_Employee_Leader@ps_Employee_History](_Employee_Leader)
		-- ,CONSTRAINT [fk_Employee_Leader@ps_Employee_History] FOREIGN KEY (_Employee_Leader) REFERENCES ps_Employee (_ID) ON DELETE CASCADE ON UPDATE CASCADE

    ,[Name] nvarchar(50) NOT NULL
    ,[Password] nvarchar(50) NULL
    ,_Attachment_Gravatar BIGINT null
		-- ,INDEX [IDX_Attachment_Gravatar@ps_Employee_History](_Attachment_Gravatar)
		,CONSTRAINT [fk_Attachment_Gravatar@ps_Employee_History] FOREIGN KEY (_Attachment_Gravatar) REFERENCES ps_Attachment (_ID) --ON DELETE CASCADE ON UPDATE CASCADE	
	,Fullname nvarchar(100) NULL
	,Description nvarchar(800) NULL
	,Email_Address nvarchar(200) NULL
    ,Telphone_Number nvarchar(200) NULL
    ,AD_Account nvarchar(50) NULL
	,Use_AD_Login tinyint NULL default 0    
    ,[Language] nvarchar(10) default 'eng'    
    ,Time_Zone int -- 用户喜好的时区
	,Change_Pwd_When_Next_Login tinyint default 0
    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Employee_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Employee_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
	);
EXEC('ALTER TABLE ps_Employee ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Employee_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

DECLARE @nSystemID BIGINT,@nGuestID BIGINT,@nAdminID BIGINT,@nLastID BIGINT
-- System和Guest账号不允许直接登录,不允许编辑更改
-- 添加System的默认History
INSERT INTO ps_Employee([Name]) VALUES('System');
SET @nSystemID=SCOPE_IDENTITY();
INSERT INTO ps_Employee_History(_Employee,[Name],Fullname,Change_Pwd_When_Next_Login,_Employee_Update) VALUES(@nSystemID,'System','System',0,@nSystemID);
SET @nLastID=SCOPE_IDENTITY();
UPDATE ps_Employee SET _Last_History= @nLastID WHERE _ID=@nSystemID;
-- 添加Guest的默认History
INSERT INTO ps_Employee([Name]) VALUES('Guest');
SET @nGuestID=SCOPE_IDENTITY();
INSERT INTO ps_Employee_History(_Employee,[Name],Fullname,Change_Pwd_When_Next_Login,_Employee_Update) VALUES(@nGuestID,'Guest','Guest',0,@nSystemID);
SET @nLastID=SCOPE_IDENTITY();
UPDATE ps_Employee SET _Last_History= @nLastID WHERE _ID=@nGuestID;
-- Admin默认密码123456
INSERT INTO ps_Employee([Name]) VALUES('Admin');
SET @nAdminID=SCOPE_IDENTITY();
INSERT INTO ps_Employee_History(_Employee,[Name],Fullname,Change_Pwd_When_Next_Login,[Password],_Employee_Update) VALUES(@nAdminID,'Admin','Administrator',1,'ea8753722c0e8ecde195d6adb8ba7c0d',@nSystemID);
SET @nLastID=SCOPE_IDENTITY();
UPDATE ps_Employee SET _Last_History= @nLastID WHERE _ID=@nAdminID;

--插入默认Site记录
INSERT INTO ps_Site_History(_Site,[Name],[Description],_Employee_Owner,_Employee_Update)
	SELECT _ID,[Name],'Default Site',@nSystemID,@nSystemID FROM ps_Site WHERE [Name]='Default';
UPDATE ps_Site SET _Last_History=tblHistory._ID FROM ps_Site tbl 
	INNER JOIN ps_Site_History tblHistory ON tbl._ID=tblHistory._Site AND tbl.[Name]='Default';


CREATE TABLE ps_Login_History(
	_ID BIGINT NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Employee BIGINT NOT NULL
		-- ,INDEX [IDX_Employee@ps_Login_History](_Employee)
		,CONSTRAINT [fk_Employee@ps_Login_History] FOREIGN KEY (_Employee) REFERENCES ps_Employee(_ID) ON DELETE CASCADE ON UPDATE CASCADE
    ,Login_Attempt int NOT NULL
    ,Login_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
	,From_IP nvarchar(16) NOT NULL
    ,From_Host nvarchar(50) NOT NULL
    ,From_MAC nvarchar(20) NULL    
    ,_Login_Result tinyint NOT NULL -- 0:Locked, 1:Noraml, 2:Reject
	);
    

CREATE TABLE ps_Group(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Group](_Site)		
		,CONSTRAINT [fk_Site@ps_Group] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
         
    ,[Name] nvarchar(50) NOT NULL 
		,CONSTRAINT [UNI(_Site,Name)@ps_Group] UNIQUE(_Site,[Name])
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Group] FOREIGN KEY (_Last_History) REFERENCES ps_Group_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Group ON ps_Group(_Last_History) WHERE _Last_History IS NOT NULL
CREATE TABLE ps_Group_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Group INT NOT NULL
		-- ,INDEX [IDX_Group@ps_Group_History](_Group)
		,CONSTRAINT [fk_Group@ps_Group_History] FOREIGN KEY (_Group) REFERENCES ps_Group (_ID) ON DELETE CASCADE ON UPDATE CASCADE
            
    ,[Name] nvarchar(50) NOT NULL UNIQUE
	,[Description] nvarchar(200) 
    
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Group_History](_Site)
		,CONSTRAINT [fk_Site@ps_Group_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Workshop INT NULL
		-- ,INDEX [IDX_Workshop@ps_Group_History](_Workshop)
		-- ,CONSTRAINT [fk_Workshop@ps_Group_History] FOREIGN KEY (_Workshop) REFERENCES ps_Workshop(_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,_Department INT NULL
		-- ,INDEX [IDX_Department@ps_Group_History](_Department)
		-- ,CONSTRAINT [fk_Department@ps_Group_History] FOREIGN KEY (_Department) REFERENCES ps_Department(_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,_Line INT NULL
		-- ,INDEX [IDX_Line@ps_Group_History](_Line)
		-- ,CONSTRAINT [fk_Line@ps_Group_History] FOREIGN KEY (_Line) REFERENCES ps_Line(_ID) ON DELETE CASCADE ON UPDATE CASCADE        
	
    ,_BU INT NULL
		-- ,INDEX [IDX_BU@ps_Group_History](_BU)
		-- ,CONSTRAINT [fk_BU@ps_Group_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,_Project INT NULL
		-- ,INDEX [IDX_Project@ps_Group_History](_Project)
		-- ,CONSTRAINT [fk_Project@ps_Group_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	
	,_Shift INT NULL
		-- ,INDEX [IDX_Shift@ps_Group_History](_Shift)
		-- ,CONSTRAINT [fk_Shift@ps_Group_History] FOREIGN KEY (_Shift) REFERENCES ps_Shift (_ID) --ON DELETE CASCADE ON UPDATE CASCADE  

    ,_Employee_Owner BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Group_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Group_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Group_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Group_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
    );
EXEC('ALTER TABLE ps_Group ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Group_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

INSERT INTO ps_Group([Name]) VALUES('System'),('Guests'),('Admins');
INSERT INTO ps_Group_History(_Group,[Name],_Employee_Owner,_Employee_Update)
	SELECT _ID, [Name],@nSystemID,@nSystemID FROM ps_Group;
UPDATE ps_Group SET ps_Group._Last_History=tblHistory._ID 
	FROM ps_Group INNER JOIN ps_Group_History tblHistory ON ps_Group._ID=tblHistory._Group; 
  
CREATE TABLE ps_Employee_In_Group(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
  
	,_Group INT NOT NULL		
		,CONSTRAINT [fk_Group@ps_Employee_In_Group] FOREIGN KEY (_Group) REFERENCES ps_Group(_ID) --ON DELETE CASCADE ON UPDATE CASCADE
    ,_Employee BIGINT NOT NULL		 
		,CONSTRAINT [fk_Employee@ps_Employee_In_Group] FOREIGN KEY (_Employee) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
        
		-- ,INDEX [IDX(_Group,_Employee)@ps_Employee_In_Group](_Group,_Employee)
	
	,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Employee_In_Group](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Employee_In_Group] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving -- 按_Group,_Employee分组最后一条记录的状态标记 
    );
INSERT INTO ps_Employee_In_Group(_Group,_Employee,_Employee_Update)
	SELECT tblGrp._ID,tblEmp._ID,@nSystemID FROM ps_Employee tblEmp,ps_Group tblGrp WHERE tblGrp.[Name]='System' AND tblEmp.[Name]='System'
    UNION SELECT tblGrp._ID,tblEmp._ID,@nSystemID FROM ps_Employee tblEmp,ps_Group tblGrp WHERE tblGrp.[Name]='Guests' AND tblEmp.[Name]='Guest'
    UNION SELECT tblGrp._ID,tblEmp._ID,@nSystemID FROM ps_Employee tblEmp,ps_Group tblGrp WHERE tblGrp.[Name]='Admins' AND tblEmp.[Name]='Admin';
     
 
CREATE TABLE ps_Preference(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY  
    ,[Name] nvarchar(50) NOT NULL UNIQUE
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Preference] FOREIGN KEY (_Last_History) REFERENCES ps_Preference_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Preference ON ps_Preference(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Preference_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Preference INT NOT NULL
		-- ,INDEX [IDX_Preference@ps_Preference_History](_Preference)
		,CONSTRAINT [fk_Preference@ps_Preference_History] FOREIGN KEY (_Preference) REFERENCES ps_Preference (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
    ,[Value] nvarchar(200)    
	,[Description] nvarchar(200)    
	
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Preference_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Preference_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    );    
INSERT INTO ps_Preference([Name])
	values('Default_Language')
    ,('Home_Page_Title')
    ,('Must_Login')
    ,('Logo_Picture')
    ,('Max_Login_Attempt')
    ,('Lock_Minute_After_Max_Login_Attempt')
	,('Folder_For_Attachments');
INSERT INTO ps_Preference_History(_Preference,[Value],_Employee_Update)
	SELECT _ID,'eng',@nSystemID FROM ps_Preference WHERE [Name]='Default_Language'
    UNION SELECT _ID,'Dashboard',@nSystemID FROM ps_Preference WHERE [Name]='Home_Page_Title'
    UNION SELECT _ID,'False',@nSystemID FROM ps_Preference WHERE [Name]='Must_Login'
    UNION SELECT _ID,'images/test.log',@nSystemID FROM ps_Preference WHERE [Name]='Logo_Picture'
    UNION SELECT _ID,'10',@nSystemID FROM ps_Preference WHERE [Name]='Max_Login_Attempt'
    UNION SELECT _ID,'30',@nSystemID FROM ps_Preference WHERE [Name]='Lock_Minute_After_Max_Login_Attempt'
	UNION SELECT _ID,'~/Attachments',@nSystemID FROM ps_Preference WHERE [Name]='Folder_For_Attachments';
UPDATE ps_Preference SET ps_Preference._Last_History=tblHistory._ID 
	FROM ps_Preference INNER JOIN ps_Preference_History tblHistory ON ps_Preference._ID=tblHistory._Preference; 

   
CREATE TABLE ps_Department(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		,CONSTRAINT [fk_Site@ps_Department] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
         
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(_Site,Name)@ps_Department] UNIQUE(_Site,[Name])
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Department] FOREIGN KEY (_Last_History) REFERENCES ps_Department_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Department ON ps_Department(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Department_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Department INT NOT NULL
		-- ,INDEX [IDX_Department@ps_Department_History](_Department)
		,CONSTRAINT [fk_Department@ps_Department_History] FOREIGN KEY (_Department) REFERENCES ps_Department (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
     
     ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Department_History](_Site)
		,CONSTRAINT [fk_Site_ID@ps_Department_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
          
    ,[Name] nvarchar(50) NOT NULL
	,[Description] nvarchar(200)
	,_Shift INT NULL
		-- ,INDEX [IDX_Shift@ps_Department_History](_Shift)
		-- ,CONSTRAINT [fk_Shift@ps_Department_History] FOREIGN KEY (_Shift) REFERENCES ps_Shift (_ID) --ON DELETE CASCADE ON UPDATE CASCADE      
	
    ,_Employee_Owner BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Department_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Department_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Department_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Department_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
    );
EXEC('ALTER TABLE ps_Department ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Department_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

INSERT INTO ps_Department([Name]) VALUES('Default');
INSERT INTO ps_Department_History(_Department,[Name],[Description],_Employee_Owner,_Employee_Update)
	SELECT _ID,[Name],'Default Department',@nSystemID,@nSystemID FROM ps_Department WHERE [Name]='Default';
UPDATE ps_Department SET _Last_History=tblHistory._ID 
	FROM ps_Department tbl INNER JOIN ps_Department_History tblHistory ON tbl._ID=tblHistory._Department AND tbl.[Name]='Default';
       
       
CREATE TABLE ps_Building(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		,CONSTRAINT [fk_Site@ps_Building] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
          
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(_Site,Name)@ps_Building] UNIQUE(_Site,[Name])
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Building] FOREIGN KEY (_Last_History) REFERENCES ps_Building_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Building ON ps_Building(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Building_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Building INT NOT NULL
		-- ,INDEX [IDX_Building@ps_Building_History](_Building)
		,CONSTRAINT [fk_Building@ps_Building_History] FOREIGN KEY (_Building) REFERENCES ps_Building (_ID) ON DELETE CASCADE ON UPDATE CASCADE
        
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Building_History](_Site)
		,CONSTRAINT [fk_Site@ps_Building_History] FOREIGN KEY (_Site) REFERENCES ps_Site(_ID) --ON DELETE CASCADE ON UPDATE CASCADE
    
    ,[Name] nvarchar(50) NOT NULL
	,[Description] nvarchar(200)    
	
    ,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Building_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Building_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Building_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Building_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
    );
EXEC('ALTER TABLE ps_Building ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Building_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

DECLARE @DefaultBuildingID INT
INSERT INTO ps_Building([Name]) VALUES('Default');
SET @DefaultBuildingID=SCOPE_IDENTITY();
INSERT INTO ps_Building_History(_Building,[Name],[Description],_Employee_Owner,_Employee_Update)
	SELECT _ID,[Name],'Default Building',@nSystemID,@nSystemID FROM ps_Building WHERE [Name]='Default';
UPDATE ps_Building SET _Last_History=tblHistory._ID 
	FROM  ps_Building tbl INNER JOIN ps_Building_History tblHistory ON tbl._ID=tblHistory._Building AND tbl.[Name]='Default';
    
    
CREATE TABLE ps_Workshop(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		  ,CONSTRAINT [fk_Site@ps_Workshop] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
    ,_Building INT NOT NULL
		,CONSTRAINT [fk_Building@ps_Workshop] FOREIGN KEY (_Building) REFERENCES ps_Building (_ID) ON DELETE CASCADE ON UPDATE CASCADE
        
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(_Site,_Building,Name)@ps_Workshop] UNIQUE(_Site,_Building,[Name])
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Workshop] FOREIGN KEY (_Last_History) REFERENCES ps_Workshop_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Workshop ON ps_Workshop(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Workshop_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Workshop INT NOT NULL
		-- ,INDEX [IDX_Workshop@ps_Workshop_History](_Workshop)
		,CONSTRAINT [fk_Workshop@ps_Workshop_History] FOREIGN KEY (_Workshop) REFERENCES ps_Workshop (_ID) ON DELETE CASCADE ON UPDATE CASCADE
        
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Workshop_History](_Site)
		,CONSTRAINT [fk_Site@ps_Workshop_History] FOREIGN KEY (_Site) REFERENCES ps_Site(_ID) --ON DELETE CASCADE ON UPDATE CASCADE
    ,_Building INT NOT NULL
		-- ,INDEX [IDX_Building@ps_Workshop_History](_Building)
		,CONSTRAINT [fk_Building@ps_Workshop_History] FOREIGN KEY (_Building) REFERENCES ps_Building (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
        
    ,[Name] nvarchar(50) NOT NULL
	,[Description] nvarchar(200)    
	
    ,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Workshop_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Workshop_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Workshop_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Workshop_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
    );
EXEC('ALTER TABLE ps_Workshop ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Workshop_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

INSERT INTO ps_Workshop(_Building,[Name]) VALUES(@DefaultBuildingID,'Default');
INSERT INTO ps_Workshop_History(_Building,_Workshop,[Name],[Description],_Employee_Owner,_Employee_Update)
	SELECT @DefaultBuildingID,_ID,[Name],'Default Workshop',@nSystemID,@nSystemID FROM ps_Workshop WHERE [Name]='Default';
UPDATE ps_Workshop SET _Last_History=tblHistory._ID 
	FROM ps_Workshop tbl INNER JOIN ps_Workshop_History tblHistory ON tbl._ID=tblHistory._Workshop AND tbl.[Name]='Default'; 

-- 具体的排班起始时间 
CREATE TABLE ps_Shift_Segment(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
	,_Site INT NOT NULL
		,CONSTRAINT [fk_Site@ps_Shift_Segment] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,[Name] nvarchar(50) NOT NULL 
		,CONSTRAINT [UNI(_Site,Name)@ps_Shift_Segment] UNIQUE(_Site,[Name])
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Shift_Segment] FOREIGN KEY (_Last_History) REFERENCES ps_Shift_Segment_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Shift_Segment ON ps_Shift_Segment(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Shift_Segment_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
	,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Shift_Segment_History](_Site)
		,CONSTRAINT [fk_Site@ps_Shift_Segment_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE

    ,_Shift_Segment INT NOT NULL
		-- ,INDEX [IDX_SS@ps_Shift_Segment_History](_Shift_Segment)
		,CONSTRAINT [fk_SS@ps_Shift_Segment_History] FOREIGN KEY (_Shift_Segment) REFERENCES ps_Shift_Segment (_ID) ON DELETE CASCADE ON UPDATE CASCADE

	,[Name] nvarchar(50) NOT NULL
	,[Description] nvarchar(200)        
    
    ,Start_Time Time NOT NULL -- 本地时间
    ,EndIntervalMinutes Float NOT NULL -- 与开始时间的分钟差
    
     ,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_EO@ps_Shift_Segment_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Shift_Segment_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_EU@ps_Shift_Segment_History](_Employee_Update)
		,CONSTRAINT [fk_EU@ps_Shift_Segment_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving    
    );
INSERT INTO ps_Shift_Segment([Name],_Site) VALUES('Day',@DefaultSiteID),('Night',@DefaultSiteID);
INSERT INTO ps_Shift_Segment_History(_Shift_Segment,_Site,[Name],[Description],Start_Time,EndIntervalMinutes,_Employee_Owner,_Employee_Update)
	SELECT _ID,@DefaultSiteID,[Name],'Shift Day','8:00',540,@nSystemID,@nSystemID FROM ps_Shift_Segment WHERE [Name]='Day'
    UNION SELECT _ID,@DefaultSiteID,[Name],'Shift Night','20:00',540,@nSystemID,@nSystemID FROM ps_Shift_Segment WHERE [Name]='Night';
UPDATE ps_Shift_Segment SET _Last_History=tblHistory._ID 
	FROM ps_Shift_Segment tbl INNER JOIN ps_Shift_Segment_History tblHistory ON tbl._ID=tblHistory._Shift_Segment;

-- 用于人员或生产线安排的班组
CREATE TABLE ps_Shift(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
	,_Site INT NOT NULL
		,CONSTRAINT [fk_Site@ps_Shift] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
		          
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(_Site,Name)@ps_Shift] UNIQUE(_Site,[Name])
	,_Last_History INT NULL
		 -- ,CONSTRAINT [fk_Last_History@ps_Shift] FOREIGN KEY (_Last_History) REFERENCES ps_Shift_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE	
	,_Shift_History_Batch INT NOT NULL -- 用HistoryID记录的排班批次号，只有在实际排班有所更改时才更换批次号
		-- ,INDEX [IDX_SHB@ps_Shift](_Shift_History_Batch)
		-- ,CONSTRAINT [fk_SHB@ps_Shift] FOREIGN KEY (_Shift_History_Batch) REFERENCES ps_Shift_History(_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Shift ON ps_Shift(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Shift_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Shift_History](_Site)
		,CONSTRAINT [fk_Site@ps_Shift_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Shift INT NOT NULL
		-- ,INDEX [IDX_Shift@ps_Shift_History](_Shift)
		,CONSTRAINT [fk_SG@ps_Shift_History] FOREIGN KEY (_Shift) REFERENCES ps_Shift (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
	,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)

	,_Employee_Create BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Shift_History](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Shift_History] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Create_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET()) 
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
	)
CREATE TABLE ps_Segment_In_Shift(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
	,_Shift_History_Batch INT NOT NULL -- 用HistoryID记录的排班批次号，只有在实际排班有所更改时才更换批次号
		-- ,INDEX [IDX_SHB@ps_Segment_In_Shift](_Shift_History_Batch)
		,CONSTRAINT [fk_SHB@ps_Segment_In_Shift] FOREIGN KEY (_Shift_History_Batch) REFERENCES ps_Shift_History(_ID) -- ON DELETE CASCADE ON UPDATE CASCADE

    ,_Shift INT NOT NULL
		-- ,INDEX [IDX_Shift@ps_Segment_In_Shift](_Shift)
		,CONSTRAINT [fk_Shift@ps_Segment_In_Shift] FOREIGN KEY (_Shift) REFERENCES ps_Shift(_ID) -- ON DELETE CASCADE ON UPDATE CASCADE
    
	,_Shift_Segment INT NOT NULL
		-- ,INDEX [IDX_SS@ps_Segment_In_Shift](_Shift_Segment)
		,CONSTRAINT [fk_SS@ps_Segment_In_Shift] FOREIGN KEY (_Shift_Segment) REFERENCES ps_Shift_Segment (_ID) -- ON DELETE CASCADE ON UPDATE CASCADE    
	)

-- 生产线列表
CREATE TABLE ps_Line(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Line](_Site)
		,CONSTRAINT [fk_Site@ps_Line] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
          
	,[Name] nvarchar(50) NOT NULL 
		,CONSTRAINT [UNI(_Site,Name)@ps_Line] UNIQUE(_Site,[Name])
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Line] FOREIGN KEY (_Last_History) REFERENCES ps_Line_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Line ON ps_Line(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Line_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Line INT NOT NULL
		-- ,INDEX [IDX_Line@ps_Line_History](_Line)
		,CONSTRAINT [fk_Line@ps_Line_History] FOREIGN KEY (_Line) REFERENCES ps_Line (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Line_History](_Site)
		,CONSTRAINT [fk_Site@ps_Line_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Workshop INT NULL
		-- ,INDEX [IDX_Workshop@ps_Line_History](_Workshop)
		,CONSTRAINT [fk_Workshop@ps_Line_History] FOREIGN KEY (_Workshop) REFERENCES ps_Workshop(_ID) --ON DELETE CASCADE ON UPDATE CASCADE        
	
    ,_BU INT NULL
		-- ,INDEX [IDX_BU@ps_Line_History](_BU)
		-- ,CONSTRAINT [fk_BU@ps_Line_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,_Project INT NULL
		-- ,INDEX [IDX_Project@ps_Line_History](_Project)
		-- ,CONSTRAINT [fk_Project@ps_Line_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE CASCADE ON UPDATE CASCADE

	,[Name] nvarchar(50) NOT NULL
	,[Description] nvarchar(200)
	,_Shift INT NULL
		-- ,INDEX [IDX_Shift@ps_Line_History](_Shift)
		,CONSTRAINT [fk_Shift@ps_Line_History] FOREIGN KEY (_Shift) REFERENCES ps_Shift (_ID) --ON DELETE CASCADE ON UPDATE CASCADE        
    
     ,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Line_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Line_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Line_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Line_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving    
    );
EXEC('ALTER TABLE ps_Line ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Line_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

INSERT INTO ps_Line([Name]) VALUES('Default');
INSERT INTO ps_Line_History(_Line,_Site,_Workshop,[Name],[Description],_Employee_Owner,_Employee_Update)
	SELECT tblA._ID,tblB._ID,tblC._ID,tblA.[Name],'Default Line',@nSystemID,@nSystemID FROM ps_Line tblA,ps_Site tblB,ps_Workshop tblC
		WHERE tblA.[Name]='Default' AND tblB.[Name]='Default' AND tblC.[Name]='Default';
UPDATE ps_Line SET _Last_History=tblHistory._ID 
	FROM ps_Line tbl INNER JOIN ps_Line_History tblHistory ON tbl._ID=tblHistory._Line AND tbl.[Name]='Default';
     
   
CREATE TABLE ps_BU(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		  ,CONSTRAINT [fk_Site@ps_BU] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
          
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(_Site,Name)@ps_BU] UNIQUE(_Site,[Name])
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_BU] FOREIGN KEY (_Last_History) REFERENCES ps_BU_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_BU ON ps_BU(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_BU_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_BU INT NOT NULL
		-- ,INDEX [IDX_Project@ps_BU_History](_BU)
		,CONSTRAINT [fk_Project@ps_BU_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) ON DELETE CASCADE ON UPDATE CASCADE
        
    ,[Name] nvarchar(50) NOT NULL
	,[Description] nvarchar(200)
    
	,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_BU_History](_Site)
		,CONSTRAINT [fk_Site@ps_BU_History] FOREIGN KEY (_Site) REFERENCES ps_Site(_ID) --ON DELETE CASCADE ON UPDATE CASCADE
    ,_Workshop INT NULL
		-- ,INDEX [IDX_Workshop@ps_BU_History](_Workshop)
		,CONSTRAINT [fk_Workshop@ps_BU_History] FOREIGN KEY (_Workshop) REFERENCES ps_Workshop (_ID) --ON DELETE CASCADE ON UPDATE CASCADE            
	
    ,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_BU_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_BU_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_BU_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_BU_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
    );
EXEC('ALTER TABLE ps_BU ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_BU_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');


INSERT INTO ps_BU([Name]) VALUES('Default');
INSERT INTO ps_BU_History(_BU,[Name],[Description],_Employee_Owner,_Employee_Update)
	SELECT _ID,[Name],'Default BU',@nSystemID,@nSystemID FROM ps_BU WHERE [Name]='Default';
UPDATE ps_BU SET _Last_History=tblHistory._ID FROM ps_BU tbl INNER JOIN ps_BU_History tblHistory ON tbl._ID=tblHistory._BU AND tbl.[Name]='Default';

    
CREATE TABLE ps_Project(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		  ,CONSTRAINT [fk_Site@ps_Project] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
          
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(_Site,Name)@ps_Project] UNIQUE(_Site,[Name])
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Project] FOREIGN KEY (_Last_History) REFERENCES ps_Project_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE	
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Project ON ps_Project(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Project_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
     ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Project_History](_Site)
		  ,CONSTRAINT [fk_Site@ps_Project_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE          
    ,_Project INT NOT NULL
		-- ,INDEX [IDX_Project@ps_Project_History](_Project)
		,CONSTRAINT [fk_Project@ps_Project_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
    ,_BU INT NOT NULL
		-- ,INDEX [IDX_BU@ps_Project_History](_BU)
		,CONSTRAINT [fk_BU@ps_Project_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) --ON DELETE CASCADE ON UPDATE CASCADE        
    ,[Name] nvarchar(50) NOT NULL
	,[Description] nvarchar(200)
	,Folder_For_Project_Attachments nvarchar(450) NULL    
	
    ,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Project_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Project_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
	,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Project_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Project_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
    );
EXEC('ALTER TABLE ps_Project ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Project_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

INSERT INTO ps_Project([Name]) VALUES('Default');
INSERT INTO ps_Project_History(_Project,_BU,[Name],[Description],_Employee_Owner,_Employee_Update)
	SELECT tblA._ID,tblB._ID,tblA.[Name],'Default Project',@nSystemID,@nSystemID FROM ps_Project tblA,ps_BU tblB WHERE tblA.[Name]='Default' AND tblB.[Name]='Default';
UPDATE ps_Project SET _Last_History=tblHistory._ID 
	FROM ps_Project tbl INNER JOIN ps_Project_History tblHistory ON tbl._ID=tblHistory._Project AND tbl.[Name]='Default';
    
    
CREATE TABLE ps_Page(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL		
		,CONSTRAINT [fk_Site@ps_Page] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,[Name] nvarchar(50) NOT NULL
		, CONSTRAINT [UNI(_Site,Name)@ps_Page] UNIQUE(_Site,Name)
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Page] FOREIGN KEY (_Last_History) REFERENCES ps_Page_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE	
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Page ON ps_Page(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Page_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Page_History](_Site)
		,CONSTRAINT [fk_Site@ps_Page_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE

	,_Page INT NOT NULL
		-- ,INDEX [IDX_Page@ps_Page_History](_Page)
		,CONSTRAINT [fk_Page@ps_Page_History] FOREIGN KEY (_Page) REFERENCES ps_Page (_ID) ON DELETE CASCADE ON UPDATE CASCADE
        
    
	,_BU INT NULL
		-- ,INDEX [IDX_BU@ps_Page_History](_BU)
		,CONSTRAINT [fk_BU@ps_Page_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Project INT NULL
		-- ,INDEX [IDX_Project@ps_Page_History](_Project)
		,CONSTRAINT [fk_Project@ps_Page_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
    
	,_Order INT  NOT NULL
    ,[Name] nvarchar(50) NOT NULL
	,[Description] nvarchar(200) 
    
	,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Page_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Page_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Page_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Page_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
    );  
EXEC('ALTER TABLE ps_Page ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Page_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

INSERT INTO ps_Page([Name]) VALUES('Default');
INSERT INTO ps_Page_History(_Page,_Order,[Name],[Description],_Employee_Owner,_Employee_Update)
	SELECT _ID,1,[Name],'Default Page',@nSystemID,@nSystemID FROM ps_Page WHERE [Name]='Default';
UPDATE ps_Page SET _Last_History=tblHistory._ID 
	FROM ps_Page tbl INNER JOIN ps_Page_History tblHistory ON tbl._ID=tblHistory._Page AND tbl.[Name]='Default';
    
    

CREATE TABLE ps_Object_Type(
	_ID int NOT NULL PRIMARY KEY          
    ,[Name] nvarchar(100) NOT NULL
)
INSERT INTO ps_Object_Type(_ID,[Name]) VALUES(1100,'All'),(1200,'Site') --下面的对象共用的中性组织方式
		,(2300,'Building'),(2410,'Workshop'),(2500,'Line'),(2600,'Station Catalog'),(2650,'Station Type'),(2700,'Station'),(2800,'Machine'),(2900,'Fixture')--物理对象组织方式		
		,(3100,'Manufacturer'),(3200,'Supplier'),(3300,'MPN') -- 物料供应对象的组织方式
		,(5100,'BU'),(5200,'Project'),(5300,'Part Family'),(5400,'Part Number'),(5500,'BOM')-- 商务对象组织方式		
		,(6100,'Page'),(6200,'Indicator Group'),(6300,'Indicator') -- 看板对象组织方式
		,(9100,'Department'),(9200,'Group'),(9300,'Employee') -- 人员对象组织方式    
CREATE TABLE ps_Access_Control(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY  
    
	,_Object_Type_People INT NOT NULL --需要控制访问的人员目标类型
		,CONSTRAINT [chk_Object_Type_People@ps_Access_Control] CHECK(_Object_Type_People>=9100 AND _Object_Type_People<=9999) --_Object_Type_People只允许人员对象类型
		,CONSTRAINT [fk_Object_Type_People@ps_Access_Control] FOREIGN KEY (_Object_Type_People) REFERENCES ps_Object_Type(_ID) --ON DELETE CASCADE ON UPDATE CASCADE 
	,_Object_ID_People BIGINT NOT NULL --需要控制访问的人员目标ID

	,_Object_Type INT NOT NULL --需要控制访问的目标类型
		,CONSTRAINT [fk_Object_Type@ps_Access_Control] FOREIGN KEY (_Object_Type) REFERENCES ps_Object_Type(_ID) --ON DELETE CASCADE ON UPDATE CASCADE 
	,_Object_ID BIGINT NOT NULL --需要控制访问的目标ID	
	
	,_Access_Type tinyint NOT NULL default -1 -- 1：完全控制, 2:查看对象及子对象, 0x04:编辑对象及子对象, 0x08:删除对象及子对象或将状态设为禁止, 0x10:添加或更改子对象的权限
	,_Allow tinyint NOT NULL default -1 -- -1:默认或继承, 0:拒绝, 1：允许

    ,_Employee_Create BIGINT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Access_Control](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Access_Control] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE 
    ,Create_Time datetimeoffset NULL default(SYSDATETIMEOFFSET())
	,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
);

--指示器所用的测量规格限制
CREATE TABLE ps_Measurement_Limit(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
	,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(Name)@ps_Measurement_Limit] UNIQUE([Name])
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Measurement_Limit] FOREIGN KEY (_Last_History) REFERENCES ps_Measurement_Limit_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE	
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Measurement_Limit ON ps_Measurement_Limit(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Measurement_Limit_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
	,_Measurement_Limit INT NOT NULL
		 ,CONSTRAINT [fk_Measurement_Limit@ps_Measurement_Limit_History] FOREIGN KEY (_Measurement_Limit) REFERENCES ps_Measurement_Limit (_ID) ON DELETE CASCADE ON UPDATE CASCADE
		        
    ,[Name] nvarchar(50) NOT NULL
	,[Description] nvarchar(200)    
	
	,Low_Limit float NULL
	,Update_Limit float NULL
	,LogicTarget nvarchar(450) NULL

	,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Measurement_Limit_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Measurement_Limit_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
    );
--指示器所用的测量周期
CREATE TABLE ps_Measurement_Period(
	_ID int NOT NULL PRIMARY KEY          
    ,[Name] nvarchar(100) NOT NULL
);
INSERT INTO ps_Measurement_Period(_ID,[Name]) VALUES(10,'Last Value'),(20,'Quarter Hour'),(25,'Half Hour'),(30,'Hour'),(40,'Shift'),(50,'Day'),(60,'Week'),(70,'Month'),(80,'Quarter'),(90,'Year');
--指示器所用的测量类型
CREATE TABLE ps_Measurement_Type(
	_ID int NOT NULL PRIMARY KEY          
    ,[Name] nvarchar(100) NOT NULL
	,[Description] nvarchar(200)
);
INSERT INTO ps_Measurement_Type(_ID,[Name]) VALUES(10,'Last Value'),(20,'Balance Quantity'),(30,'Feed Quantity'),(40,'Consume Quantity'),(50,'Deviation Quantity'),(60,'Total Times')
	,(70,'Utilization'),(80,'Output Efficiency'),(90,'Minumum'),(100,'Maxinum'),(130,'Average')
	,(200,'CPK'),(210,'Standard Deviation'),(220,'Standand Variance')
	,(250,'Min CPK'),(260,'Min Standard Deviation'),(270,'Min Standand Variance'),(280,'Max CPK'),(290,'Max Standard Deviation'),(300,'Max Standand Variance')
	,(500,'Fisrt Pass Quantity'),(510,'Total Pass Quantity'),(520,'Final Pass Quantity'),(530,'Fisrt Pass Yield'),(540,'Final Pass Yield')
	,(550,'Fisrt Fail Quantity'),(560,'Total Fail Quantity'),(570,'Final Fail Quantity'),(580,'Fisrt Fail Yield'),(590,'Final Fail Yield');
-- 指示器达到一定级别后所用的动作
CREATE TABLE ps_Indicator_Action(
	_ID int NOT NULL PRIMARY KEY          
    ,[Name] nvarchar(100) NOT NULL
	,[Description] nvarchar(200)
);
INSERT INTO ps_Indicator_Action(_ID,[Name]) VALUES(10,'Background Color'),(20,'Foreground Color'),(30,'Background Image'),(40,'Foreground Image'),(50,'Play Sound'),(60,'Play Video'),(70,'Change Text'),(80,'Hidden Indicator'),(90,'Show Indicator')
	,(100,'Send E-Mail To Employee Group'),(110,'CC E-Mail To Employee Group'),(120,'BCC E-Mail To Employee Group')
	,(200,'Send WeChat To Employee Group'),(210,'Send Short-Message To Employee Group'),(220,'Call Telephone To Employee Group')
	,(300,'Stop Source Machine'),(310,'Stop Other Machine'),(320,'Turn-On Alarm');
-- 由用户指定指示器动作值
CREATE TABLE ps_Indicator_Action_Value(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
	          
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(Name)@ps_Indicator_Action_Value] UNIQUE([Name])
	,_Last_History INT NULL
		 -- ,CONSTRAINT [fk_Last_History@ps_Indicator_Action_Value] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_Action_Value_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE	
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Indicator_Action_Value ON ps_Indicator_Action_Value(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Indicator_Action_Value_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Indicator_Action_Value INT NOT NULL
		-- ,INDEX [IDX_ICV@ps_Indicator_Action_Value_History](_Indicator_Action_Value)
		,CONSTRAINT [fk_ICV@ps_Indicator_Action_Value_History] FOREIGN KEY (_Indicator_Action_Value) REFERENCES ps_Indicator_Action_Value (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
	,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)
	,_Indicator_Action INT NOT NULL
		-- ,INDEX [IDX_IA@ps_Indicator_Action_Value_History](_Indicator_Action)
		,CONSTRAINT [fk_IA@ps_Indicator_Action_Value_History] FOREIGN KEY (_Indicator_Action) REFERENCES ps_Indicator_Action (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,Action_Value nvarchar(450) -- 某个动作的值，如果是改变颜色或文本为直接的文本或颜色值，其它的对应的ID值(包括图片、视频、音频)

	,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_EU@ps_Indicator_Action_Value_History](_Employee_Update)
		,CONSTRAINT [fk_EU@ps_Indicator_Action_Value_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET()) 
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
	)
-- 指示器达到一定级别后所用的一组动作
CREATE TABLE ps_Indicator_Action_Group(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
	          
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(Name)@ps_Indicator_Action_Group] UNIQUE([Name])
	,_Last_History INT NULL
		 -- ,CONSTRAINT [fk_Last_History@ps_Indicator_Action_Group] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE	
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Indicator_Action_Group ON ps_Indicator_Action_Group(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Indicator_Action_Group_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Indicator_Action_Group INT NOT NULL
		-- ,INDEX [IDX_ICG@ps_Indicator_Action_Group_History](_Indicator_Action_Group)
		,CONSTRAINT [fk_ICG@ps_Indicator_Action_Group_History] FOREIGN KEY (_Indicator_Action_Group) REFERENCES ps_Indicator_Action_Group (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
	,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)

	,_Employee_Create BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Indicator_Action_Group_History](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Indicator_Action_Group_History] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Create_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET()) 
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
	)
CREATE TABLE ps_Indicator_Action_Value_In_Group(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Indicator_Action_Group INT NOT NULL		
		,CONSTRAINT [fk_ICG_History@ps_Indicator_Action_Value_In_Group] FOREIGN KEY (_Indicator_Action_Group) REFERENCES ps_Indicator_Action_Group (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
	,_Indicator_Action_Value INT NOT NULL
		,CONSTRAINT [fk_ICV@ps_Indicator_Action_Value_In_Group] FOREIGN KEY (_Indicator_Action_Value) REFERENCES ps_Indicator_Action_Value (_ID) ON DELETE CASCADE ON UPDATE CASCADE    

		-- ,INDEX [IDX_IGV@ps_Indicator_Action_Value_In_Group](_Indicator_Action_Group,_Indicator_Action_Value)

	,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_EU@ps_Indicator_Action_Value_In_Group](_Employee_Update)
		,CONSTRAINT [fk_EU@ps_Indicator_Action_Value_In_Group] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving -- 按_Indicator_Action_Group,_Indicator_Action_Value分组最后一条记录的状态标记 
	)

-- 一个指示器(Indicator)只表示一个指标，当到达不同的阈值时，可以采取不同的动作(发邮件、短信、微信、拔打电话，或停止指定的机器，或触发指定的报警器等)
CREATE TABLE ps_Indicator(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
	          
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(Name)@ps_Indicator] UNIQUE([Name])
	,_Last_History INT NULL
		 -- ,CONSTRAINT [fk_Last_History@ps_Indicator] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE	
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Indicator ON ps_Indicator(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Indicator_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Indicator INT NOT NULL
		-- ,INDEX [IDX_Indicator@ps_Indicator_History](_Indicator)
		,CONSTRAINT [fk_Indicator@ps_Indicator_History] FOREIGN KEY (_Indicator) REFERENCES ps_Indicator (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
	,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)

	,_Object_Type_First INT NOT NULL --需要指示的目标对象类型
		,CONSTRAINT [chk_Object_Type_First@ps_Indicator_History] CHECK(_Object_Type_First<>6100) --指示的目录类型不能是页面自身
		,CONSTRAINT [fk_Object_Type_First@ps_Indicator_History] FOREIGN KEY (_Object_Type_First) REFERENCES ps_Object_Type(_ID) --ON DELETE CASCADE ON UPDATE CASCADE 
	,_Object_ID_First BIGINT NOT NULL --需要指示的目标对象ID
	
	,_Object_Type_Second INT NULL --第二个需要指示的目标对象类型
		,CONSTRAINT [chk_Object_Type_Second@ps_Indicator_History] CHECK(_Object_Type_Second<>6100) --指示的目标类型不能是页面自身
		,CONSTRAINT [fk_Object_Type_Second@ps_Indicator_History] FOREIGN KEY (_Object_Type_Second) REFERENCES ps_Object_Type(_ID) --ON DELETE CASCADE ON UPDATE CASCADE 
	,_Object_ID_Second BIGINT NOT NULL --第二个需要指示的目标对象ID

	,_Object_Type_Thrid INT NULL --第三个需要指示的目标对象类型
		,CONSTRAINT [chk_Object_Type_Thrid@ps_Indicator_History] CHECK(_Object_Type_Thrid<>6100) --指示的目标类型不能是页面自身
		,CONSTRAINT [fk_Object_Type_Thrid@ps_Indicator_History] FOREIGN KEY (_Object_Type_Thrid) REFERENCES ps_Object_Type(_ID) --ON DELETE CASCADE ON UPDATE CASCADE 
	,_Object_ID_Thrid BIGINT NULL --第三个需要指示的目标对象ID

	,_Object_Type_Fourth INT NULL --第四个需要指示的目标对象类型
		,CONSTRAINT [chk_Object_Type_Fourth@ps_Indicator_History] CHECK(_Object_Type_Fourth<>6100) --指示的目标类型不能是页面自身
		,CONSTRAINT [fk_Object_Type_Fourth@ps_Indicator_History] FOREIGN KEY (_Object_Type_Fourth) REFERENCES ps_Object_Type(_ID) --ON DELETE CASCADE ON UPDATE CASCADE 
	,_Object_ID_Fourth BIGINT NULL --第四个需要指示的目标对象ID
			 
	,_Measurement_Period  INT NOT NULL
		,CONSTRAINT [fk_Measurement_Period@ps_Indicator_History] FOREIGN KEY (_Measurement_Period) REFERENCES ps_Measurement_Period(_ID) --ON DELETE CASCADE ON UPDATE CASCADE 
	,_Measurement_Type  INT NOT NULL
		,CONSTRAINT [fk_Measurement_Type@ps_Indicator_History] FOREIGN KEY (_Measurement_Type) REFERENCES ps_Measurement_Type(_ID) --ON DELETE CASCADE ON UPDATE CASCADE 

    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_EU@ps_Indicator_History](_Employee_Update)
		,CONSTRAINT [fk_EU@ps_Indicator_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET()) 
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
    );
CREATE TABLE ps_Indicator_Level(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Indicator INT NOT NULL
		-- ,INDEX [IDX_Indicator@ps_Indicator_Level](_Indicator)
		,CONSTRAINT [fk_Indicator@ps_Indicator_Level] FOREIGN KEY (_Indicator) REFERENCES ps_Indicator (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
	,_Priority INT NOT NULL -- 当前级别的优先级
	,_Measurement_Limit  INT NOT NULL
		,CONSTRAINT [fk_Measurement_Limit@ps_Indicator_Level] FOREIGN KEY (_Measurement_Limit) REFERENCES ps_Measurement_Limit(_ID) --ON DELETE CASCADE ON UPDATE CASCADE

	,_Indicator_Action_Group INT NULL --达到当前指标指定的一组动作
		,CONSTRAINT [fk_IAG@ps_Indicator_Level] FOREIGN KEY (_Indicator_Action_Group) REFERENCES ps_Indicator_Action_Group (_ID) --ON DELETE CASCADE ON UPDATE CASCADE

	,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_EU@ps_Indicator_Level](_Employee_Update)
		,CONSTRAINT [fk_EU@ps_Indicator_Level] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET()) 
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
	);

CREATE TABLE ps_Indicator_Value( -- 各个周期的最新指示值
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Indicator INT NOT NULL
		-- ,INDEX [IDX_Indicator@ps_Indicator_Value](_Indicator)
		,CONSTRAINT [fk_Indicator@ps_Indicator_Value] FOREIGN KEY (_Indicator) REFERENCES ps_Indicator (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	
	,Date_Time_Period datetimeoffset NULL--  当前值所表示的主周期，一刻钟（Quarter Hour)用当前时刻的第一分钟取整表示，'Week'和'Quarter'用该周期的第一天取整表示,'Shift'用当天取整并附加下一个字段
	,Date_Time_Period_Addition BIGINT NULL -- 周期字段的附加值，当为'Last One'时，为该类型项目的最新条目ID，当'Shift'时，为ps_Shift表的ID

	,floatValue float NULL
	,LogicValue nvarchar(450) NULL

	 ,_Indicator_Level INT NOT NULL
		-- ,INDEX [IDX_Indicator_Level@ps_Indicator_Value](_Indicator_Level) -- 当前值所达到指示级别
		,CONSTRAINT [fk_Indicator_Level@ps_Indicator_Value] FOREIGN KEY (_Indicator_Level) REFERENCES ps_Indicator_Level (_ID)
	);
--解释原因类型列表
CREATE TABLE ps_Indicator_Reason(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(Name)@ps_Indicator_Reason] UNIQUE([Name])
	,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Indicator_Reason] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_Reason_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX UNI_Last_History@ps_Indicator_Reason ON ps_Indicator_Reason(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Indicator_Reason_History(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,_Indicator_Reason INT NOT NULL
		-- ,INDEX [IDX_Indicator_Reason@ps_Indicator_Reason_History](_Indicator_Reason)
		,CONSTRAINT [fk_Indicator_Reason@ps_Indicator_Reason_History] FOREIGN KEY (_Indicator_Reason) REFERENCES ps_Indicator_Reason (_ID) ON DELETE CASCADE ON UPDATE CASCADE
         
    ,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)
      
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Indicator_Reason_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Indicator_Reason_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
);
-- 可能的人员对某个指标值的解释
CREATE TABLE ps_Indicator_Explanation (	
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Indicator_Value INT NOT NULL
		-- ,INDEX [IDX_Indicator@ps_Indicator_Explanation](_Indicator_Value)
		,CONSTRAINT [fk_Indicator_Value@ps_Indicator_Explanation] FOREIGN KEY (_Indicator_Value) REFERENCES ps_Indicator_Value (_ID) ON DELETE CASCADE ON UPDATE CASCADE

	,_Indicator_Reason INT NOT NULL
		-- ,INDEX [IDX_Indicator_Reason@ps_Indicator_Explanation](_Indicator_Reason)
		,CONSTRAINT [fk_Indicator_Reason@ps_Indicator_Explanation] FOREIGN KEY (_Indicator_Reason) REFERENCES ps_Indicator_Reason (_ID) ON DELETE CASCADE ON UPDATE CASCADE    
	,Explanation  nvarchar(max) NOT  NULL

	,_Employee_Create BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Indicator_Explanation](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Indicator_Explanation] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Create_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET()) 
)
-- 解释时可能提交的多个附件
CREATE TABLE ps_Indicator_Explanation_Attachment (	
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Indicator_Explanation INT NOT NULL
		-- ,INDEX [IDX_Indicator_Explanation@ps_Indicator_Explanation_Attachment](_Indicator_Explanation)
		,CONSTRAINT [fk_Indicator_Explanation@ps_Indicator_Explanation_Attachment] FOREIGN KEY (_Indicator_Explanation) REFERENCES ps_Indicator_Explanation (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	,_Attachment BIGINT NULL 
		,CONSTRAINT [fk_Attachment@ps_Indicator_Explanation_Attachment] FOREIGN KEY (_Attachment) REFERENCES ps_Attachment (_ID) --ON DELETE CASCADE ON UPDATE CASCADE	
)

-- 指示器组合
CREATE TABLE ps_Indicator_Group(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
	          
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(Name)@ps_Indicator_Group] UNIQUE([Name])
	,_Last_History INT NULL
		 -- ,CONSTRAINT [fk_Last_History@ps_Indicator_Group] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_Group_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE	
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Indicator_Group ON ps_Indicator_Group(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Indicator_Group_History(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Indicator_Group INT NOT NULL
		-- ,INDEX [IDX_IG@ps_Indicator_Group_History](_Indicator_Group)
		,CONSTRAINT [fk_IG@ps_Indicator_Group_History] FOREIGN KEY (_Indicator_Group) REFERENCES ps_Indicator_Group (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
	,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)

	,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_EU@ps_Indicator_Group_History](_Employee_Update)
		,CONSTRAINT [fk_EU@ps_Indicator_Group_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET()) 
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
	)
CREATE TABLE ps_Indicator_In_Group(
	_ID int NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Indicator_Group INT NOT NULL		
		,CONSTRAINT [fk_IG@ps_Indicator_In_Group] FOREIGN KEY (_Indicator_Group) REFERENCES ps_Indicator_Group (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    
	,_Indicator INT NOT NULL		
		,CONSTRAINT [fk_Indicator@ps_Indicator_In_Group] FOREIGN KEY (_Indicator) REFERENCES ps_Indicator (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	
		-- ,INDEX [IDX(_Indicator_Group,_Indicator)@ps_Indicator_In_Group](_Indicator_Group,_Indicator)
	
	,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_EU@ps_Indicator_In_Group](_Employee_Update)
		,CONSTRAINT [fk_EU@ps_Indicator_In_Group] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET()) 
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
	)


-- 一个指示器(Indicator)或指示组放在页面上的位置
CREATE TABLE ps_Indicator_In_Page(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
   ,_Last_History INT NULL
		 -- ,CONSTRAINT [fk_Last_History@ps_Indicator_In_Page] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_In_Page_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE	
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Indicator_In_Page ON ps_Indicator_In_Page(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Indicator_In_Page_History(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,_Indicator_In_Page INT NOT NULL
		 ,CONSTRAINT [fk_IIG@ps_Indicator_In_Page_History] FOREIGN KEY (_Indicator_In_Page) REFERENCES ps_Indicator_In_Page (_ID) ON DELETE CASCADE ON UPDATE CASCADE
         
    ,_Page INT NOT NULL
		-- ,INDEX [IDX_Page@ps_Indicator_In_Page_History](_Page)
		,CONSTRAINT [fk_Page@ps_Indicator_In_Page_History] FOREIGN KEY (_Page) REFERENCES ps_Page (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Indicator INT NULL
		-- ,INDEX [IDX_Indicator@ps_Indicator_In_Page_History](_Indicator)
		,CONSTRAINT [fk_Indicator@ps_Indicator_In_Page_History] FOREIGN KEY (_Indicator) REFERENCES ps_Indicator(_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Indicator_Group INT NULL
		-- ,INDEX [IDX_IG@ps_Indicator_In_Page_History](_Indicator_Group)
		,CONSTRAINT [fk_IG@ps_Indicator_In_Page_History] FOREIGN KEY (_Indicator_Group) REFERENCES ps_Indicator_Group(_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,X int not NULL
    ,Y int not null	
	    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Indicator_In_Page_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Indicator_In_Page_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
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
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,[Name] nvarchar(100) NOT NULL UNIQUE
    ,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Station_Template] FOREIGN KEY (_Last_History) REFERENCES ps_Station_Template_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX UNI_Last_History@ps_Station_Template ON ps_Station_Template(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Station_Template_History(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,_Station_Template INT NOT NULL
		-- ,INDEX [IDX_Station_Template@ps_Station_Template_History](_Station_Template)
		,CONSTRAINT [fk_Station_Template@ps_Station_Template_History] FOREIGN KEY (_Station_Template) REFERENCES ps_Station_Template (_ID) ON DELETE CASCADE ON UPDATE CASCADE
         
    ,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)
    ,Handle_Assembly nvarchar(100) NULL
    
	,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Station_Template_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Station_Template_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Station_Template_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Station_Template_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
);

-- 站位分类目录
CREATE TABLE ps_Station_Catalog(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
	,_Site INT NOT NULL	
		,CONSTRAINT [fk_Site@ps_Station_Catalog] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE

    ,[Name] nvarchar(100) NOT NULL
		,CONSTRAINT [UNI(_Site,Name)@ps_Station_Catalog] UNIQUE(_Site,[Name])
    ,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Station_Catalog] FOREIGN KEY (_Last_History) REFERENCES ps_Station_Catalog_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX UNI_Last_History@ps_Station_Catalog ON ps_Station_Catalog(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Station_Catalog_History(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
	,_Site INT NOT NULL	
		,CONSTRAINT [fk_Site@ps_Station_Catalog_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) -- ON DELETE CASCADE ON UPDATE CASCADE
    ,_Station_Catalog INT NOT NULL		
		,CONSTRAINT [fk_Station_Catalog@ps_Station_Catalog_History] FOREIGN KEY (_Station_Catalog) REFERENCES ps_Station_Catalog (_ID) ON DELETE CASCADE ON UPDATE CASCADE

		-- ,INDEX [IDX(_Site,_Station_Catalog)@ps_Station_Catalog_History](_Site,_Station_Catalog)
         
    ,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)
    
	,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Station_Catalog_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Station_Catalog_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Station_Catalog_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Station_Catalog_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
);

CREATE TABLE ps_Station_Type(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		  ,CONSTRAINT [fk_Site@ps_Station_Type] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    ,_Project INT NULL
		,CONSTRAINT [fk_Project@ps_Station_Type] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
		      
    ,[Name] nvarchar(100) NOT NULL
		,CONSTRAINT [UNI(_Site,_Project,Name)@ps_Station_Type] UNIQUE(_Site,_Project,[Name])
    ,_Last_History INT NULL UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Station_Type] FOREIGN KEY (_Last_History) REFERENCES ps_Station_Type_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX UNI_Last_History@ps_Station_Type ON ps_Station_Type(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Station_Type_History(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Station_Type_History](_Site)
		,CONSTRAINT [fk_Site@ps_Station_Type_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
    ,_Project INT NULL
		-- ,INDEX [IDX_Project@ps_Station_Type_History](_Project)
		,CONSTRAINT [fk_Project@ps_Station_Type_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Station_Type INT NOT NULL 
		 ,CONSTRAINT [fk_Station_Type@ps_Station_Type_History] FOREIGN KEY (_Station_Type) REFERENCES ps_Station_Type (_ID) --ON DELETE CASCADE ON UPDATE CASCADE

	,_Station_Catalog INT NOT NULL
		-- ,INDEX [IDX_Station_Catalog@ps_Station_Type_History](_Station_Template)
		,CONSTRAINT [fk_Station_Catalog@ps_Station_Type_History] FOREIGN KEY (_Station_Catalog) REFERENCES ps_Station_Catalog (_ID) --ON DELETE CASCADE ON UPDATE CASCADE		           
    
    ,_Station_Template INT NOT NULL 
		 ,CONSTRAINT [fk_Station_Template@ps_Station_Type_History] FOREIGN KEY (_Station_Template) REFERENCES ps_Station_Template (_ID) --ON DELETE CASCADE ON UPDATE CASCADE         
    ,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)
	,Handle_Assembly nvarchar(100) NULL
    ,Folder_For_Attachments nvarchar(450) NULL 

	,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Station_Type_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Station_Type_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Station_Type_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Station_Type_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
);
EXEC('ALTER TABLE ps_Station_Type ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Station_Type_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

CREATE TABLE ps_Station(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		  ,CONSTRAINT [fk_Site@ps_Station] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	
    ,[Name] nvarchar(100) NOT NULL
		,CONSTRAINT [UNI(_Site,Name)@ps_Station] UNIQUE(_Site,[Name])
    ,_Last_History INT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Station] FOREIGN KEY (_Last_History) REFERENCES ps_Station_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE        
);
CREATE UNIQUE INDEX UNI_Last_History@ps_Station ON ps_Station(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Station_History(
	_ID int NOT NULL IDENTITY(1,1) PRIMARY KEY     
	 ,_Site INT NOT NULL		
		,CONSTRAINT [fk_Site@ps_Station_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	 ,_Station INT NOT NULL		
		,CONSTRAINT [fk_Station@ps_Station_History] FOREIGN KEY (_Station) REFERENCES ps_Station (_ID) ON DELETE CASCADE ON UPDATE CASCADE    
     ,_Line INT NOT NULL
		-- ,INDEX [IDX_Line@ps_Station_History](_Line)
		,CONSTRAINT [fk_Line@ps_Station_History] FOREIGN KEY (_Line) REFERENCES ps_Line (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	 ,_Station_Type INT NOT NULL
		-- ,INDEX [IDX_Station_Type@ps_Station_History](_Station_Type)
		,CONSTRAINT [fk_Station_Type@ps_Station_History] FOREIGN KEY (_Station_Type) REFERENCES ps_Station_Type (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
   
		-- ,INDEX [IDX(_Site,_Station,_Line,_Station_Type)@ps_Station_History](_Site,_Station,_Line,_Station_Type)

    ,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)
	,HostName nvarchar(100)
    ,MAC_Address nvarchar(20)
    ,Guid_ID nvarchar(50)
    
	,_BU INT NULL
		-- ,INDEX [IDX_BU@ps_Station_History](_BU)
		,CONSTRAINT [fk_BU@ps_Station_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Project INT NULL
		-- ,INDEX [IDX_Project@ps_Station_History](_Project)
		,CONSTRAINT [fk_Project@ps_Station_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
    
    ,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Station_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Station_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Station_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Station_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
);
EXEC('ALTER TABLE ps_Station ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Station_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

CREATE TABLE ps_Fixture(
	_ID BIGINT NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		  ,CONSTRAINT [fk_Site@ps_Fixture] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
          
    ,[Name] nvarchar(50) NOT NULL
		,CONSTRAINT [UNI(_Site,Name)@ps_Fixture] UNIQUE(_Site,[Name])
	,_Last_History BIGINT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Fixture] FOREIGN KEY (_Last_History) REFERENCES ps_Fixture_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE
    );
CREATE UNIQUE INDEX UNI_Last_History@ps_Fixture ON ps_Fixture(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Fixture_History(
	_ID BIGINT NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL		
		,CONSTRAINT [fk_Site@ps_Fixture_History] FOREIGN KEY (_Site) REFERENCES ps_Site(_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Fixture BIGINT NOT NULL		
		,CONSTRAINT [fk_Fixture@ps_Fixture_History] FOREIGN KEY (_Fixture) REFERENCES ps_Fixture (_ID) ON DELETE CASCADE ON UPDATE CASCADE
        
		-- ,INDEX [IDX(_Site,_Fixture)@ps_Fixture_History](_Site,_Fixture)

    ,Guid_ID nvarchar(50) NULL
    ,[Name] nvarchar(50) NOT NULL
	,[Description] nvarchar(200)
    	
    ,_Workshop INT NULL
		-- ,INDEX [IDX_Workshop@ps_Fixture_History](_Workshop)
		,CONSTRAINT [fk_Workshop@ps_Fixture_History] FOREIGN KEY (_Workshop) REFERENCES ps_Workshop (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Line INT NULL
		-- ,INDEX [IDX_Line@ps_Fixture_History](_Line)
		,CONSTRAINT [fk_Line@ps_Fixture_History] FOREIGN KEY (_Line) REFERENCES ps_Line (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
    ,_Station INT NULL
		-- ,INDEX [IDX_Station@ps_Fixture_History](_Station)
		,CONSTRAINT [fk_Station@ps_Fixture_History] FOREIGN KEY (_Station) REFERENCES ps_Station (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
        
    ,_BU INT NULL
		-- ,INDEX [IDX_BU@ps_Fixture_History](_BU)
		,CONSTRAINT [fk_BU@ps_Fixture_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Project INT NULL
		-- ,INDEX [IDX_Project@ps_Fixture_History](_Project)
		,CONSTRAINT [fk_Project@ps_Fixture_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	
    ,_Employee_Owner BIGINT NULL
		-- ,INDEX [IDX_Employee_Owner@ps_Fixture_History](_Employee_Owner)
		,CONSTRAINT [fk_Employee_Owner@ps_Fixture_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID) --ON DELETE CASCADE ON UPDATE CASCADE    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Fixture_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Fixture_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
    );
EXEC('ALTER TABLE ps_Fixture ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Fixture_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

INSERT INTO ps_Fixture([Name]) VALUES('Default');
INSERT INTO ps_Fixture_History(_Fixture,[Name],[Description],_Employee_Owner,_Employee_Update)
	SELECT _ID,[Name],'Default Fixture',@nSystemID,@nSystemID FROM ps_Fixture WHERE [Name]='Default';
UPDATE ps_Fixture SET _Last_History=tblHistory._ID 
	FROM ps_Fixture tbl INNER JOIN ps_Fixture_History tblHistory ON tbl._ID=tblHistory._Fixture AND tbl.[Name]='Default';

CREATE TABLE ps_Part_Family(
	_ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Part_Family](_Site)
		,CONSTRAINT [fk_Site@ps_Part_Family] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	
    ,[Name] nvarchar(100) NOT NULL
		,CONSTRAINT [UNI(_Site,Name)@ps_Part_Family] UNIQUE(_Site,[Name])
    ,_Last_History BIGINT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Part_Family] FOREIGN KEY (_Last_History) REFERENCES ps_Part_Family_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE        
);
CREATE UNIQUE INDEX UNI_Last_History@ps_Part_Family ON ps_Part_Family(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Part_Family_History(
	_ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY     
    ,_Site INT NOT NULL
		,CONSTRAINT [fk_Site@ps_Part_Family_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Part_Family BIGINT NOT NULL		
		,CONSTRAINT [fk_Part_Family@ps_Part_Family_History] FOREIGN KEY (_Part_Family) REFERENCES ps_Part_Family (_ID) ON DELETE CASCADE ON UPDATE CASCADE    
       
		-- ,INDEX [IDX(_Site,_Part_Family)@ps_Part_Family_History](_Site,_Part_Family)

    ,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)
    ,_External_Part_Family INT NULL
        
	,_BU INT NULL
		-- ,INDEX [IDX_BU@ps_Part_Family_History](_BU)
		,CONSTRAINT [fk_BU@ps_Part_Family_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Project INT NULL
		-- ,INDEX [IDX_Project@ps_Part_Family_History](_Project)
		,CONSTRAINT [fk_Project@ps_Part_Family_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Part_Family_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Part_Family_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
);
EXEC('ALTER TABLE ps_Part_Family ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Part_Family_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');


INSERT INTO ps_Part_Family([Name]) VALUES('Default');
INSERT INTO ps_Part_Family_History(_Part_Family,[Name],[Description],_Employee_Update)
	SELECT _ID,[Name],'Default Part Family',@nSystemID FROM ps_Part_Family WHERE [Name]='Default';
UPDATE ps_Part_Family SET _Last_History=tblHistory._ID 
	FROM ps_Part_Family tbl INNER JOIN ps_Part_Family_History tblHistory ON tbl._ID=tblHistory._Part_Family AND tbl.[Name]='Default';

CREATE TABLE ps_Part_Number(
	_ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		  ,CONSTRAINT [fk_Site@ps_Part_Number] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) ON DELETE CASCADE ON UPDATE CASCADE
	
    ,[Name] nvarchar(100) NOT NULL
		,CONSTRAINT [UNI(_Site,Name)@ps_Part_Number] UNIQUE(_Site,[Name])
    ,_Last_History BIGINT NULL --UNIQUE
		 -- ,CONSTRAINT [fk_Last_History@ps_Part_Number] FOREIGN KEY (_Last_History) REFERENCES ps_Part_Number_History (_ID) ON DELETE CASCADE ON UPDATE CASCADE        
);
CREATE UNIQUE INDEX UNI_Last_History@ps_Part_Number ON ps_Part_Number(_Last_History) WHERE _Last_History IS NOT NULL;
CREATE TABLE ps_Part_Number_History(
	_ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY     
     ,_Site INT NOT NULL		
		,CONSTRAINT [fk_Site@ps_Part_Number_History] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Part_Number BIGINT NOT NULL		
		,CONSTRAINT [fk_Part_Number@ps_Part_Number_History] FOREIGN KEY (_Part_Number) REFERENCES ps_Part_Number (_ID) ON DELETE CASCADE ON UPDATE CASCADE        
	,_Part_Family BIGINT NULL		
		,CONSTRAINT [fk_Part_Family@ps_Part_Number_History] FOREIGN KEY (_Part_Family) REFERENCES ps_Part_Family (_ID) -- ON DELETE CASCADE ON UPDATE CASCADE   

		-- ,INDEX [IDX(_Site,_Part_Number,_Part_Family)@ps_Part_Number_History](_Site,_Part_Number,_Part_Family)   

    ,[Name] nvarchar(100) NOT NULL 
	,[Description] nvarchar(200)
    ,_External_Part_Number BIGINT NULL
    ,UOM nvarchar(50) NULL
	,IsUnit smallint NOT NULL default 0
    
	,_BU INT NULL
		-- ,INDEX [IDX_BU@ps_Part_Number_History](_BU)
		,CONSTRAINT [fk_BU@ps_Part_Number_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,_Project INT NULL
		-- ,INDEX [IDX_Project@ps_Part_Number_History](_Project)
		,CONSTRAINT [fk_Project@ps_Part_Number_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Part_Number_History](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Part_Number_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID) --ON DELETE CASCADE ON UPDATE CASCADE
	,Update_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET())
    ,_Status tinyint NOT NULL default 1 -- 0x0:Locked, 0x01:Noraml, 0x10:Draft, 0x20:Approving
);
EXEC('ALTER TABLE ps_Part_Number ADD DEFAULT('+@DefaultSiteID+') FOR _Site');
EXEC('ALTER TABLE ps_Part_Number_History ADD DEFAULT('+@DefaultSiteID+') FOR _Site');

INSERT INTO ps_Part_Number([Name]) VALUES('Default');
INSERT INTO ps_Part_Number_History(_Part_Number,[Name],[Description],_Employee_Update)
	SELECT _ID,[Name],'Default Part Number',@nSystemID FROM ps_Part_Number WHERE [Name]='Default';
UPDATE ps_Part_Number SET _Last_History=tblHistory._ID 
	FROM ps_Part_Number tbl INNER JOIN ps_Part_Number_History tblHistory ON tbl._ID=tblHistory._Part_Number AND tbl.[Name]='Default';
    

    
-- 追加交叉外键的约束
ALTER TABLE ps_Site ADD CONSTRAINT [fk_Last_History@ps_Site] FOREIGN KEY (_Last_History) REFERENCES ps_Site_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Site_History ADD CONSTRAINT [fk_Employee_Owner@ps_Site_History] FOREIGN KEY (_Employee_Owner) REFERENCES ps_Employee(_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Site_History ADD CONSTRAINT [fk_Employee_Update@ps_Site_History] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Attachment ADD CONSTRAINT [fk_Employee_Create@ps_Attachment] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee(_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Employee ADD CONSTRAINT [fk_Last_History@ps_Employee] FOREIGN KEY (_Last_History) REFERENCES ps_Employee_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Employee ADD CONSTRAINT [fk_Last_Login_History@ps_Employee] FOREIGN KEY (_Last_Login_History) REFERENCES ps_Login_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Employee_History ADD CONSTRAINT [fk_BU@ps_Employee_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Employee_History ADD CONSTRAINT [fk_Project@ps_Employee_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Employee_History ADD CONSTRAINT [fk_Department@ps_Employee_History] FOREIGN KEY (_Department) REFERENCES ps_Department (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Employee_History ADD CONSTRAINT [fk_Employee_Leader@ps_Employee_History] FOREIGN KEY (_Employee_Leader) REFERENCES ps_Employee (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Group ADD CONSTRAINT [fk_Last_History@ps_Group] FOREIGN KEY (_Last_History) REFERENCES ps_Group_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Group_History ADD CONSTRAINT [fk_Workshop@ps_Group_History] FOREIGN KEY (_Workshop) REFERENCES ps_Workshop(_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Group_History ADD CONSTRAINT [fk_Department@ps_Group_History] FOREIGN KEY (_Department) REFERENCES ps_Department(_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Group_History ADD CONSTRAINT [fk_Line@ps_Group_History] FOREIGN KEY (_Line) REFERENCES ps_Line(_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Group_History ADD CONSTRAINT [fk_BU@ps_Group_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Group_History ADD CONSTRAINT [fk_Project@ps_Group_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Group_History ADD CONSTRAINT [fk_Shift@ps_Group_History] FOREIGN KEY (_Shift) REFERENCES ps_Shift (_ID) --ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Preference ADD CONSTRAINT [fk_Last_History@ps_Preference] FOREIGN KEY (_Last_History) REFERENCES ps_Preference_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Department ADD CONSTRAINT [fk_Last_History@ps_Department] FOREIGN KEY (_Last_History) REFERENCES ps_Department_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Department_History ADD CONSTRAINT [fk_Shift@ps_Department_History] FOREIGN KEY (_Shift) REFERENCES ps_Shift (_ID) --ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Building ADD CONSTRAINT [fk_Last_History@ps_Building] FOREIGN KEY (_Last_History) REFERENCES ps_Building_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Workshop ADD CONSTRAINT [fk_Last_History@ps_Workshop] FOREIGN KEY (_Last_History) REFERENCES ps_Workshop_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Shift_Segment ADD CONSTRAINT [fk_Last_History@ps_Shift_Segment] FOREIGN KEY (_Last_History) REFERENCES ps_Shift_Segment_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Shift ADD CONSTRAINT [fk_Last_History@ps_Shift] FOREIGN KEY (_Last_History) REFERENCES ps_Shift_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Shift ADD CONSTRAINT [fk_SHB@ps_Shift] FOREIGN KEY (_Shift_History_Batch) REFERENCES ps_Shift_History(_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Line ADD CONSTRAINT [fk_Last_History@ps_Line] FOREIGN KEY (_Last_History) REFERENCES ps_Line_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Line_History ADD CONSTRAINT [fk_BU@ps_Line_History] FOREIGN KEY (_BU) REFERENCES ps_BU (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Line_History ADD CONSTRAINT [fk_Project@ps_Line_History] FOREIGN KEY (_Project) REFERENCES ps_Project (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_BU ADD CONSTRAINT [fk_Last_History@ps_BU] FOREIGN KEY (_Last_History) REFERENCES ps_BU_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Project ADD CONSTRAINT [fk_Last_History@ps_Project] FOREIGN KEY (_Last_History) REFERENCES ps_Project_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Page ADD CONSTRAINT [fk_Last_History@ps_Page] FOREIGN KEY (_Last_History) REFERENCES ps_Page_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Measurement_Limit ADD CONSTRAINT [fk_Last_History@ps_Measurement_Limit] FOREIGN KEY (_Last_History) REFERENCES ps_Measurement_Limit_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Indicator_Action_Value ADD CONSTRAINT [fk_Last_History@ps_Indicator_Action_Value] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_Action_Value_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Indicator_Action_Group ADD CONSTRAINT [fk_Last_History@ps_Indicator_Action_Group] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Indicator ADD CONSTRAINT [fk_Last_History@ps_Indicator] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Indicator_Reason ADD CONSTRAINT [fk_Last_History@ps_Indicator_Reason] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_Reason_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Indicator_Group ADD CONSTRAINT [fk_Last_History@ps_Indicator_Group] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_Group_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Indicator_In_Page ADD CONSTRAINT [fk_Last_History@ps_Indicator_In_Page] FOREIGN KEY (_Last_History) REFERENCES ps_Indicator_In_Page_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Station_Template ADD CONSTRAINT [fk_Last_History@ps_Station_Template] FOREIGN KEY (_Last_History) REFERENCES ps_Station_Template_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Station_Catalog ADD CONSTRAINT [fk_Last_History@ps_Station_Catalog] FOREIGN KEY (_Last_History) REFERENCES ps_Station_Catalog_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Station_Type ADD CONSTRAINT [fk_Last_History@ps_Station_Type] FOREIGN KEY (_Last_History) REFERENCES ps_Station_Type_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Station ADD CONSTRAINT [fk_Last_History@ps_Station] FOREIGN KEY (_Last_History) REFERENCES ps_Station_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Fixture ADD CONSTRAINT [fk_Last_History@ps_Fixture] FOREIGN KEY (_Last_History) REFERENCES ps_Fixture_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Part_Family ADD CONSTRAINT [fk_Last_History@ps_Part_Family] FOREIGN KEY (_Last_History) REFERENCES ps_Part_Family_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE ps_Part_Number ADD CONSTRAINT [fk_Last_History@ps_Part_Number] FOREIGN KEY (_Last_History) REFERENCES ps_Part_Number_History (_ID)-- ON DELETE CASCADE ON UPDATE CASCADE;





-- 非唯一索引在SQL Server中不能在建表的时候在线添加，在此追加
CREATE INDEX  [IDX_Site@ps_Site_History] ON ps_Site_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Site_History] ON ps_Site_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Site_History] ON ps_Site_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Attachment] ON ps_Attachment(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_FileSize@ps_Attachment] ON ps_Attachment(FileSize) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_ImgHeight@ps_Attachment] ON ps_Attachment(ImgHeight) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_ImgWidth@ps_Attachment] ON ps_Attachment(ImgWidth) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Create@ps_Attachment] ON ps_Attachment(_Employee_Create) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Employee] ON ps_Employee(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee@ps_Employee_History] ON ps_Employee_History(_Employee) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Employee_History] ON ps_Employee_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_BU@ps_Employee_History] ON ps_Employee_History(_BU) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Project@ps_Employee_History] ON ps_Employee_History(_Project) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Department@ps_Employee_History] ON ps_Employee_History(_Department) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Leader@ps_Employee_History] ON ps_Employee_History(_Employee_Leader) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Attachment_Gravatar@ps_Employee_History] ON ps_Employee_History(_Attachment_Gravatar) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Employee_History] ON ps_Employee_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee@ps_Login_History] ON ps_Login_History(_Employee) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Group] ON ps_Group(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Group@ps_Group_History] ON ps_Group_History(_Group) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Group_History] ON ps_Group_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Workshop@ps_Group_History] ON ps_Group_History(_Workshop) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Department@ps_Group_History] ON ps_Group_History(_Department) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Line@ps_Group_History] ON ps_Group_History(_Line) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_BU@ps_Group_History] ON ps_Group_History(_BU) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Project@ps_Group_History] ON ps_Group_History(_Project) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Shift@ps_Group_History] ON ps_Group_History(_Shift) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Group_History] ON ps_Group_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Group_History] ON ps_Group_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX(_Group,_Employee)@ps_Employee_In_Group] ON ps_Employee_In_Group(_Group,_Employee) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Employee_In_Group] ON ps_Employee_In_Group(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Preference@ps_Preference_History] ON ps_Preference_History(_Preference) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Preference_History] ON ps_Preference_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Department@ps_Department_History] ON ps_Department_History(_Department) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Department_History] ON ps_Department_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Shift@ps_Department_History] ON ps_Department_History(_Shift) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Department_History] ON ps_Department_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Department_History] ON ps_Department_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Building@ps_Building_History] ON ps_Building_History(_Building) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Building_History] ON ps_Building_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Building_History] ON ps_Building_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Building_History] ON ps_Building_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Workshop@ps_Workshop_History] ON ps_Workshop_History(_Workshop) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Workshop_History] ON ps_Workshop_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Building@ps_Workshop_History] ON ps_Workshop_History(_Building) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Workshop_History] ON ps_Workshop_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Workshop_History] ON ps_Workshop_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Shift_Segment_History] ON ps_Shift_Segment_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_SS@ps_Shift_Segment_History] ON ps_Shift_Segment_History(_Shift_Segment) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_EO@ps_Shift_Segment_History] ON ps_Shift_Segment_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_EU@ps_Shift_Segment_History] ON ps_Shift_Segment_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_SHB@ps_Shift] ON ps_Shift(_Shift_History_Batch) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Shift_History] ON ps_Shift_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Shift@ps_Shift_History] ON ps_Shift_History(_Shift) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Create@ps_Shift_History] ON ps_Shift_History(_Employee_Create) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_SHB@ps_Segment_In_Shift] ON ps_Segment_In_Shift(_Shift_History_Batch) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Shift@ps_Segment_In_Shift] ON ps_Segment_In_Shift(_Shift) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_SS@ps_Segment_In_Shift] ON ps_Segment_In_Shift(_Shift_Segment) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Line] ON ps_Line(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Line@ps_Line_History] ON ps_Line_History(_Line) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Line_History] ON ps_Line_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Workshop@ps_Line_History] ON ps_Line_History(_Workshop) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_BU@ps_Line_History] ON ps_Line_History(_BU) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Project@ps_Line_History] ON ps_Line_History(_Project) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Shift@ps_Line_History] ON ps_Line_History(_Shift) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Line_History] ON ps_Line_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Line_History] ON ps_Line_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Project@ps_BU_History] ON ps_BU_History(_BU) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_BU_History] ON ps_BU_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Workshop@ps_BU_History] ON ps_BU_History(_Workshop) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_BU_History] ON ps_BU_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_BU_History] ON ps_BU_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Project_History] ON ps_Project_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Project@ps_Project_History] ON ps_Project_History(_Project) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_BU@ps_Project_History] ON ps_Project_History(_BU) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Project_History] ON ps_Project_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Project_History] ON ps_Project_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Page_History] ON ps_Page_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Page@ps_Page_History] ON ps_Page_History(_Page) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_BU@ps_Page_History] ON ps_Page_History(_BU) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Project@ps_Page_History] ON ps_Page_History(_Project) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Page_History] ON ps_Page_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Page_History] ON ps_Page_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Create@ps_Access_Control] ON ps_Access_Control(_Employee_Create) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Measurement_Limit_History] ON ps_Measurement_Limit_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_ICV@ps_Indicator_Action_Value_History] ON ps_Indicator_Action_Value_History(_Indicator_Action_Value) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_IA@ps_Indicator_Action_Value_History] ON ps_Indicator_Action_Value_History(_Indicator_Action) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_EU@ps_Indicator_Action_Value_History] ON ps_Indicator_Action_Value_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_ICG@ps_Indicator_Action_Group_History] ON ps_Indicator_Action_Group_History(_Indicator_Action_Group) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Create@ps_Indicator_Action_Group_History] ON ps_Indicator_Action_Group_History(_Employee_Create) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_IGV@ps_Indicator_Action_Value_In_Group] ON ps_Indicator_Action_Value_In_Group(_Indicator_Action_Group,_Indicator_Action_Value) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_EU@ps_Indicator_Action_Value_In_Group] ON ps_Indicator_Action_Value_In_Group(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Indicator@ps_Indicator_History] ON ps_Indicator_History(_Indicator) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_EU@ps_Indicator_History] ON ps_Indicator_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Indicator@ps_Indicator_Level] ON ps_Indicator_Level(_Indicator) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_EU@ps_Indicator_Level] ON ps_Indicator_Level(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Indicator@ps_Indicator_Value] ON ps_Indicator_Value(_Indicator) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Indicator_Level@ps_Indicator_Value] ON ps_Indicator_Value(_Indicator_Level) -- 当前值所达到指示级别 WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Indicator_Reason@ps_Indicator_Reason_History] ON ps_Indicator_Reason_History(_Indicator_Reason) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Indicator_Reason_History] ON ps_Indicator_Reason_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Indicator@ps_Indicator_Explanation] ON ps_Indicator_Explanation(_Indicator_Value) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Indicator_Reason@ps_Indicator_Explanation] ON ps_Indicator_Explanation(_Indicator_Reason) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Create@ps_Indicator_Explanation] ON ps_Indicator_Explanation(_Employee_Create) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Indicator_Explanation@ps_Indicator_Explanation_Attachment] ON ps_Indicator_Explanation_Attachment(_Indicator_Explanation) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_IG@ps_Indicator_Group_History] ON ps_Indicator_Group_History(_Indicator_Group) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_EU@ps_Indicator_Group_History] ON ps_Indicator_Group_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX(_Indicator_Group,_Indicator)@ps_Indicator_In_Group] ON ps_Indicator_In_Group(_Indicator_Group,_Indicator) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_EU@ps_Indicator_In_Group] ON ps_Indicator_In_Group(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Page@ps_Indicator_In_Page_History] ON ps_Indicator_In_Page_History(_Page) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Indicator@ps_Indicator_In_Page_History] ON ps_Indicator_In_Page_History(_Indicator) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_IG@ps_Indicator_In_Page_History] ON ps_Indicator_In_Page_History(_Indicator_Group) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Indicator_In_Page_History] ON ps_Indicator_In_Page_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Station_Template@ps_Station_Template_History] ON ps_Station_Template_History(_Station_Template) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Station_Template_History] ON ps_Station_Template_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Station_Template_History] ON ps_Station_Template_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX(_Site,_Station_Catalog)@ps_Station_Catalog_History] ON ps_Station_Catalog_History(_Site,_Station_Catalog) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Station_Catalog_History] ON ps_Station_Catalog_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Station_Catalog_History] ON ps_Station_Catalog_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Station_Type_History] ON ps_Station_Type_History(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Project@ps_Station_Type_History] ON ps_Station_Type_History(_Project) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Station_Catalog@ps_Station_Type_History] ON ps_Station_Type_History(_Station_Template) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Station_Type_History] ON ps_Station_Type_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Station_Type_History] ON ps_Station_Type_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Line@ps_Station_History] ON ps_Station_History(_Line) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Station_Type@ps_Station_History] ON ps_Station_History(_Station_Type) WITH FILLFACTOR=60;
CREATE INDEX  [IDX(_Site,_Station,_Line,_Station_Type)@ps_Station_History] ON ps_Station_History(_Site,_Station,_Line,_Station_Type) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_BU@ps_Station_History] ON ps_Station_History(_BU) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Project@ps_Station_History] ON ps_Station_History(_Project) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Station_History] ON ps_Station_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Station_History] ON ps_Station_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX(_Site,_Fixture)@ps_Fixture_History] ON ps_Fixture_History(_Site,_Fixture) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Workshop@ps_Fixture_History] ON ps_Fixture_History(_Workshop) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Line@ps_Fixture_History] ON ps_Fixture_History(_Line) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Station@ps_Fixture_History] ON ps_Fixture_History(_Station) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_BU@ps_Fixture_History] ON ps_Fixture_History(_BU) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Project@ps_Fixture_History] ON ps_Fixture_History(_Project) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Owner@ps_Fixture_History] ON ps_Fixture_History(_Employee_Owner) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Fixture_History] ON ps_Fixture_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Site@ps_Part_Family] ON ps_Part_Family(_Site) WITH FILLFACTOR=60;
CREATE INDEX  [IDX(_Site,_Part_Family)@ps_Part_Family_History] ON ps_Part_Family_History(_Site,_Part_Family) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_BU@ps_Part_Family_History] ON ps_Part_Family_History(_BU) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Project@ps_Part_Family_History] ON ps_Part_Family_History(_Project) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Part_Family_History] ON ps_Part_Family_History(_Employee_Update) WITH FILLFACTOR=60;
CREATE INDEX  [IDX(_Site,_Part_Number,_Part_Family)@ps_Part_Number_History] ON ps_Part_Number_History(_Site,_Part_Number,_Part_Family) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_BU@ps_Part_Number_History] ON ps_Part_Number_History(_BU) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Project@ps_Part_Number_History] ON ps_Part_Number_History(_Project) WITH FILLFACTOR=60;
CREATE INDEX  [IDX_Employee_Update@ps_Part_Number_History] ON ps_Part_Number_History(_Employee_Update) WITH FILLFACTOR=60;


