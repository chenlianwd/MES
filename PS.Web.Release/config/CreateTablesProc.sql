DELIMITER $$
DROP PROCEDURE IF EXISTS `CreateTablesProc` $$
/*anaNums、ovenNums:动态建立字段组的个数
	lineName:产线名
	recipeName:批次名(即表名前缀)
	
*/
CREATE PROCEDURE `CreateTablesProc`(IN `anaNums` tinyint,IN `ovenNums` tinyint,IN `lineName` VARCHAR(20),IN `recipeName` VARCHAR(20),
																		IN `productName` VARCHAR(50),IN `baseName` VARCHAR(50),IN `processName` VARCHAR(50),
																		IN `ovenName` VARCHAR(50),IN `startTime` datetime,IN `eventFileName` VARCHAR(50),
																		IN `isControlCode` TINYINT,IN `controlCode` VARCHAR(30)
) 
BEGIN
	/*mysql中可以不用DELCARE声明 直接使用set变量，另set a为局部、块变量，set @a为全局、会话变量*/
	DECLARE recipecollect VARCHAR(50) CHARACTER SET utf8;
	DECLARE recipe_eventinfo VARCHAR(50) CHARACTER SET utf8;
	DECLARE recipe VARCHAR(50) CHARACTER SET utf8;
	DECLARE recipe_anainfo VARCHAR(50) CHARACTER SET utf8;
	DECLARE recipe_oveninfo VARCHAR(50) CHARACTER SET utf8;
	DECLARE recipe_boardinfo VARCHAR(50) CHARACTER SET utf8;
	DECLARE i TINYINT DEFAULT 1;
	DECLARE tmpstr1 TEXT;
	DECLARE j TINYINT DEFAULT 1;
	DECLARE tmpstr2 TEXT;
	DECLARE z TINYINT DEFAULT 1;
	DECLARE tmpstr3 TEXT;
	/*拼接日期NOW()暂时用空字符串代替*/
	SET recipecollect = CONCAT(recipeName,'recipecollect',lineName);
	SET recipe_eventinfo = CONCAT(recipeName,'recipe_eventinfo',lineName);
	SET recipe = CONCAT(recipeName,'recipe',lineName);
	SET recipe_anainfo = CONCAT(recipeName,'recipe_anainfo',lineName);
	SET recipe_oveninfo = CONCAT(recipeName,'recipe_oveninfo',lineName);
	SET recipe_boardinfo = CONCAT(recipeName,'recipe_boardinfo',lineName);
