
DELIMITER $$

DROP PROCEDURE IF EXISTS Update_Employee_Info $$

CREATE PROCEDURE Update_Employee_Info ( _EmpID int,sPwd varchar(50),_EmpID_Update int ,blobGravatar Blob, sFullName varchar(100) ,sDescription varchar(200),sMailAddress varchar(200)
	 ,nLogin_Result_ID int,nLogin_Attempt int,sFrom_IP varchar(16),sFrom_MAC varchar(20),sFrom_Host varchar(50)
    ) 
    BEGIN
		
        INSERT INTO ps_Employee_Update_History(_Employee_ID,`Password`,_Employee_ID_Update ,Gravatar ,Fullname,Description,Email_Address,Telphone_Number,AD_Account,_Use_AD_Login,_Status_ID,`Language`,bChangePwdWhenNextLogin
        )
			SELECT _EmpID
					,(CASE WHEN sPwd IS NOT NULL THEN sPwd ELSE `Password` END)
                    ,_EmpID_Update
                    ,(CASE WHEN blobGravatar IS NOT NULL THEN blobGravatar ELSE Gravatar END)
					,(CASE WHEN sFullName IS NOT NULL THEN sFullName ELSE Fullname END) 
                    ,(CASE WHEN sDescription IS NOT NULL THEN sDescription ELSE Description END) 
                    ,(CASE WHEN sMailAddress IS NOT NULL THEN sMailAddress ELSE Email_Address END) 
                    ,Telphone_Number,AD_Account,_Use_AD_Login,_Status_ID,`Language`,0
				FROM ps_Employee_Update_History tblHistory INNER JOIN ps_Employee tblEmp ON tblEmp.Last_Employee_Update_History_ID=tblHistory._ID;
		
        SET @LastID=LAST_INSERT_ID();
		UPDATE ps_Employee SET Last_Employee_Update_History_ID = @LastID WHERE _ID = _EmpID;
        
        IF nLogin_Result_ID<>-1 THEN
			INSERT INTO ps_Employee_Login_History(_Employee_ID,Login_Attempt,From_IP,From_MAC,From_Host,_Login_Result_ID)
		 		VALUES(_EmpID,nLogin_Attempt,sFrom_IP,sFrom_MAC,sFrom_Host,nLogin_Result_ID);
		END IF;
        
    END $$
    
DELIMITER ;