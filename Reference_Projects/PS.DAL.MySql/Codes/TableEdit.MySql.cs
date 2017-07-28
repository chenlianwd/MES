using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.Common;
using System.Diagnostics;
using MySql.Data.MySqlClient;

namespace PS
{
    public partial class DAL_MySql : DALBase
    {
        /// <summary>
        /// 构造一个对指定表的插入语句。
        /// </summary>
        /// <param name="sTableName">指定的表名</param>
        /// <param name="sFieldList">已经构造好的字段列表</param>
        /// <param name="sValList">已经构造好的数值列表</param>
        /// <returns>构造好的SQL语句</returns>
        private string BuildInsert(string sTableName, string sFieldList, string sValList)
        {
            return "INSERT INTO `" + sTableName + "`(" + sFieldList + ") VALUES(" + sValList + ");\n";
        }

        /// <summary>
        /// 更新指定的表
        /// </summary>
        /// <param name="sTableName">指定的表名</param>
        /// <param name="sUpdateValList">已经构造好的需要更新的字段/数值列表</param>
        /// <param name="sKeyField">条件语句的主键字段</param>
        /// <param name="sKeyValue">条件语句的主键值</param>
        /// <returns></returns>
        private string BuildUpdate(string sTableName, string sUpdateValList, string sKeyField, long nKeyValue)
        {
            return " UPDATE `" + sTableName + "` SET " + sUpdateValList + " WHERE `" + sKeyField + "`=" + nKeyValue + ";\n";
        }


        private string BuildCommonSelectSql(EditableInfo ei, bool bOnlyArray,  string sNameFilter)
        {
            string sSql = "";
            //if (bForRender || bOnlyArray)
            //{
            //    sSql = "";
            //    if (bFirstIsNA)
            //        sSql = "SELECT -1 AS _ID,'<N/A>' AS Name,-1 AS  _Status UNION \n";
            //    sSql += "SELECT tblMaster._ID,tblHistory.`Name`,tblHistory._Status \n";
            //}
            //else
            //    sSql = "SELECT tblHistory.*,tblEmp.`Name` AS UserName " + (ei.HasOwner ? ",tblOwner.`Name` AS OwnerName \n" : "\n");

            //sSql += " FROM `" + ei.PrimaryTable + "` tblMaster INNER JOIN `" + ei.HistoryTable + "_History` tblHistory ON tblMaster._Last_History=tblHistory._ID \n"
            //    + (string.IsNullOrEmpty(sNameFilter) ? "" : " AND tblHistory.`Name` LIKE '%" + sNameFilter + "%'")
            //    + " ps_Employee tblEmp ON tblHistory._Employee_Update=tblEmp.ID \n"
            //    + (ei.HasOwner ? " INNER JOIN  ps_Employee tblOwner ON tblHistory._Employee_Owner=tblOwner._ID  \n" : "\n")
            //    + " ORDER BY tblHistory.`Name`";

            return sSql;
        }