/*CREATE*/
	SET @sqlstr1 = CONCAT("CREATE TABLE IF NOT EXISTS ",recipecollect," (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `RecipeFileName` varchar(50) DEFAULT NULL,
  `ProductName` varchar(50) DEFAULT NULL,
  `BaseName` varchar(50) DEFAULT NULL,
  `ProcessName` varchar(50) DEFAULT NULL,
  `OvenName` varchar(50) DEFAULT NULL,
  `ProLine` varchar(30) DEFAULT NULL,
  `BoardNum` mediumint(9) DEFAULT NULL,
  `StartTime` datetime DEFAULT NULL,
  `EndTime` datetime DEFAULT NULL,
  `EventFileName` varchar(50) DEFAULT NULL,
  `IsControlCode` tinyint(1) DEFAULT NULL,
  `ControlCode` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SET @sqlstr2 = CONCAT("CREATE TABLE IF NOT EXISTS ",recipe_eventinfo," (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `EventIndex` int(11) DEFAULT NULL,
  `EventImftype` int(11) DEFAULT NULL,
  `StartTime` datetime DEFAULT NULL,
  `EndTime` datetime DEFAULT NULL,
  `InvolvedArea` bigint(20) DEFAULT NULL,
  `MaxDeltaValue` double DEFAULT NULL,
  `StartBoardIndex` mediumint(9) DEFAULT NULL,
  `EndBoardIndex` mediumint(9) DEFAULT NULL,
  `LastBoardCode` varchar(30) DEFAULT NULL,
  `LastBoardIndex` mediumint(9) DEFAULT NULL,
  `CurrentBoardCode` varchar(30) DEFAULT NULL,
  `EventHandleStat` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SET @sqlstr3 = CONCAT("CREATE TABLE IF NOT EXISTS ",recipe," (
  `FileType` varchar(50) DEFAULT NULL,
  `ProductName` varchar(50) DEFAULT NULL,
  `BoardIndex` mediumint(9) NOT NULL AUTO_INCREMENT,
  `ProLine` varchar(50) DEFAULT NULL,
  `StartTime` datetime DEFAULT NULL,
  `EndTime` datetime DEFAULT NULL,
  `BaseName` varchar(50) DEFAULT NULL,
  `Barcode` varchar(30) DEFAULT NULL,
  `CPK` double DEFAULT NULL,
  `ProfilefileType` int(11) DEFAULT NULL,
  `RecipeBoardName` varchar(50) DEFAULT NULL,
  `BoardLength` double DEFAULT NULL,
  `_Interval` double DEFAULT NULL,
  `FirstFlag` tinyint(1) DEFAULT NULL,
  `IsPass` tinyint(1) DEFAULT NULL,
  `ReportPath` varchar(300) DEFAULT NULL,
  `OvenTempDeltaPercent` double DEFAULT NULL,
  `CAValue` double DEFAULT NULL,
  `SpeedDeltaPercent` double DEFAULT NULL,
  PRIMARY KEY (`BoardIndex`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SET tmpstr3='';
	WHILE z<=38 DO
		SET tmpstr3 = CONCAT(tmpstr3,'`tc',z,'` char(10) DEFAULT NULL,');
		SET z = z + 1;
	END WHILE;
	SET @sqlstr4 = CONCAT("CREATE TABLE IF NOT EXISTS ",recipe_boardinfo," (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `boardid` mediumint(9) DEFAULT NULL,
  `InnerTemp` float(4,1) DEFAULT NULL,
  `Humidity` float(4,1) DEFAULT NULL,
  ",tmpstr3,"
  PRIMARY KEY (`id`),
	KEY `FK_",recipe_boardinfo,"` (`boardid`),
  CONSTRAINT `FK_",recipe_boardinfo,"` FOREIGN KEY (`boardid`) REFERENCES ",recipe," (`BoardIndex`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	
	SET tmpstr1='';
  WHILE i<=anaNums DO
		SET tmpstr1 = CONCAT(tmpstr1,'`ana',i,'_value` FLOAT(4,1) DEFAULT NULL, `ana',i,'_ca` CHAR(10) DEFAULT NULL, `ana',i,'_cp` CHAR(10) DEFAULT NULL, `ana',i,'_cpk` CHAR(10) DEFAULT NULL,');
		SET i = i + 1;
	END WHILE;
	SET tmpstr2='';
	WHILE j<=ovenNums DO
		SET tmpstr2 = CONCAT(tmpstr2,'`oven',j,'` float(4,1) DEFAULT NULL,');						 
		SET j = j + 1;
	END WHILE;
	SET @sqlstr5 = CONCAT("CREATE TABLE IF NOT EXISTS ",recipe_anainfo," (
  `id` bigint(20) NOT NULL,
  `boardid` mediumint(9) DEFAULT NULL,
  `channel` mediumint(9) DEFAULT NULL,
  `anasegmentnum` mediumint(5) DEFAULT NULL,
  ",tmpstr1," 
  PRIMARY KEY (`id`),
  KEY `FK_",recipe_anainfo,"` (`boardid`),
  CONSTRAINT `FK_",recipe_anainfo,"` FOREIGN KEY (`boardid`) REFERENCES ",recipe," (`BoardIndex`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	SET @sqlstr6 = CONCAT("CREATE TABLE IF NOT EXISTS ",recipe_oveninfo," (
  `id` bigint(20) NOT NULL,
  `boardid` mediumint(9) DEFAULT NULL,
  `speed` float(5,1) DEFAULT NULL,
  ",tmpstr2," 
  PRIMARY KEY (`id`),
  KEY `FK_",recipe_oveninfo,"` (`boardid`),
  CONSTRAINT `FK_",recipe_oveninfo,"` FOREIGN KEY (`boardid`) REFERENCES ",recipe," (`BoardIndex`)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
/*INSERT*/
	SET @sqlstr7 = CONCAT("INSERT INTO ",recipecollect,"(RecipeFileName,ProductName,BaseName,ProcessName,
												OvenName,ProLine,BoardNum,StartTime,EndTime,EventFileName,IsControlCode,ControlCode)"," VALUES(?,?,?,?,?,?,?,?,?,?,?,?)");
	SET @recipeNameP = recipeName;
	SET @productNameP = productName;
	SET @baseNameP = baseName;
	SET @processNameP = processName;
	SET @ovenNameP = ovenName;
	SET @lineNameP = lineName;
	SET @boardNumsP = 0;
	SET @startTimeP = startTime;
	SET @endTimeP = NOW();
	SET @eventFileNameP = eventFileName;
	SET @isControlCodeP = isControlCode;
	SET	@controlCodeP = controlCode;

	PREPARE stmt1 FROM @sqlstr1;
	PREPARE stmt2 FROM @sqlstr2;
	PREPARE stmt3 FROM @sqlstr3;
	PREPARE stmt4 FROM @sqlstr4;
	PREPARE stmt5 FROM @sqlstr5;
	PREPARE stmt6 FROM @sqlstr6;
  
	EXECUTE stmt1;
	EXECUTE stmt2;
	EXECUTE stmt3;
	EXECUTE stmt4;
	EXECUTE stmt5;
	EXECUTE stmt6;
	PREPARE stmt7 FROM @sqlstr7; -- 插入语句的预处理以及执行必须在建表语句执行完之后;
  EXECUTE stmt7 USING @recipeNameP,@productNameP,@baseNameP,@processNameP,@ovenNameP,@lineNameP,@boardNumsP,@startTimeP,@endTimeP,@eventFileNameP,@isControlCodeP,@controlCodeP;
END $$
DELIMITER;

