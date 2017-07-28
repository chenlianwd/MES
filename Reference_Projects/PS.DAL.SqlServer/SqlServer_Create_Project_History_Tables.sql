
CREATE TABLE ps_Unit_History_Extra_P1T1(	
	_ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	
    ,_Employee_Create BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Unit_History_Extra_P1T1](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Unit_History_Extra_P1T1] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
	,Create_Time datetimeoffset NULL default(SYSDATETIMEOFFSET())
    );
CREATE TABLE ps_Unit_History_Extra_Detail_P1T1(		
	_ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,_Unit_History_Extra INT NULL
		-- ,INDEX [IDX_Unit_History_Extra@ps_Unit_History_Extra_Detail_P1T1](_Unit_History_Extra)
		,CONSTRAINT [_Unit_History_Extra@ps_Unit_History_Extra_Detail_P1T1] FOREIGN KEY (_Unit_History_Extra) REFERENCES ps_Unit_History_Extra_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
	
    ,Attribute nvarchar(200) NOT NULL
    ,AttrValue nvarchar(200) NOT NULL
		-- ,INDEX [IDX(Attribute,AttrValue)@ps_Unit_History_Extra_Detail_P1T1](Attribute,AttrValue)
    
    ,_Employee_Create BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Unit_History_Extra_Detail_P1T1](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Unit_History_Extra_Detail_P1T1] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
	,Create_Time datetimeoffset NULL default(SYSDATETIMEOFFSET())
    );  

CREATE TABLE ps_Attachment_P1T1(
	_ID BIGINT NOT NULL  IDENTITY(1,1) PRIMARY KEY
	,FileName nvarchar(200)
    ,SavePathName nvarchar(500)
    ,FileMime nvarchar(100)
    ,CRC64 int
		-- ,INDEX [IDX_CRC64@ps_Attachment_P1T1](CRC64)
    ,FileSize BIGINT
		-- ,INDEX [IDX_FileSize@ps_Attachment_P1T1](FileSize)
    ,ImgHeight int
		-- ,INDEX [IDX_ImgHeight@ps_Attachment_P1T1](ImgHeight)
    ,ImgWidth int
		-- ,INDEX [IDX_ImgWidth@ps_Attachment_P1T1](ImgWidth)
    ,_Employee_Create BIGINT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Attachment_P1T1](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Attachment_P1T1] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee(_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
	,Create_Time datetimeoffset NULL default(SYSDATETIMEOFFSET())
	);
    
