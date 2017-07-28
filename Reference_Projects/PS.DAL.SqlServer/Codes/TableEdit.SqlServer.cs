using System;
using System.Collections.Generic;
using System.Web;
using System.Data;
using System.Data.Common;
using System.Diagnostics;
using System.Data.SqlClient;

namespace PS
{
    public partial class DAL_SqlServer : DALBase
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
            return "INSERT INTO " + QuoteField(sTableName) + "(" + sFieldList + ") VALUES(" + sValList + ");\n";
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
            return " UPDATE " + QuoteField(sTableName) + " SET " + sUpdateValList + " WHERE " + QuoteField(sKeyField) + "=" + nKeyValue + ";\n";
        }


        private string BuildCommonSelectSql(EditableInfo ei, bool bOnlyArray, string sNameFilter)
        {
            string sSql = "";
            //if (bForRender || bOnlyArray)
            //{
            //    sSql = "";
            //    if (bFirstIsNA)
            //        sSql = "SELECT -1 AS _ID,'<N/A>' AS Name,-1 AS  _Status UNION \n";
            //    sSql += "SELECT tblMaster._ID,tblHistory.Name,tblHistory._Status \n";
            //}
            //else
            //    sSql = "SELECT tblHistory.*,tblEmp.Name AS UserName " + (ei.HasOwner ? ",tblOwner.Name AS OwnerName \n" : "\n");

            //sSql += " FROM " + QuoteField(ei.MasterTable.sName) + " tblMaster INNER JOIN `" + ei.HistoryTable + "_History` tblHistory ON tblMaster._Last_History=tblHistory._ID \n"
            //    + (string.IsNullOrEmpty(sNameFilter) ? "" : " AND tblHistory.`Name` LIKE '%" + sNameFilter + "%'")
            //    + " ps_Employee tblEmp ON tblHistory._Employee_Update=tblEmp.ID \n"
            //    + (ei.HasOwner ? " INNER JOIN  ps_Employee tblOwner ON tblHistory._Employee_Owner=tblOwner._ID  \n" : "\n")
            //    + " ORDER BY tblHistory.`Name`";


            sSql += "SELECT tblMaster._ID";
            string sFromSql = " FROM " + QuoteField(ei.MasterTable) + " tblMaster \n";
            foreach (Field fld in ei.MasterTable.Fields)
            {
                if (bOnlyArray == false || (bOnlyArray && fld.name.Equals("Name", StringComparison.OrdinalIgnoreCase))) //bOnlyArray时只取名字
                    sSql += ",tblMaster." + QuoteField(fld);
            }

            int nSlaveIdx = 0;
            string sNameInSlave = "",sOrderFld="";
            foreach (EditableTable tbl in ei.SlaveTables)
            {
                string sForeignKeyInMaster = ei.ForeignKeyInMaster(tbl);
                if (sForeignKeyInMaster != "")
                {
                    nSlaveIdx++;
                    string sSlaveName = "tblSlave" + nSlaveIdx;
                    sFromSql += "   " + EditableTable.JoinName[(int)tbl.Join] + QuoteField(tbl) + " " + sSlaveName + "  ON tblMaster." + QuoteField(sForeignKeyInMaster) + "=" + sSlaveName + "._ID \n";
                    sSql += "    ";
                    foreach (Field fld in tbl.Fields)
                    {
                        if (bOnlyArray == false ||
                            (bOnlyArray && (fld.name.Equals("Name", StringComparison.OrdinalIgnoreCase) || fld.name.Equals("_Status", StringComparison.OrdinalIgnoreCase)))) //bOnlyArray时只取名字和状态
                        {
                            if (!fld.name.Equals(ei.sSlaveKey, StringComparison.OrdinalIgnoreCase))
                                sSql += "," + sSlaveName + "." + QuoteField(fld);
                        }

                        if (sNameInSlave == "" && fld.name.Equals("Name", StringComparison.OrdinalIgnoreCase))
                            sNameInSlave = sSlaveName + "." + QuoteField(fld);

                        if( (fld.editor& Editor.order)!= Editor.none )
                            sOrderFld = sSlaveName + "." + QuoteField(fld);
                    }
                    sSql += "\n";
                }
            }
            sSql += sFromSql;

            if (sNameInSlave != "")
            {
                if (!string.IsNullOrEmpty(sNameFilter))
                    sSql += "    WHERE " + sNameInSlave + " LIKE '%" + sSql.Replace("'", "''") + "%' \n";

                if (sOrderFld != "")
                    sOrderFld = sOrderFld + "," + sNameInSlave;
                else
                    sOrderFld = sNameInSlave;
            }

            if (sOrderFld != "")
                sSql += "   ORDER BY " + sOrderFld;

            return sSql;
        }

        private void AddFieldValue(changeStatus nStatus, Field Fld, Dictionary<string, object> row, EmployeeInfo emp,string HistoryForeignKey, ref string sSql,ref string sValList)
        {
            //if (Fld.editor == Editor.none)
            //    return;

            string sVal = QuoteNull;
            object val = null;

            if ((Fld.editor & Editor.order) != Editor.none)
                val = row["__index"];
            else if (row.ContainsKey(Fld) && row[Fld] != null)
            {
                val = row[Fld];
                if (Fld.type == FieldType.Int && Cvt.IsNumerical(val) == false)
                    val = null;
            }
            else if (nStatus == changeStatus.AddHistory)
            {
                if (sSql.Length > 0) sSql += ",";
                sSql += QuoteField(Fld);

                if (sValList.Length > 0) sValList += ",";

                if (Fld.name.Equals("Update_Time", StringComparison.OrdinalIgnoreCase)
                    || Fld.name.Equals("Create_Time", StringComparison.OrdinalIgnoreCase))
                    sValList += FuncCurrentTimestamp;
                else
                    sValList += QuoteField(Fld);

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
            else if (Fld.name.Equals("_Employee_Update", StringComparison.OrdinalIgnoreCase))
            {
                if (nStatus == changeStatus.Where)
                    return;

                sVal = emp._Employee.ToString();
            }
            //else if (val == null && Fld.name.Equals("_Site", StringComparison.OrdinalIgnoreCase))
            //{
            //    sVal = emp._Site_Working.ToString();
            //}
            //else if (val == null && Fld.name.Equals("_Project", StringComparison.OrdinalIgnoreCase))
            //{
            //    sVal = emp._Project_Working.ToString();
            //}
            else if (Fld.name.Equals(HistoryForeignKey, StringComparison.OrdinalIgnoreCase) && nStatus == changeStatus.Add)
            {
                sVal = "@nLastPrimaryID";
            }
            else
            {
                try
                {
                    if (val != null)
                        sVal = Convert.ToInt64(val).ToString();
                    else if (nStatus != changeStatus.AddHistory)
                        return;
                }
                catch(Exception )
                {
                }
            }


            if (nStatus == changeStatus.Add)
            {
                if (Fld.name.Equals("Update_Time", StringComparison.OrdinalIgnoreCase) == false
                    && Fld.name.Equals("Create_Time", StringComparison.OrdinalIgnoreCase) == false)
                {
                    if (sSql.Length > 0) sSql += ",";
                    sSql += QuoteField(Fld);
                    
                    if (sValList.Length > 0) sValList += ",";
                    sValList += sVal;
                }
            }
            else if (nStatus == changeStatus.Update)
            {
                if (sSql.Length > 0) sSql += ",";

                if (Fld.name.Equals("Update_Time", StringComparison.OrdinalIgnoreCase)
                    || Fld.name.Equals("Create_Time", StringComparison.OrdinalIgnoreCase))
                    sSql += QuoteField(Fld) + "=" + FuncCurrentTimestamp;
                else
                    sSql += QuoteField(Fld) + "=" + sVal;
            }
            else if (nStatus == changeStatus.Where)
            {
                if (Fld.name.Equals("Update_Time", StringComparison.OrdinalIgnoreCase)
                    || Fld.name.Equals("Create_Time", StringComparison.OrdinalIgnoreCase))
                    return;//条件语句不关心创建时间或更新时间
                else
                {
                    if (sSql.Length > 0) sSql += " AND ";
                    sSql += QuoteField(Fld) + "=" + sVal;
                }
            }
            else if (nStatus == changeStatus.AddHistory)
            {
                if (sSql.Length > 0) sSql += ",";
                sSql += QuoteField(Fld);

                if (sValList.Length > 0) sValList += ",";

                if (Fld.name.Equals("Update_Time", StringComparison.OrdinalIgnoreCase)
                    || Fld.name.Equals("Create_Time", StringComparison.OrdinalIgnoreCase))
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
                if (string.IsNullOrEmpty(sSql))
                    sSql = "DECLARE @nLastPrimaryID BIGINT,@nLastID BIGINT; \n";

                if (nStatus == changeStatus.Add)
                {
                    foreach (Field fld in ei.MasterTable.Fields)
                    {
                        //if (fld.editor != Editor.none)
                        AddFieldValue(nStatus, fld, row, emp, "", ref sSqlRow, ref sValList);
                    }

                   
                    if (sSqlRow.Length > 0)
                    {
                        sSql += BuildInsert(ei.MasterTable.sName, sSqlRow, sValList);
                        sSql += "SET @nLastPrimaryID=" + FuncLastInsertId + ";\n";
                    }
                    else
                        sSql += "SET @nLastPrimaryID=" + row[ei.sSlaveKey] + ";\n";

                    if (ei.SlaveTables != null)
                    {
                        foreach (EditableTable slave in ei.SlaveTables)
                        {
                            sValList = "";
                            sSqlRow = "";
                            foreach (Field fld in slave.Fields)
                                AddFieldValue(nStatus, fld, row, emp, ei.sSlaveKey, ref sSqlRow, ref sValList);

                            if (sSqlRow.Length > 0)
                            {
                                sSql += BuildInsert(slave.sName, sSqlRow, sValList);
                                string sForeignKeyInMaster = ei.ForeignKeyInMaster(slave.sName);
                                if (sForeignKeyInMaster.Length > 0)
                                    sSql += "UPDATE " + QuoteField(ei.MasterTable.sName) + " SET " + QuoteField(sForeignKeyInMaster) + "=" + FuncLastInsertId + " WHERE " + QuoteField("_ID") + "=@nLastPrimaryID;\n";
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
                    foreach (Field Fld in ei.MasterTable.Fields)
                    {
                        if (row.ContainsKey(Fld))
                            AddFieldValue(changeStatus.Update, Fld, row, emp, "", ref sSqlRow, ref sValList);
                    }

                    string sPrimaryKey = ei.sSlaveKey;
                    if (!row.ContainsKey(sPrimaryKey))
                        sPrimaryKey = "_ID";

                    if (sSqlRow.Length > 0)
                        sSql += "UPDATE " + QuoteField(ei.MasterTable.sName) + " SET " + sSqlRow + " WHERE " + QuoteField("_ID") + "=" + row[sPrimaryKey] + ";\n";

                    if (ei.SlaveTables != null)
                    {
                        foreach (EditableTable slave in ei.SlaveTables)
                        {
                            string sForeignKeyInMaster = ei.ForeignKeyInMaster(slave.sName);
                            if (sForeignKeyInMaster.Length == 0)
                                continue;

                            //先构造添加到Histry表中的语句
                            sValList = "";
                            sSqlRow = "";
                            foreach (Field Fld in slave.Fields)
                                AddFieldValue(changeStatus.AddHistory, Fld, row, emp, ei.sSlaveKey, ref sSqlRow, ref sValList);

                            string sSelectPrimary= "SELECT @nLastID=" + QuoteField(sForeignKeyInMaster) + " FROM " + QuoteField(ei.MasterTable.sName) + " WHERE  " + QuoteField("_ID") + "=" + row[sPrimaryKey] + " ;\n";
                            
                            string sInsertSql = " INSERT INTO " + QuoteField(slave.sName) + "(" + sSqlRow + ") \n"
                                + "    SELECT " + sValList + " FROM " + QuoteField(slave.sName) + " WHERE " + QuoteField("_ID") + "=@nLastID;\n";

                            //再决定是是否需要检查确实有更改
                            if (!bCheckChanged)
                                sSql += sSelectPrimary + sInsertSql;
                            else
                            {
                                sValList = "";
                                sSqlRow = "";

                                foreach (Field Fld in slave.Fields)
                                {
                                    if (row.ContainsKey(Fld) && ei.sSlaveKey.Equals(Fld,StringComparison.OrdinalIgnoreCase)==false )
                                        AddFieldValue(changeStatus.Where, Fld, row, emp, ei.sSlaveKey, ref sSqlRow, ref sValList);
                                }
                                if (sSqlRow.Length > 0)
                                {
                                    string sUpdateSql = "";
                                    if (!string.IsNullOrEmpty(sForeignKeyInMaster))
                                        sUpdateSql = " UPDATE " + QuoteField(ei.MasterTable.sName) + " SET "
                                            + QuoteField(sForeignKeyInMaster) + "=" + FuncLastInsertId + " WHERE " + QuoteField("_ID") + "=" + row[sPrimaryKey] + ";\n";

                                    sSql += sSelectPrimary;
                                    sSql += "IF NOT EXISTS(SELECT * FROM " + QuoteField(slave.sName) + " WHERE  " + QuoteField("_ID") + "=@nLastID AND " + sSqlRow + ") \n"
                                        + "BEGIN\n"
                                        + sInsertSql
                                        + sUpdateSql
                                        + "END;\n";
                                }
                            }
                        }
                    }//END OF if (ei.SlaveTables != null)
                }
            }
        }

        public override DataTable GetEditableTable(EditableInfo ei, bool bOnlyArray, string sNameFilter)
        {
            string sSql = "";
            if (ei.Sql != null)
                sSql = ei.Sql;
            else if (ei.BuildSelectSql != null)
                sSql = ei.BuildSelectSql(ei,bOnlyArray, sNameFilter);
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
                    if ((ei.Option | Option.ManualSort) != Option.None && sStatus == "nochanged")
                        sStatus = "update";

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
                DbTransaction objTrans = BeginTransaction();
                try
                {
                    ExecuteNonQuery(objTrans, sSql);
                }
                catch (Exception ex)
                {
                    //WriteExceptionLogForDAL
                    objTrans.Rollback();
                    throw ex;
                }
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