        private void AddFieldValue(changeStatus nStatus, string sFld, Dictionary<string, object> row, EmployeeInfo emp,string HistoryForeignKey, ref string sSql,ref string sValList)
        {
            string sVal = QuoteNull;
            object val = null;
            if (row.ContainsKey(sFld))
                val = row[sFld];
            else if (nStatus == changeStatus.AddHistory)
            {
                if (sSql.Length > 0) sSql += ",";
                sSql += QuoteField(sFld);

                if (sValList.Length > 0) sValList += ",";

                if (sFld.Equals("Update_Time", StringComparison.OrdinalIgnoreCase)
                    || sFld.Equals("Create_Time", StringComparison.OrdinalIgnoreCase))
                    sValList += FuncCurrentTimestamp;
                else
                    sValList += QuoteField(sFld);

                return;
            }
            else if (nStatus == changeStatus.Where)//条件语句不关心没有给值的字段
            {
                return;
            }

            if (val != null && val.GetType() == typeof(string))
            {
                if (Cvt.IsNumerical(val))
                    sVal = val.ToString();
                else
                    sVal = QuoteValue(val.ToString());
            }
            else if (sFld.Equals("_Employee_Update", StringComparison.OrdinalIgnoreCase))
            {
                if (nStatus == changeStatus.Where)
                    return;

                sVal = emp._Employee.ToString();
            }
            else if (sFld.Equals("_Site", StringComparison.OrdinalIgnoreCase))
            {
                sVal = emp._Site_Working.ToString();
            }
            else if (sFld.Equals("_Project", StringComparison.OrdinalIgnoreCase))
            {
                sVal = emp._Project_Working.ToString();
            }
            else if (sFld.Equals(HistoryForeignKey, StringComparison.OrdinalIgnoreCase) && nStatus == changeStatus.Add)
            {
                sVal = "@nLastPrimaryID";
            }
            else
            {
                try
                {
                    sVal = Convert.ToInt32(val).ToString();
                }
                catch(Exception )
                {
                }
            }


            if (nStatus == changeStatus.Add)
            {
                if (sFld.Equals("Update_Time", StringComparison.OrdinalIgnoreCase) == false
                    && sFld.Equals("Create_Time", StringComparison.OrdinalIgnoreCase) == false)
                {
                    if (sSql.Length > 0) sSql += ",";
                    sSql += QuoteField(sFld);
                    
                    if (sValList.Length > 0) sValList += ",";
                    sValList += sVal;
                }
            }
            else if (nStatus == changeStatus.Update)
            {
                if (sSql.Length > 0) sSql += ",";                

                if (sFld.Equals("Update_Time", StringComparison.OrdinalIgnoreCase)
                    || sFld.Equals("Create_Time", StringComparison.OrdinalIgnoreCase))
                    sSql += QuoteField(sFld) + "=" + FuncCurrentTimestamp;
                else
                    sSql += QuoteField(sFld) + "=" + sVal;
            }
            else if (nStatus == changeStatus.Where)
            {
                if (sSql.Length > 0) sSql += " AND ";

                if (sFld.Equals("Update_Time", StringComparison.OrdinalIgnoreCase)
                    || sFld.Equals("Create_Time", StringComparison.OrdinalIgnoreCase))
                    return;//条件语句不关心创建时间或更新时间
                else
                    sSql += QuoteField(sFld) + "=" + sVal;
            }
            else if (nStatus == changeStatus.AddHistory)
            {
                if (sSql.Length > 0) sSql += ",";
                sSql += QuoteField(sFld);

                if (sValList.Length > 0) sValList += ",";

                if (sFld.Equals("Update_Time", StringComparison.OrdinalIgnoreCase)
                    || sFld.Equals("Create_Time", StringComparison.OrdinalIgnoreCase))
                    sValList += FuncCurrentTimestamp;
                else
                    sValList += sVal;
            }
        }