CREATE TABLE ps_Unit_History_P1T1(
	_ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,_Unit_History_Extra INT NULL
		-- ,INDEX [IDX_Unit_History_Extra@ps_Unit_History_P1T1](_Unit_History_Extra)
		,CONSTRAINT [fk_Unit_History_Extra@ps_Unit_History_P1T1] FOREIGN KEY (_Unit_History_Extra) REFERENCES ps_Unit_History_Extra_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
    
    ,_Line INT NOT NULL
		-- ,INDEX [IDX_Line@ps_Unit_History_P1T1](_Line)
		,CONSTRAINT [fk_Line@ps_Unit_History_P1T1] FOREIGN KEY (_Line) REFERENCES ps_Line (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Station INT NOT NULL
		-- ,INDEX [IDX_Station@ps_Unit_History_P1T1](_Station)
    	,CONSTRAINT [fk_Station@ps_Unit_History_P1T1] FOREIGN KEY (_Station) REFERENCES ps_Station (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE            
	,_Fixture BIGINT NOT NULL
		-- ,INDEX [IDX_Fixture@ps_Unit_History_P1T1](_Fixture)
		,CONSTRAINT [fk_Fixture@ps_Unit_History_P1T1] FOREIGN KEY (_Fixture) REFERENCES ps_Fixture (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE	
     
	,_Unit BIGINT NOT NULL
		-- ,INDEX [IDX_Unit@ps_Unit_History_P1T1](_Unit)
		,CONSTRAINT [fk_Unit@ps_Unit_History_P1T1] FOREIGN KEY (_Unit) REFERENCES ps_Unit_P1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
	,_Serial_Number BIGINT NOT NULL
		-- ,INDEX [IDX_Serial_Number@ps_Unit_History_P1T1](_Serial_Number)
		,CONSTRAINT [fk_Serial_Number@ps_Unit_History_P1T1] FOREIGN KEY (_Serial_Number) REFERENCES ps_Serial_Number_P1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
    ,_Part BIGINT NULL
		-- ,INDEX [IDX_Part@ps_Unit_History_P1T1](_Part)
		,CONSTRAINT [fk_Part@ps_Test_ST1] FOREIGN KEY (_Part) REFERENCES ps_Part_Family (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Part_Family BIGINT NOT NULL
		-- ,INDEX [IDX_Part_Family@ps_Unit_History_P1T1](_Part_Family)
		,CONSTRAINT [fk_Part_Family@ps_Unit_History_P1T1] FOREIGN KEY (_Part_Family) REFERENCES ps_Part_Family (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE  
    ,_Shift INT NOT NULL
		-- ,INDEX [IDX_Shift@ps_Unit_History_P1T1](_Shift)
		,CONSTRAINT [fk_Shift@ps_Unit_History_P1T1] FOREIGN KEY (_Shift) REFERENCES ps_Shift (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE    
     ,_Unit_State INT NOT NULL
		-- ,INDEX [IDX_Unit_State@ps_Unit_History_P1T1](_Unit_State)
		,CONSTRAINT [fk_Unit_State@ps_Unit_History_P1T1] FOREIGN KEY (_Unit_State) REFERENCES ps_Unit_State_P1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
        
	,Panel_Index INT NULL 
    ,bResult smallint -- 0: Fail; 1:Pass; 2:NDF
		,CONSTRAINT [CHK_bResult@ps_Test_ST1] CHECK(bResult IN (0,1,2))
	,Test_Count int
	,Start_Time datetimeoffset NOT NULL
	,Elapsed_Time float
	
    ,_Employee_Create BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Unit_History_P1T1](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Unit_History_P1T1] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
	,Create_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET()) 
    	
    ,Quarter_Hour datetimeoffset -- 在插入数据时实时计算时报，更长周期的统计报表终端用户查询时按终端用户的时区计算
     ); 
CREATE TABLE ps_Unit_History_Attachment_P1T1(
	ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,_Unit_History BIGINT NOT NULL
		-- ,INDEX [IDX_Unit_History@ps_Unit_History_Attachment_P1T1](_Unit_History)
		,CONSTRAINT [fk_Unit_History@ps_Unit_History_Attachment_P1T1] FOREIGN KEY (_Unit_History) REFERENCES ps_Unit_History_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
    
    ,_Attachment BIGINT NOT NULL
		-- ,INDEX [IDX_Attachment@ps_Unit_History_Attachment_P1T1](_Attachment)
		,CONSTRAINT [fk_Attachment@ps_Unit_History_Attachment_P1T1] FOREIGN KEY (_Attachment) REFERENCES ps_Attachment_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
    ); 
    
CREATE TABLE ps_Test_Detail_Def_P1T1(	
	_ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY        
	,[Name] nvarchar(450) NOT NULL
	,Description nvarchar(450) NULL	
	,Logic_Target nvarchar(450) NULL	
	,Err_Msg nvarchar(450)
    
	,_Employee_Create BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Test_Detail_Def_P1T1](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Test_Detail_Def_P1T1] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
	,Create_Time datetimeoffset NULL default(SYSDATETIMEOFFSET()) 
	);
CREATE TABLE ps_Test_Limit_P1T1(	
	_ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY        
	,Low_Limit float NULL
	,High_Limit float NULL
	,Target_Value float NULL
	,Unit nvarchar(20) NULL	
    
	,_Employee_Create BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Test_Limit_P1T1](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Test_Limit_P1T1] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
	,Create_Time datetimeoffset NULL default(SYSDATETIMEOFFSET()) 
	);
CREATE TABLE ps_Test_Detail_P1T1(
	_ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,_Unit_History BIGINT NOT NULL
		-- ,INDEX [IDX_Unit_History@ps_Test_Detail_P1T1](_Unit_History)
		,CONSTRAINT [fk_Unit_History@ps_Test_Detail_P1T1] FOREIGN KEY (_Unit_History) REFERENCES ps_Unit_History_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
    
	,_Detail_Def INT NOT NULL
		-- ,INDEX [IDX_Detail_Def@ps_Test_Detail_P1T1](_Detail_Def)
		,CONSTRAINT [fk_Detail_Def@ps_Test_Detail_P1T1] FOREIGN KEY (_Detail_Def) REFERENCES ps_Test_Detail_Def_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
	,_Test_Limit INT NULL
		-- ,INDEX [IDX_Test_Limit@ps_Test_Detail_P1T1](_Test_Limit)
		,CONSTRAINT [fk_Test_Limit@ps_Test_Detail_P1T1] FOREIGN KEY (_Test_Limit) REFERENCES ps_Test_Limit_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
	,Step INT
	,Parent_Step INT NULL
		-- ,CONSTRAINT [fk_ParentStep@ps_Test_Detail_P1T1] FOREIGN KEY (Parent_Step) REFERENCES ps_Test_Detail_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
    ,_BOM_ID BIGINT NULL -- 待添加BOM表结构后加入,用于关联相应的Location位置信息

    ,Test_Value float NULL	
    ,Logic_Value nvarchar(450) NULL    
	,Elapsed_Time float	
    ,bResult smallint -- 0: Fail; 1:Pass; 2:NDF
		,CONSTRAINT [CHK_bResult@ps_Test_Detail_P1T1] CHECK(bResult IN (0,1,2))
	);
  
CREATE TABLE ps_Test_Detail_Attachment_P1T1(
	ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,_Test_Detail BIGINT NOT NULL
		-- ,INDEX [IDX_Test_Detail@ps_Test_Detail_Attachment_P1T1](_Test_Detail)
		,CONSTRAINT [fk_Test_Detail@ps_Test_Detail_Attachment_P1T1] FOREIGN KEY (_Test_Detail) REFERENCES ps_Test_Detail_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
    
    ,_Attachment BIGINT NOT NULL
		-- ,INDEX [IDX_Attachment@ps_Test_Detail_Attachment_P1T1](_Attachment)
		,CONSTRAINT [fk_Attachment@ps_Test_Detail_Attachment_P1T1] FOREIGN KEY (_Attachment) REFERENCES ps_Attachment_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
    ); 
    
CREATE TABLE ps_Test_Unit_Summary_P1T1
(
	_Unit BIGINT NOT NULL PRIMARY KEY
		,CONSTRAINT [fk_Unit@ps_Test_Unit_Summary_P1T1] FOREIGN KEY (_Unit) REFERENCES ps_Unit_P1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 	
	,_Unit_History_First BIGINT NOT NULL, CONSTRAINT [IDX_Unit_History_First@ps_Test_Unit_Summary_P1T1] UNIQUE(_Unit_History_First)
		,CONSTRAINT [fk_Unit_History_First@ps_Test_Detail_P1T1] FOREIGN KEY (_Unit_History_First) REFERENCES ps_Unit_History_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
	,_Unit_History_Last BIGINT NOT NULL, CONSTRAINT [IDX_Unit_History_Last@ps_Test_Unit_Summary_P1T1] UNIQUE(_Unit_History_Last)
		,CONSTRAINT [fk_Unit_History_Last@ps_Test_Detail_P1T1] FOREIGN KEY (_Unit_History_Last) REFERENCES ps_Unit_History_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
	,Test_Count int NOT NULL default 0
	,TotalElapsedTime INT NULL
);
CREATE TABLE ps_Test_Quarter_Hourly_Summary_P1T1(
	_ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY	
    
    ,_Line INT NOT NULL
		-- ,INDEX [IDX_Line@ps_Test_Quarter_Hourly_Summary_P1T1](_Line)
		,CONSTRAINT [fk_Line@ps_Test_Quarter_Hourly_Summary_P1T1] FOREIGN KEY (_Line) REFERENCES ps_Line (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Station INT NOT NULL
		-- ,INDEX [IDX_Station@ps_Test_Quarter_Hourly_Summary_P1T1](_Station)
    	,CONSTRAINT [fk_Station@ps_Test_Quarter_Hourly_Summary_P1T1] FOREIGN KEY (_Station) REFERENCES ps_Station (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE            
	,_Fixture BIGINT NOT NULL
		-- ,INDEX [IDX_Fixture@ps_Test_Quarter_Hourly_Summary_P1T1](_Fixture)
		,CONSTRAINT [fk_Fixture@ps_Test_Quarter_Hourly_Summary_P1T1] FOREIGN KEY (_Fixture) REFERENCES ps_Fixture (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE	
     
    ,_Part BIGINT NULL
		-- ,INDEX [IDX_Part@ps_Test_Quarter_Hourly_Summary_P1T1](_Part)
		,CONSTRAINT [fk_Part@ps_Test_Quarter_Hourly_Summary_P1T1] FOREIGN KEY (_Part) REFERENCES ps_Part_Family (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE    
    ,_Shift INT NOT NULL
		-- ,INDEX [IDX_Shift@ps_Test_Quarter_Hourly_Summary_P1T1](_Shift)
		,CONSTRAINT [fk_Shift@ps_Test_Quarter_Hourly_Summary_P1T1] FOREIGN KEY (_Shift) REFERENCES ps_Shift (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
	,_Employee BIGINT NOT NULL
		-- ,INDEX [IDX_Employee@ps_Test_Quarter_Hourly_Summary_P1T1](_Employee)
		,CONSTRAINT [fk_Employee@ps_Test_Quarter_Hourly_Summary_P1T1] FOREIGN KEY (_Employee) REFERENCES ps_Employee (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
        
	,Quarter_Hour datetimeoffset NOT NULL -- 在插入数据时实时计算一刻钟报，更长周期的统计报表终端用户查询时按终端用户的时区计算
    ,First_Pass_Qty INT
    ,Final_Pass_Qty INT
    ,Total_Qty INT    
    ,Total_Test_Times INT
    ,Waste_Time INT
    ,Total_Elapsed_Time INT
);

CREATE TABLE ps_Test_Detail_Quarter_Hourly_P1T1(
	_ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,_Test_Quarter_Hourly_Summary BIGINT NOT NULL-- ,INDEX [IDX_Test_Hourly_Summary@ps_Test_Detail_Quarter_Hourly_P1T1](_Test_Quarter_Hourly_Summary)
		,CONSTRAINT [fk_Test_Hourly_Summary@ps_Test_Detail_Quarter_Hourly_P1T1] FOREIGN KEY (_Test_Quarter_Hourly_Summary) REFERENCES ps_Test_Quarter_Hourly_Summary_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
    
	,_Detail_Def INT NOT NULL
		-- ,INDEX [IDX_Detail_Def@ps_Test_Detail_Quarter_Hourly_P1T1](_Detail_Def)
		,CONSTRAINT [fk_Detail_Def@ps_Test_Detail_Quarter_Hourly_P1T1] FOREIGN KEY (_Detail_Def) REFERENCES ps_Test_Detail_Def_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
	,_Test_Limit INT NULL
		-- ,INDEX [IDX_Test_Limit@ps_Test_Detail_Quarter_Hourly_P1T1](_Test_Limit)
		,CONSTRAINT [fk_Test_Limit@ps_Test_Detail_Quarter_Hourly_P1T1] FOREIGN KEY (_Test_Limit) REFERENCES ps_Test_Limit_P1T1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
	,_BOM_ID BIGINT NULL -- 待添加BOM表结构后加入,用于关联相应的Location位置信息

    ,Pass_Times INT
    ,Total_Times INT
    ,Min_Value float
    ,Max_Value float
    ,Mean float(53) -- 平均值
    ,Variance float(53) -- 方差
    ,StdDev float(53) -- 标准差(Standard Deviation)
    ,CPK float(53)
	);
     