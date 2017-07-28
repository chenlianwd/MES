using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.Reflection;
using System.IO;
using System.Web;
using System.Data;
using System.Security.Cryptography;
using System.Runtime.InteropServices;
using System.Web.Hosting;
using System.Xml;
//using Microsoft.Web.Administration;

using PS;

namespace PS
{
    public class Common
    {
        private static LanguageHelper _LanguageHelper = null;
        public static LanguageHelper LanguageHelper
        {
            get
            {
                if (_LanguageHelper == null)
                    _LanguageHelper = new LanguageHelper();
                return _LanguageHelper;
            }
        }

        private static readonly EditableInfo[] _EditableList = new EditableInfo[]
        {
             new EditableInfo("_Employee",null,"_Employee",new EditableTable("ps_Employee",new Field[] { "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none),new Field("_Last_Login_History" ,Editor.none)})
                 ,new EditableTable[] {new EditableTable( "ps_Employee_History",new Field[] { new Field("_Employee",Editor.none),new Field("_Site",Editor.none),new Field("_BU",80,Editor.HasNA|Editor.select)
                            ,new Field("_Project",80,Editor.HasNA|Editor.select),new Field("_Department",80,Editor.HasNA|Editor.select),"Name","Password"//,"_Attachment_Gravatar"
                            ,"Fullname","Description","Email_Address","Telphone_Number",new Field("Use_AD_Login","Use AD?",80,Editor.chk),"AD_Account"//,"Language","Time_Zone"
                            ,new Field("Change_Pwd_When_Next_Login","Change Pwd?",100,Editor.chk) ,new Field("_Status","Enable?",60, Editor.chk)
                            ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                            ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)})
                  //,new EditableTable("ps_Login_History",Join.Left, new Field[] { new Field("_Employee",Editor.readOnly),new Field("Login_Attempt",Editor.readOnly)
                      //    , new Field("From_IP",Editor.readOnly),  new Field("From_MAC",Editor.readOnly), new Field("From_Host",Editor.readOnly)
                      //    ,new Field("Login_Time","Login Time",130,Align.right,Editor.readOnly,FieldType.datetime),  new Field("_Login_Result",Editor.readOnly) })
                  })
            ,new EditableInfo("loginHistory",null,"_Employee","ps_Employee",new Field[]{ new Field("_Last_Login_History",Editor.none)}
                  ,"ps_Login_History", new Field[] { "_Employee","Login_Attempt","From_IP","From_MAC","From_Host","_Login_Result" })
            ,new EditableInfo("_Department",null,"_Department",Option.HasOwner, "ps_Department",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)}
                  ,"ps_Department_History", new Field[] {  new Field("_Department",Editor.none),new Field("_Site",Editor.none),"Name","Description"
                        //,new Field("_Shift",80,Editor.HasNA|Editor.select) 
                        ,new Field("_Employee_Owner",80,Editor.HasNA|Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)})
            ,new EditableInfo("_Group",null,"_Group",Option.HasOwner,"ps_Group",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)}
                  ,"ps_Group_History", new Field[] {  new Field("_Group",80,Editor.none),new Field("_Site",Editor.none),"Name","Description"
                        ,new Field("_Workshop",80,Editor.HasNA|Editor.select) ,new Field("_Department",80,Editor.HasNA|Editor.select),new Field("_Line",80,Editor.HasNA|Editor.select)
                        ,new Field("_BU",80,Editor.HasNA|Editor.select),new Field("_Project",80,Editor.HasNA|Editor.select),new Field("_Shift",80,Editor.HasNA|Editor.select)
                        ,new Field("_Employee_Owner",80,Editor.HasNA|Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)})
            ,new EditableInfo("Employee_In_Group",null,"",new EditableTable("ps_Employee_In_Group",new Field[]{ new Field("_Group",Editor.select),new Field("_Employee",Editor.select)
                        ,new Field("_Status","Enable?",60, Editor.chk) ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)})
                  ,new EditableTable[] {})
             ,new EditableInfo("_Building",null,"_Building",Option.HasOwner,new EditableTable("ps_Building",new Field[] { "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Building_History",new Field[] { new Field("_Building",Editor.none),new Field("_Site",Editor.none),"Name","Description"
                       ,new Field("_Employee_Owner",80,Editor.HasNA|Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                       ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                       ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Workshop",null,"_Workshop",Option.HasOwner,new EditableTable("ps_Workshop",new Field[] { "Name",new Field("_Site",Editor.none),new Field("_Building",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Workshop_History",new Field[] { new Field("_Workshop",Editor.none),new Field("_Site",Editor.none),new Field("_Building",Editor.none),"Name","Description"
                       ,new Field("_Employee_Owner",80,Editor.HasNA|Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                       ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                       ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
             ,new EditableInfo("_Shift_Segment",null,"_Shift_Segment",Option.HasOwner,new EditableTable("ps_Shift_Segment",new Field[] { "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Shift_Segment_History",new Field[] { new Field("_Shift_Segment",Editor.none),new Field("_Site",Editor.none),"Name","Description"
                      ,new Field("Start_Time",80,Editor.text,FieldType.time) ,new Field("EndIntervalMinutes","End Interval Minutes",80, Editor.text,FieldType.Int) 
                      ,new Field("_Employee_Owner",80,Editor.HasNA|Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                      ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                      ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
             ,new EditableInfo("_Shift",null,"_Shift",new EditableTable("ps_Shift",new Field[] { "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Shift_History",new Field[] { new Field("_Shift",Editor.none),new Field("_Site",Editor.none),"Name","Description"
                       ,new Field("_Status","Enable?",60, Editor.chk) 
                       ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                       ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
           ,new EditableInfo("_Line",null,"_Line",Option.HasOwner,new EditableTable("ps_Line",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Line_History", new Field[] {  new Field("_Line",80,Editor.none),new Field("_Site",Editor.none),"Name","Description"
                        ,new Field("_Workshop",80,Editor.HasNA|Editor.select) ,new Field("_BU",80,Editor.HasNA|Editor.select),new Field("_Project",80,Editor.HasNA|Editor.select)
                        ,new Field("_Shift",80,Editor.HasNA|Editor.select) ,new Field("_Employee_Owner",80,Editor.HasNA|Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
           ,new EditableInfo("_BU",null,"_BU",Option.HasOwner,new EditableTable("ps_BU",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_BU_History", new Field[] {  new Field("_BU",80,Editor.none),new Field("_Site",Editor.none),"Name","Description"
                        ,new Field("_Workshop",80,Editor.HasNA|Editor.select) ,new Field("_Employee_Owner",80,Editor.HasNA|Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Project",null,"_Project",Option.HasOwner,new EditableTable("ps_Project",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Project_History", new Field[] {  new Field("_Project",80,Editor.none),new Field("_Site",Editor.none)
                        ,new Field("_BU",80,Editor.select) ,"Name","Description",new Field("Folder_For_Project_Attachments","Folder For Attachments")
                        ,new Field("_Employee_Owner",80,Editor.HasNA|Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Page",null,"_Page",Option.HasOwner|Option.ManualSort,new EditableTable("ps_Page",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Page_History", new Field[] {  new Field("_Page",80,Editor.none),"Name","Description"
                        ,new Field("_Order",80,Editor.order)  
                        ,new Field("_BU",80,Editor.HasNA|Editor.select) ,new Field("_Project",80,Editor.HasNA|Editor.select) 
                        ,new Field("_Employee_Owner",80,Editor.HasNA|Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Measurement_Limit",null,"_Measurement_Limit",new EditableTable("ps_Measurement_Limit",new Field[]{ "Name",new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Measurement_Limit_History", new Field[] {  new Field("_Measurement_Limit",80,Editor.none),"Name","Description"
                        ,new Field("Low_Limit",80,Editor.text) ,new Field("Update_Limit",80,Editor.text) ,new Field("LogicTarget",80,Editor.text) 
                        ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)})) 
            ,new EditableInfo("_Indicator_Action_Value",null,"_Indicator_Action_Value",new EditableTable("ps_Indicator_Action_Value",new Field[]{ "Name",new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Indicator_Action_Value_History", new Field[] {  new Field("_Indicator_Action_Value",80,Editor.none),"Name","Description"
                        ,new Field("_Indicator_Action",80,Editor.select) ,new Field("Action_Value",80,Editor.text) 
                        ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
             ,new EditableInfo("_Indicator_Action_Group",null,"_Indicator_Action_Group",new EditableTable("ps_Indicator_Action_Group",new Field[]{ "Name",new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Indicator_Action_Value_History", new Field[] {  new Field("_Indicator_Action_Group",80,Editor.none),"Name","Description"                        
                        ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("Indicator_Action_Value_In_Group",null,"",Option.Group, new EditableTable("ps_Indicator_Action_Value_In_Group",new Field[]{ new Field("_Indicator_Action_Group",Editor.select),new Field("_Indicator_Action_Value",Editor.select) 
                        ,new Field("_Status","Enable?",60, Editor.chk) ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)})
                  ,new EditableTable[] {})
             ,new EditableInfo("_Indicator_Action",null,"",Option.ReadOnly,new EditableTable("ps_Indicator_Action",new Field[]{new Field("Name",300)})
                  ,new EditableTable[] {})
            ,new EditableInfo("_Measurement_Type",null,"",Option.ReadOnly, new EditableTable("ps_Measurement_Type",new Field[]{new Field("Name",300)})
                  ,new EditableTable[] {})
            ,new EditableInfo("_Measurement_Period",null,"",Option.ReadOnly,new EditableTable("ps_Measurement_Period",new Field[]{new Field("Name",300)})
                  ,new EditableTable[] {})
            ,new EditableInfo("_Indicator",null,"_Indicator",new EditableTable("ps_Indicator",new Field[]{ "Name",new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Indicator_History", new Field[] {  new Field("_Indicator",80,Editor.none),"Name","Description"
                        ,new Field("_Object_Type_First",80,Editor.select) ,new Field("_Object_ID_First",80,Editor.select)
                        ,new Field("_Object_Type_Second",80,Editor.HasNA|Editor.select) ,new Field("_Object_ID_Second",80,Editor.HasNA|Editor.select)
                        ,new Field("_Object_Type_Thrid",80,Editor.HasNA|Editor.select) ,new Field("_Object_ID_Thrid",80,Editor.HasNA|Editor.select)
                        ,new Field("_Object_Type_Fourth",80,Editor.HasNA|Editor.select) ,new Field("_Object_ID_Fourth",80,Editor.HasNA|Editor.select)
                        ,new Field("_Measurement_Period",80,Editor.select) ,new Field("_Measurement_Period",80,Editor.select)
                        ,new Field("_Measurement_Type",80,Editor.select) ,new Field("_Measurement_Type",80,Editor.select)
                        ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Indicator_Level",null,"",new EditableTable("ps_Indicator_Level",new Field[]{ new Field("_Indicator",Editor.select),new Field("_Priority",Editor.none)
                        ,new Field("_Measurement_Limit",Editor.select),new Field("_Indicator_Action_Group",Editor.select)
                        ,new Field("_Status","Enable?",60, Editor.chk) ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)})
                  ,new EditableTable[] {})
            ,new EditableInfo("_Indicator_Reason",null,"_Indicator_Reason",new EditableTable("ps_Indicator_Reason",new Field[]{ "Name",new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Indicator_Reason_History", new Field[] {  new Field("_Indicator_Reason",80,Editor.none),"Name","Description"                        
                        ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Indicator_Group",null,"_Indicator_Group",new EditableTable("ps_Indicator_Group",new Field[]{ "Name",new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Indicator_Group_History", new Field[] { "Name","Description"                        
                        ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("Indicator_In_Group",null,"",new EditableTable("ps_Indicator_In_Group",new Field[]{ new Field("_Indicator_Group",Editor.select),new Field("_Indicator",Editor.select)
                        ,new Field("_Status","Enable?",60, Editor.chk) ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)})
                  ,new EditableTable[] {})
            ,new EditableInfo("_Station_Template",null,"_Station_Template",new EditableTable("ps_Station_Template",new Field[]{ "Name",new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Station_Template_History", new Field[] {  new Field("_Station_Template",80,Editor.none),"Name","Description" ,"Handle_Assembly"                       
                        ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Station_Catalog",null,"_Station_Catalog",new EditableTable("ps_Station_Catalog",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Station_Catalog_History", new Field[] {  new Field("_Station_Catalog",80,Editor.none),new Field("_Site",Editor.none),"Name","Description"                       
                        ,new Field("_Employee_Owner",80,Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Station_Type",null,"_Station_Type",new EditableTable("ps_Station_Type",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Project",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Station_Type_History", new Field[] {  new Field("_Station_Type",80,Editor.none),new Field("_Site",Editor.none),new Field("_Project",Editor.HasNA|Editor.select)
                        ,new Field("_Station_Catalog",Editor.HasNA|Editor.select),new Field("_Station_Template",Editor.HasNA|Editor.select),"Name","Description","Handle_Assembly" ,"Folder_For_Attachments" 
                        ,new Field("_Employee_Owner",80,Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Station",null,"_Station",Option.HasOwner,new EditableTable("ps_Station",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Station_History", new Field[] {  new Field("_Station",80,Editor.none),new Field("_Site",Editor.none)
                        ,new Field("_Line",Editor.select),new Field("_Station_Type",Editor.select),"Name","Description","HostName" ,"MAC_Address" ,"Guid_ID" 
                        ,new Field("_BU",Editor.HasNA|Editor.select),new Field("_Project",Editor.HasNA|Editor.select)
                        ,new Field("_Employee_Owner",80,Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Fixture",null,"_Fixture",Option.HasOwner,new EditableTable("ps_Fixture",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Fixture_History", new Field[] {  new Field("_Fixture",80,Editor.none),new Field("_Site",Editor.none)
                        ,"Name","Description","Guid_ID"
                        ,new Field("_Workshop",Editor.HasNA|Editor.select),new Field("_Line",Editor.HasNA|Editor.select),new Field("_Station",Editor.HasNA|Editor.select)
                        ,new Field("_BU",Editor.HasNA|Editor.select),new Field("_Project",Editor.HasNA|Editor.select)
                        ,new Field("_Employee_Owner",80,Editor.select) ,new Field("_Status","Enable?",60, Editor.chk) 
                        ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Part_Family",null,"_Part_Family",Option.HasOwner,new EditableTable("ps_Part_Family",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Part_Family_History", new Field[] {  new Field("_Part_Family",80,Editor.none),new Field("_Site",Editor.none)
                        ,"Name","Description"                        
                        ,new Field("_BU",Editor.HasNA|Editor.select),new Field("_Project",Editor.HasNA|Editor.select)                        
                        ,new Field("_Status","Enable?",60, Editor.chk) ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
            ,new EditableInfo("_Part_Number",null,"_Part_Number",Option.HasOwner,new EditableTable("ps_Part_Number",new Field[]{ "Name",new Field("_Site",Editor.none),new Field("_Last_History",Editor.none)})
                  ,new EditableTable("ps_Part_Number_History", new Field[] {  new Field("_Part_Number",80,Editor.none),new Field("_Site",Editor.none)
                         ,new Field("_Part_Family",Editor.HasNA|Editor.select),"Name","Description","UOM",new Field("IsUnit",Editor.chk)                          
                        ,new Field("_BU",Editor.HasNA|Editor.select),new Field("_Project",Editor.HasNA|Editor.select)                        
                        ,new Field("_Status","Enable?",60, Editor.chk) ,new Field("_Employee_Update","Update By Employee",130,Editor.readOnly|Editor.select)
                        ,new Field("Update_Time","Update Time",130,Align.right,Editor.readOnly|Editor.datetime,FieldType.datetime)}))
        };
        public static EditableInfo[] EditableList
        {
            get { return _EditableList; }
        }
        public static EditableInfo SelectEditableInfo(string sName)
        {
             foreach (EditableInfo ei in EditableList)
            {
                if (sName.Equals(ei.EditableName, StringComparison.OrdinalIgnoreCase))
                    return  ei;
            }
             return null;
        }

        /// <summary>
        /// 设置/获取显示文本所选用的语言
        /// </summary>
        public static string Language
        {
            get
            {
                return LanguageHelper.Language;
            }
            set
            {
                LanguageHelper.Language = value;
            }
        }

        /// <summary>
        /// 创建当前目录或当前目录下bin目录中所有继承自指定基类的类型清单
        /// </summary>
        /// <param name="baseType">基类</param>
        /// <returns>所有继承自指定基类的类型清单</returns>
        public static Type[] GetAllSubClass(Type baseType)
        {
            List<Type> lst = new List<Type>();
            string sPath = Path.GetDirectoryName(AppDomain.CurrentDomain.BaseDirectory);
            if (Directory.Exists(Path.Combine(sPath, "bin")))
                sPath = Path.Combine(sPath, "bin");

            Assembly assembly = null;
            foreach (string sFile in Directory.GetFiles(sPath))
            {
                try
                {
                    assembly = Assembly.LoadFile(sFile);
                    Type[] types = assembly.GetTypes();
                    foreach (Type ty in types)
                    {
                        if (ty.IsSubclassOf(baseType))
                            lst.Add(ty);
                    }
                }
                catch (Exception)
                {
                }
            }

            return lst.ToArray();
        }

        /// <summary>
        /// 创建当前目录或当前目录下bin目录中所有继承自指定基类的所有类的实例
        /// </summary>
        /// <typeparam name="baseType">基类</typeparam>
        /// <returns>所有指定基类的实例数组</returns>
        public static baseType[] LoadAllSubClass<baseType>() where baseType : class
        {         
            List<baseType> lst = new List<baseType>();
            string sPath = Path.GetDirectoryName(AppDomain.CurrentDomain.BaseDirectory);
            if (Directory.Exists(Path.Combine(sPath, "bin")))
                sPath = Path.Combine(sPath, "bin");

            Assembly assembly = null;
            object obj = null;
            foreach (string sFile in Directory.GetFiles(sPath))
            {
                try
                {
                    assembly = Assembly.LoadFile(sFile);
                    Type[] types = assembly.GetTypes();
                    foreach (Type ty in types)
                    {
                        if (ty.IsSubclassOf(typeof(baseType)))
                        {
                            obj = assembly.CreateInstance(ty.ToString());
                            if (obj != null)
                                lst.Add(obj as baseType);
                        }
                    }
                }
                catch (Exception)
                {
                }
            }

            return lst.ToArray();
        }
        private static DALBase _DAL = null;
        /// <summary>
        /// 整个应用使用的DAL对象
        /// </summary>
        public static DALBase DAL
        {
            get
            {
                if (_DAL == null)
                    RenewDAL();

                return _DAL;
            }
        }
        /// <summary>
        /// 用于在主数据库连接更改时，重置内部的数据库连接
        /// </summary>
        public static void RenewDAL()
        {
#if WEB_DEBUG
            _DAL = new DAL_SqlServer();
#else
            //_DAL = LoadAssembly(typeof(DALBase)) as DALBase;
            string sDALName = readConfig("DAL_Assembly", "DAL_SqlServer");
            DALBase[] DalLst = Common.LoadAllSubClass<DALBase>();
            foreach (DALBase dal in DalLst)
            {
                if (dal.GetType().Name.Equals(sDALName, StringComparison.OrdinalIgnoreCase))
                {
                    _DAL = dal;
                    return;
                }
            }
#endif
        }
        /// <summary>
        /// 按指定的类型加载DLL,并创建指定类型的继承实例
        /// </summary>
        /// <param name="type">基类类型</param>
        /// <returns>指定类型的继承实例</returns>
        private static object LoadAssembly(Type type)
        {
            string sPath = Path.GetDirectoryName(AppDomain.CurrentDomain.BaseDirectory);
            if (Directory.Exists(Path.Combine(sPath, "bin")))
                sPath = Path.Combine(sPath, "bin");

            openConfig();

            string sAssemblyFile = null;
            try
            {
                sAssemblyFile = _config.AppSettings.Settings[type.Name + "_Assembly_File"].Value;
            }
            catch (Exception)
            {
            }
            if (sAssemblyFile == null || (sAssemblyFile != null && sAssemblyFile.Trim().Length == 0))
            {
                sAssemblyFile = type.Name + ".dll";
                SaveConfigSetting(_config, type.Name + "_Assembly_File", sAssemblyFile);
            }
            string sAssembly = null;
            try
            {
                sAssembly = _config.AppSettings.Settings[type.Name + "_Assembly"].Value;
            }
            catch (Exception)
            {
            }

            Assembly assembly = null;
            object obj = null;
            try
            {
                assembly = Assembly.LoadFile(Path.Combine(sPath, sAssemblyFile));
                obj = assembly.CreateInstance(sAssembly);
                if (!type.IsInstanceOfType(obj))
                    obj = null;
            }
            catch (Exception)
            {
            }

            if (obj == null)
            {
                foreach (string sFile in Directory.GetFiles(sPath))
                {
                    try
                    {
                        assembly = Assembly.LoadFile(sFile);
                        Type[] types = assembly.GetTypes();
                        foreach (Type ty in types)
                        {
                            if (ty.IsSubclassOf(type))
                            {
                                obj = assembly.CreateInstance(ty.ToString());
                                sAssembly = ty.ToString();
                                sPath = sFile;
                                break;
                            }
                        }
                        if (obj != null)
                            break;
                    }
                    catch (Exception)
                    {
                    }
                }
                if (obj != null)
                {
                    writeConfig(type.Name + "_Assembly_File", sPath);
                    writeConfig(type.Name + "_Assembly", sAssembly);
                }
            }
            return obj;
        }

        private static void SaveConfigSetting(Configuration config, string sKey, string sVal)
        {
            if (config.AppSettings.Settings[sKey] == null)
                config.AppSettings.Settings.Add(sKey, sVal);
            else
                config.AppSettings.Settings[sKey].Value = sVal;
        }
        /// <summary>
        /// DES加密字符串
        /// </summary>
        /// <param name="encryptString">待加密的字符串</param>
        /// <param name="encryptKey">加密密钥,要求为8位</param>
        /// <returns>加密成功返回加密后的字符串，失败返回源串</returns>
        public static string EncryptDES(string encryptString, byte[] rgbIV, byte[] rgbKey)
        {
            byte[] inputByteArray = Encoding.UTF8.GetBytes(encryptString);
            DESCryptoServiceProvider dCSP = new DESCryptoServiceProvider();
            MemoryStream mStream = new MemoryStream();
            CryptoStream cStream = new CryptoStream(mStream, dCSP.CreateEncryptor(rgbKey, rgbIV), CryptoStreamMode.Write);
            cStream.Write(inputByteArray, 0, inputByteArray.Length);
            cStream.FlushFinalBlock();
            return Convert.ToBase64String(mStream.ToArray());
        }
        /// <summary>
        /// DES解密字符串
        /// </summary>
        /// <param name="decryptString">待解密的字符串</param>
        /// <param name="decryptKey">解密密钥,要求为8位,和加密密钥相同</param>
        /// <returns>解密成功返回解密后的字符串，失败返源串</returns>
        public static string DecryptDES(string decryptString, byte[] rgbIV, byte[] rgbKey)
        {
            if (string.IsNullOrEmpty(decryptString))
                return "";

            byte[] inputByteArray =   Convert.FromBase64String(decryptString);
            DESCryptoServiceProvider DCSP = new DESCryptoServiceProvider();
            MemoryStream mStream = new MemoryStream();
            CryptoStream cStream = new CryptoStream(mStream, DCSP.CreateDecryptor(rgbKey, rgbIV), CryptoStreamMode.Write);
            cStream.Write(inputByteArray, 0, inputByteArray.Length);
            cStream.FlushFinalBlock();
            return Encoding.UTF8.GetString(mStream.ToArray());
        }


        public static string GetHostName(string sIP)
        {
            //string sIP = Page.Request.UserHostAddress;
            string sHostName = "";
            try
            {
                sHostName = System.Net.Dns.GetHostEntry(sIP).HostName;
                if (sHostName.Length != 0)
                    sHostName = sHostName.Substring(0, sHostName.IndexOf('.'));
            }
            catch { };
            if (sHostName.Length == 0)
            {
                string sMac = GetCustomerMacByArp(sIP);
                sHostName = sIP;
                if (sMac.Length > 0) sHostName += "," + sMac;
            };
            return sHostName;
        }
        [DllImport("Iphlpapi.dll")]
        private static extern int SendARP(Int32 dest, Int32 host, ref ulong byteMac, ref Int32 length);
        [DllImport("Ws2_32.dll")]
        private static extern Int32 inet_addr(string ip);
        public static string GetCustomerMacByArp(string sIP)
        {

            Int32 ldest = inet_addr(sIP); //目的地的ip 
            //Int32 lhost = inet_addr("");    //本地服务器的ip 
            ulong PMAC=0;
            Int32 len = 6;
            string mac_src = "";
            if (SendARP(ldest, 0, ref PMAC, ref len) == 0)
            {
                byte[] byteMac = BitConverter.GetBytes(PMAC);
                for (int i = 0; i<len; i++)
                {
                    if (mac_src.Length > 0)
                        mac_src += "-";
                    mac_src += byteMac[i].ToString("X2");
                }
            }
            return mac_src;
        }

        //public static Configuration GetConfiguration()
        //{
        //    if (HostingEnvironment.ApplicationVirtualPath == "/")
        //        return WebConfigurationManager.OpenWebConfiguration("~/web.config");

        //    WebConfigurationFileMap fileMap = CreateFileMap(HostingEnvironment.ApplicationVirtualPath);
        //    // Get the Configuration object for the mapped virtual directory.
        //    return WebConfigurationManager.OpenMappedWebConfiguration(fileMap, HostingEnvironment.ApplicationVirtualPath);
        //}

        //private static WebConfigurationFileMap CreateFileMap(string applicationVirtualPath)
        //{

        //    WebConfigurationFileMap fileMap =
        //           new WebConfigurationFileMap();

        //    // Get he physical directory where this app runs. 
        //    // We'll use it to map the virtual directories 
        //    // defined next.  
        //    string physDir = HostingEnvironment.ApplicationPhysicalPath;

        //    // Create a VirtualDirectoryMapping object to use 
        //    // as the root directory for the virtual directory 
        //    // named config.  
        //    // Note: you must assure that you have a physical subdirectory 
        //    // named config in the curremt physical directory where this 
        //    // application runs.
        //    VirtualDirectoryMapping vDirMap =
        //        new VirtualDirectoryMapping(physDir, true);

        //    // Add vDirMap to the VirtualDirectories collection  
        //    // assigning to it the virtual directory name.
        //    fileMap.VirtualDirectories.Add(applicationVirtualPath, vDirMap);

        //    // Create a VirtualDirectoryMapping object to use 
        //    // as the default directory for all the virtual  
        //    // directories.
        //    VirtualDirectoryMapping vDirMapBase =
        //        new VirtualDirectoryMapping(physDir, true, "web.config");

        //    // Add it to the virtual directory mapping collection.
        //    fileMap.VirtualDirectories.Add("/", vDirMapBase);

        //    // Return the mapping. 
        //    return fileMap;
        //}

        private static Configuration _config = null;
        private static void openConfig()
        {
            if (_config == null)
            {
                //try
                //{
                    string sPath = Path.GetDirectoryName(AppDomain.CurrentDomain.BaseDirectory);
                    sPath = Path.Combine(Path.Combine(sPath, "config"), "Preferences.xml");

                    ExeConfigurationFileMap configMap = new ExeConfigurationFileMap();
                    configMap.ExeConfigFilename = sPath;
                     _config = ConfigurationManager.OpenMappedExeConfiguration(configMap, ConfigurationUserLevel.None);

                    //if (HostingEnvironment.ApplicationVirtualPath == "/")
                    //    _config = System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration(null);//System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration("~");
                //}
                //catch (Exception ex)
                //{
                //    _config = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
                //}
            }
        }
        public static void writeConfig(string sKey, string sValue)
        {
            openConfig();

            if (_config.AppSettings.Settings[sKey] == null)
                _config.AppSettings.Settings.Add(sKey, sValue);
            else
                _config.AppSettings.Settings[sKey].Value = sValue;

            //_config.Save(ConfigurationSaveMode.Modified);
            _config.Save(ConfigurationSaveMode.Full);            
            ConfigurationManager.RefreshSection("appSettings"); //刷新，否则程序读取的还是之前的值（可能已装入内存）
            _config = null;
        }

        public static string readConfig(string sKey, string sDefValue)
        {
            openConfig();

            if (_config.AppSettings.Settings[sKey] == null)
            {
                _config.AppSettings.Settings.Add(sKey, sDefValue);
                _config.Save(ConfigurationSaveMode.Modified);
                 ConfigurationManager.RefreshSection("appSettings"); //刷新，否则程序读取的还是之前的值（可能已装入内存）
            }

            return _config.AppSettings.Settings[sKey].Value;
        }

        public Common()
        {


        }
    }
}