        private void BuildSubmitSql(EmployeeInfo emp, changeStatus nStatus, EditableInfo ei, Dictionary<string, object> row,bool bCheckChanged, ref string sSql)
        {
            //if (ei.PrimaryFields == null || ei.PrimaryFields.Length == 0)
            //    return;

            //string sName = "";
            //if (row.ContainsKey(ei.PrimaryFields[0]))//第一个Name字段不能为空白
            //    sName = Cvt.ToString(row[ei.PrimaryFields[0]]);
            //sName = sName.Trim();
            //if (sName.Length > 0)
            {
                string sValList = "";
                string sSqlRow = "";

                if (nStatus == changeStatus.Add)
                {
                    foreach (string sFld in ei.MasterTable.Fields)
                        AddFieldValue(nStatus, sFld, row, emp, "", ref sSqlRow, ref sValList);

                    if (sSqlRow.Length > 0)
                    {
                        sSql += BuildInsert(ei.MasterTable.sName, sSqlRow, sValList);
                        sSql += "SET @nLastPrimaryID=last_insert_id();\n";
                    }
                    //else
                    //    sSql += "SET @nLastPrimaryID=" + row[ei.HistoryForeignKey] + ";\n";

                    if (ei.SlaveTables != null)
                    {
                        foreach (EditableTable slave in ei.SlaveTables)
                        {
                            sValList = "";
                            sSqlRow = "";
                            foreach (string sFld in slave.Fields)
                                AddFieldValue(nStatus, sFld, row, emp, ei.sSlaveKey, ref sSqlRow, ref sValList);

                            if (sSqlRow.Length > 0)
                            {
                                sSql += BuildInsert(slave.sName, sSqlRow, sValList);
                                string sForeignKeyInMaster = ei.ForeignKeyInMaster(slave.sName);
                                if (sForeignKeyInMaster.Length > 0)
                                    sSql += "UPDATE " + QuoteField(ei.MasterTable.sName) + " SET " + QuoteField(sForeignKeyInMaster) + "=last_insert_id() WHERE " + QuoteField("_ID") + "=@nLastPrimaryID;\n";
                            }
                        }
                    }
                }
                //else if (nStatus == changeStatus.Update)//没有列出的值的字段将置为NULL
                //{
                //    foreach (string sFld in ei.PrimaryFields)
                //        AddFieldValue(nStatus, sFld, row, emp, "", ref sSqlRow, ref sValList);
                //    sSql += "UPDATE " + QuoteField(ei.PrimaryTable) + " SET " + sSqlRow + " WHERE " + QuoteField("_ID") + "=" + row[ei.HistoryForeignKey] + ";\n";

                //    if (!string.IsNullOrEmpty(ei.HistoryTable))
                //    {
                //        //再构造添加到Histry表中的语句
                //        sValList = "";
                //        sSqlRow = "";
                //        foreach (string sFld in ei.HistoryFileds)
                //            AddFieldValue(changeStatus.Add, sFld, row, emp, ei.HistoryForeignKey, ref sSqlRow, ref sValList);
                //        string sInsertSql = BuildInsert(ei.HistoryTable, sSqlRow, sValList);

                //        //先检查是否确实有更改
                //        if (!bCheckChanged)
                //            sSql += sInsertSql;
                //        else
                //        {
                //            sValList = "";
                //            sSqlRow = "";

                //            foreach (string sFld in ei.HistoryFileds)
                //                AddFieldValue(nStatus, sFld, row, emp, ei.HistoryForeignKey, ref sSqlRow, ref sValList);
                //            sSql += "IF NOT EXISTS(SELECT * FROM " + QuoteField(ei.HistoryTable) + " WHERE " + QuoteField("_ID") + "=" + row["_ID"] + " AND " + sValList + ") THEN \n"
                //                 + sInsertSql
                //                 + "UPDATE " + QuoteField(ei.PrimaryTable) + " SET " + QuoteField("_Last_History") + "=last_insert_id() WHERE " + QuoteField("_ID") + "=" + row[ei.HistoryForeignKey] + ";\n"
                //                 + "END IF;\n";
                //        }
                //    }
                //}
                //else if (nStatus == changeStatus.AddHistory)//没有列出的值的字段将置最后一次的值
                else if (nStatus == changeStatus.Update || nStatus == changeStatus.AddHistory)//没有列出的值的字段将置最后一次的值
                {
                    //foreach (string sFld in ei.PrimaryFields)
                    //{
                    //    if (row.ContainsKey(sFld))
                    //        AddFieldValue(changeStatus.Update, sFld, row, emp, "", ref sSqlRow, ref sValList);
                    //}
                    //if (sSqlRow.Length > 0)
                    //    sSql += "UPDATE " + QuoteField(ei.PrimaryTable) + " SET " + sSqlRow + " WHERE " + QuoteField("_ID") + "=" + row[ei.HistoryForeignKey] + ";\n";

                    //if (!string.IsNullOrEmpty(ei.HistoryTable))
                    //{
                    //    //先构造添加到Histry表中的语句
                    //    sValList = "";
                    //    sSqlRow = "";
                    //    foreach (string sFld in ei.HistoryFileds)
                    //        AddFieldValue(changeStatus.AddHistory, sFld, row, emp, ei.HistoryForeignKey, ref sSqlRow, ref sValList);

                    //    string sInsertSql = " SELECT " + QuoteField(ei.ForeignKeyInPrimary) + " INTO @nLastID FROM " + QuoteField(ei.PrimaryTable) + " WHERE  " + QuoteField("_ID") + "=" + row[ei.HistoryForeignKey] + " ;\n"
                    //        + " INSERT INTO " + QuoteField(ei.HistoryTable) + "(" + sSqlRow + ") \n"
                    //        + " SELECT " + sValList + " FROM " + QuoteField(ei.HistoryTable) + " WHERE " + QuoteField("_ID") + "=@nLastID;\n";

                    //    //再决定是是否需要检查确实有更改
                    //    if (!bCheckChanged)
                    //        sSql += sInsertSql;
                    //    else
                    //    {
                    //        sValList = "";
                    //        sSqlRow = "";

                    //        foreach (string sFld in ei.HistoryFileds)
                    //        {
                    //            if (row.ContainsKey(sFld))
                    //                AddFieldValue(changeStatus.Where, sFld, row, emp, ei.HistoryForeignKey, ref sSqlRow, ref sValList);
                    //        }
                    //        if (sSqlRow.Length > 0)
                    //        {
                    //            string sUpdateSql ="";
                    //            if (!string.IsNullOrEmpty(ei.ForeignKeyInPrimary))
                    //                sUpdateSql = " UPDATE " + QuoteField(ei.PrimaryTable) + " SET "
                    //                    + QuoteField(ei.ForeignKeyInPrimary) + "=last_insert_id() WHERE " + QuoteField("_ID") + "=" + row[ei.HistoryForeignKey] + ";\n";

                    //            sSql += "IF NOT EXISTS(SELECT * FROM " + QuoteField(ei.HistoryTable) + " WHERE  " + QuoteField("_ID") + "=" + row[ei.HistoryForeignKey] + " AND " + sSqlRow + ") THEN \n"
                    //                + sInsertSql
                    //                + sUpdateSql
                    //                + "END IF;\n";                                
                    //        }
                    //    }
                    //}
                }

                
            }
        }

