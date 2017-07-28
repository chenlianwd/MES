
CREATE TABLE ps_Unit_State_P1(
	_ID int NOT NULL PRIMARY KEY
	,Description nvarchar(800) NOT NULL
	,_Status tinyint NOT NULL default 1 -- 0:Locked, 1:Noraml
    );
INSERT INTO ps_Unit_State_P1(_ID,Description) VALUES(1000,'Default Unite State')

CREATE TABLE ps_Panel_P1(
	_ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
    ,_Line INT NOT NULL
		-- ,INDEX [IDX_Line@ps_Panel_P1](_Line)
		,CONSTRAINT [fk_Line@ps_Panel_P1] FOREIGN KEY (_Line) REFERENCES ps_Line (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Station INT NOT NULL
		-- ,INDEX [IDX_Station@ps_Panel_P1](_Station)
    	,CONSTRAINT [fk_Station@ps_Panel_P1] FOREIGN KEY (_Station) REFERENCES ps_Station (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE  
    ,Create_Time datetimeoffset NULL default(SYSDATETIMEOFFSET())
    );
    
CREATE TABLE ps_Unit_P1(
	_ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY	
	,_Line INT NOT NULL
		-- ,INDEX [IDX_Line@ps_Unit_P1](_Line) -- 最后所在的Line
		,CONSTRAINT [fk_Line@ps_Unit_P1] FOREIGN KEY (_Line) REFERENCES ps_Line (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
    ,_Station INT NOT NULL
		-- ,INDEX [IDX_Station@ps_Unit_P1](_Station) -- 最后所在的Station
    	,CONSTRAINT [fk_Station@ps_Unit_P1] FOREIGN KEY (_Station) REFERENCES ps_Station (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE  
	,_Work_Order int NULL -- 所在的Work Order
	,_RMA int NULL	-- 可能的RMA单号
	,_Part BIGINT NULL
		-- ,INDEX [IDX_Part@ps_Unit_P1](_Part) -- 最新的PartID
		,CONSTRAINT [fk_Part@ps_Unit_P1] FOREIGN KEY (_Part) REFERENCES ps_Part_Family (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
	,_Serial_Number BIGINT NULL
		-- ,INDEX [IDX_Serial_Number@ps_Unit_History_P1T1](_Serial_Number)  -- 最后使用的SN
		-- , CONSTRAINT [fk_Serial_Number@ps_Unit_History_P1T1] FOREIGN KEY (_Serial_Number) REFERENCES ps_Serial_Number_P1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE     
	,_Unit_State INT NOT NULL
		-- ,INDEX [IDX_Unit_State@ps_Unit_P1](_Unit_State)
		,CONSTRAINT [fk_Unit_State@ps_Unit_P1] FOREIGN KEY (_Unit_State) REFERENCES ps_Unit_State_P1 (_ID) ON UPDATE CASCADE--ON DELETE RESTRICT
	,_Unit_Status int NULL	
    
	,_Unit_Panel int NULL -- 此子板来自来独立SN的拼板。
		-- ,CONSTRAINT [fk_Unit_Panel@ps_Unit_P1] FOREIGN KEY (_Unit_Panel) REFERENCES ps_Unit_State_P1 (_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	
    -- 此子板来自来不带独立SN的拼板。
    ,_Panel BIGINT NULL 
		,CONSTRAINT [fk_Panel@ps_Unit_P1] FOREIGN KEY (_Panel) REFERENCES ps_Panel_P1 --(_ID) ON DELETE RESTRICT ON UPDATE CASCADE
	,Panel_Index int NULL
    
    ,_Employee_Update BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Update@ps_Unit_P1](_Employee_Update)
		,CONSTRAINT [fk_Employee_Update@ps_Unit_P1] FOREIGN KEY (_Employee_Update) REFERENCES ps_Employee --(_ID) ON DELETE RESTRICT ON UPDATE CASCADE	
	,Update_Time datetimeoffset NULL default(SYSDATETIMEOFFSET())

	,_Station_Create INT NOT NULL
		-- ,INDEX [IDX_Station_Create@ps_Unit_P1](_Station)
    	,CONSTRAINT [fk_Station_Create@ps_Panel_P1] FOREIGN KEY (_Station_Create) REFERENCES ps_Station (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
	,_Employee_Create BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Unit_P1](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Unit_P1] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
	,Create_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET()) 
    );
CREATE TABLE ps_Serial_Number_P1(
	_ID BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY
	,_Unit BIGINT NOT NULL
		-- ,INDEX [IDX_Unit@ps_Serial_Number_P1](_Unit)
    	,CONSTRAINT [fk_Unit@ps_Serial_Number_P1] FOREIGN KEY (_Unit) REFERENCES ps_Unit_P1 (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
	,_Serial_Number_Type smallint NOT NULL default 1
	,Serial_Number nvarchar(50) NOT NULL

	,_Station_Create INT NOT NULL
		-- ,INDEX [IDX_Station_Create@ps_Serial_Number_P1](_Station)
    	,CONSTRAINT [fk_Station_Create@ps_Serial_Number_P1] FOREIGN KEY (_Station_Create) REFERENCES ps_Station (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 

	,_Employee_Create BIGINT NOT NULL
		-- ,INDEX [IDX_Employee_Create@ps_Serial_Number_P1](_Employee_Create)
		,CONSTRAINT [fk_Employee_Create@ps_Serial_Number_P1] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee (_ID) --ON DELETE RESTRICT ON UPDATE CASCADE
	,Create_Time datetimeoffset NOT NULL default(SYSDATETIMEOFFSET()) 
    );

CREATE TABLE ps_Attachment_P1(
	_ID BIGINT NOT NULL  IDENTITY(1,1) PRIMARY KEY
    ,_Site INT NOT NULL
		-- ,INDEX [IDX_Site@ps_Attachment_P1](_Site)		
		 ,CONSTRAINT [fk_Site@ps_Attachment_P1] FOREIGN KEY (_Site) REFERENCES ps_Site (_ID)-- ON DELETE RESTRICT ON UPDATE CASCADE
	,FileName nvarchar(200)
    ,SavePathName nvarchar(500)
    ,FileMime nvarchar(100)
    ,CRC64 int
		-- ,INDEX [IDX_CRC64@ps_Attachment_P1](CRC64)
    ,FileSize BIGINT
		-- ,INDEX [IDX_FileSize@ps_Attachment_P1](FileSize)
    ,ImgHeight int
		-- ,INDEX [IDX_ImgHeight@ps_Attachment_P1](ImgHeight)
    ,ImgWidth int
		-- ,INDEX [IDX_ImgWidth@ps_Attachment_P1](ImgWidth)
    ,_Employee_Create BIGINT NULL-- ,INDEX [IDX_Employee_Create@ps_Attachment_P1](_Employee_Create)
		 ,CONSTRAINT [fk_Employee_Create@ps_Attachment_P1] FOREIGN KEY (_Employee_Create) REFERENCES ps_Employee(_ID) --ON DELETE RESTRICT ON UPDATE CASCADE 
	,Create_Time datetimeoffset NULL default(SYSDATETIMEOFFSET())
	);
   