        public override DataTable GetEditableTable(EditableInfo ei, bool bOnlyArray, string sNameFilter)
        {
            string sSql = "";
            if (ei.Sql != null)
                sSql = ei.Sql;
            else if (ei.BuildSelectSql != null)
                sSql = ei.BuildSelectSql( ei,bOnlyArray, sNameFilter);
            else
                sSql = BuildCommonSelectSql(ei,bOnlyArray, sNameFilter);

            return ExecuteDataTable(sSql);
        }

        public override void SubmitEditableChange(EmployeeInfo emp, Dictionary<string, object>[] Rows, EditableInfo ei)
        {
            string sSql = "";
            foreach (Dictionary<string, object> row in Rows)
            {
                string sStatus = Cvt.ToString(row["__status"]);
                if (!string.IsNullOrEmpty(sStatus))
                {
                    changeStatus nStatus = (changeStatus)Enum.Parse(typeof(changeStatus), sStatus, true);
                    BuildSubmitSql(emp, nStatus, ei, row, true, ref sSql);
                }
            }
            ExecCommandWithTransaction(sSql); 
        }

        public override void SubmitEditableChange( EmployeeInfo emp,changeStatus nStatus, bool bCheckChanged, string sEditableName, Dictionary<string, object> row)
        {
            foreach (EditableInfo ei in Common.EditableList)
            {
                if (sEditableName.Equals(ei.EditableName, StringComparison.OrdinalIgnoreCase))
                    SubmitEditableChange(emp,nStatus, bCheckChanged, ei, row);
            }
        }
        private void ExecCommandWithTransaction(string sSql)
        {
            if (sSql.Length > 0)
            {
                //MySql 不支持在存贮过程外使用IF语句，创建一个临时的存贮过程
                string sProcName = "temp_Proc_" + Guid.NewGuid().ToString().Replace('-', '_');

                sSql = "DELIMITER $$ \n"
                    + "DROP PROCEDURE IF EXISTS " + sProcName + " $$ \n"
                    + "CREATE PROCEDURE " + sProcName + " () \n"
                    + "BEGIN \n\n"
                    + sSql
                    + "\n END $$\n"
                    + "DELIMITER ;\n"
                    + "CALL " + sProcName + "();\n"
                    + "DROP PROCEDURE IF EXISTS " + sProcName + "; \n";

                Debug.WriteLine(sSql);

                DbTransaction objTrans = BeginTransaction();
                MySqlScript script = new MySqlScript(objTrans.Connection as MySqlConnection, sSql);
                script.Execute();
                //ExecuteNonQuery(objTrans, sSql);
                objTrans.Commit();//使用事务提交，保证数据完整性   
            }
        }
        public override void SubmitEditableChange(EmployeeInfo emp,changeStatus nStatus, bool bCheckChanged,  EditableInfo ei, Dictionary<string, object> row)
        {
            string sSql = "";
            BuildSubmitSql(emp, nStatus, ei, row, bCheckChanged, ref sSql);
            ExecCommandWithTransaction(sSql);          
        }

    }
}