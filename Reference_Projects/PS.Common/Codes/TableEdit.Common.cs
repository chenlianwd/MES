using System;
using System.Collections.Generic;
using System.Text;
using System.Data;

namespace PS
{
    public enum changeStatus
    {
        Update = 1,
        Add = 2,
        Delete = 3,
        AddHistory = 5,
        Where = 6
    }
    public enum RequestPurpose
    {
        Get = 1,
        Update = 2
    }
    public delegate string delegateBuildSelectSql(EditableInfo ei, bool bOnlyArray, string sNameFilter);
    public enum Align
    {
        right=1,
        left=2,
        center=3
    }
    public enum Editor
    {
        none=0,
        chk=1,
        text=2,        
        password=3,
        datetime=4,
        date = 5,
        time = 6,
        select = 7,
        order=0x400,
        readOnly=0x800,
        MaskReadOnly=0xFF,
        HasNA =0x80,
        MaskNA = 0xF0F
    }    
    public enum FieldType
    {
        Int=0,
        text=1,
        datetime=2,
        date=3,
        time=4
    }
    public enum Join
    {
        Inner = 0,
        Left = 1,
        Right = 2,
        FullOuter = 3,
    }
    public enum Option
    {
        None = 0,
        HasOwner = 0x10,
        ManualSort = 0x20,
        ReadOnly = 0x40,
        Group = 0x80,
        HasStatus=0x100
    }
    public class Field
    {
        public string name { get; set; }
        public string display { get; set; }
        public long width { get; set; }
        public Align align { get; set; }
        public Editor editor { get; set; }
        public FieldType type { get; set; }
        public static readonly string[] FieldTypeName = {"int","text","datetime","date","time" };
        public Field(string sName,  Editor editor)
        {
            this.name = sName;
            this.editor = editor;
            this.type = this.editor == Editor.text ? FieldType.text : FieldType.Int;
            this.width = 120;
            this.align = Align.right;
            this.display = sName[0] == '_' ? sName.Substring(1) : sName;
        }    
        public Field(string sName, string  sTitle, long nWidth,Align align,Editor editor,FieldType type)
        {
            this.name = sName;
            this.display = sTitle;
            this.width = nWidth;
            this.align = align;
            this.editor = editor;
            this.type = type;
        }
        public Field(string sName, string sTitle, long nWidth,Editor editor, FieldType type)
        {
            this.name = sName;
            this.display = sTitle;
            this.width = nWidth;
            this.align = Align.right;
            this.editor = editor;
            this.type = type;
        }
        public Field(string sName, long nWidth, Editor editor, FieldType type)
        {
            this.name = sName;
            this.display = sName[0] == '_' ? sName.Substring(1) : sName; ;
            this.width = nWidth;
            this.align = Align.right;
            this.editor = editor;
            this.type = type;
        }  
        public Field(string sName, string sTitle, Editor editor)
        {
            this.name = sName;
            this.display = sTitle;
            this.width = 120;
            this.align = Align.right;
            this.editor = editor;
            this.type = this.editor == Editor.text ? FieldType.text : FieldType.Int;
        }
        public Field(string sName)
        {
            this.name = sName;      
            this.width = 120;
            this.align = Align.right;
            this.display = sName[0] == '_' ? sName.Substring(1) : sName;
            this.editor = sName[0] == '_' ?  Editor.select:Editor.text;
            this.type = this.editor == Editor.text ? FieldType.text : FieldType.Int;
        }
        public Field(string sName,int nWidth)
        {
            this.name = sName;
            this.width = nWidth;
            this.align = Align.right;
            this.display = sName[0] == '_' ? sName.Substring(1) : sName;
            this.editor = sName[0] == '_' ? Editor.select : Editor.text;
            this.type = this.editor == Editor.text ? FieldType.text : FieldType.Int;
        }       
        public Field(string sName, string sTitle, long nWidth, Editor editor)
        {
            this.name = sName;
            this.display = sTitle;
            this.editor = editor;
            this.type = this.editor == Editor.text ? FieldType.text : FieldType.Int;
            this.width = nWidth;
            this.align = Align.right;
        }
        public Field(string sName, long nWidth, Editor editor)
        {
            this.name = sName;
            this.display = sName[0] == '_' ? sName.Substring(1) : sName;
            this.editor = editor;
            this.type = this.editor == Editor.text ? FieldType.text : FieldType.Int;
            this.width = nWidth;
            this.align = Align.right;
        }
        public Field(string sName, string sTitle)
        {
            this.name = sName;
            this.display = sTitle;
            this.editor = sName[0] == '_' ? Editor.select : Editor.text;            
            this.type = this.editor == Editor.text?FieldType.text: FieldType.Int;
            this.width = 120;
            this.align = Align.right;
        }       
        public Field(string sName, string sTitle, int nWidth)
        {
            this.name = sName;
            this.display = sTitle;      
            this.width = nWidth;
            this.align = Align.right;
            this.editor = sName[0] == '_' ? Editor.select : Editor.text;
            this.type = this.editor == Editor.text ? FieldType.text : FieldType.Int;
        }
        public static implicit operator string(Field fld)//实现隐式转换Field为string数据类型的方法
        {
            return fld.name;
        }
        public static implicit operator Field(string ss)//实现隐式转换string为Field数据类型的方法
        {
            return new Field(ss);
        }
        public static string AdjustName(string sName)
        {
            if (sName.Equals("_Employee_Update", StringComparison.OrdinalIgnoreCase)
                || sName.Equals("_Employee_Owner", StringComparison.OrdinalIgnoreCase)
                || sName.Equals("_Employee_Create", StringComparison.OrdinalIgnoreCase))
                return "_Employee";
            else
                return sName;
        }
    }
    public class EditableTable
    {
        public string sName { get; set; }
        public Field[] Fields { get; set; }
        public Join Join { get; set; }
        public static readonly string[] JoinName = { " INNER JOIN ", " LEFT JOIN ", " RIGHT JOIN ", " FULL OUTER JOIN "};
        public EditableTable(string sTableName,  Field[]  Fields)
        {
            this.sName = sTableName;
            this.Fields = Fields;
            this.Join = Join.Inner;
        }
        public EditableTable(string sTableName, Join Join, Field[] Fields)
        {
            this.sName = sTableName;
            this.Fields = Fields;
            this.Join = Join;
        }
        public static implicit operator string(EditableTable tbl)//实现隐式转换EditableTable为string数据类型的方法
        {
            return tbl.sName;
        }
    }
    public class EditableInfo
    {
        public string EditableName;        
        public string JsonVarName;
        public Option Option;
        
        public string Sql;
        public delegateBuildSelectSql BuildSelectSql;
        public EditableTable MasterTable;
        public EditableTable[] SlaveTables;
        public string sSlaveKey;
        const string sPrefix = "ps",sLast= "_Last";
        public string ForeignKeyInMaster(string sSlaveTableName)
        {
            foreach(Field fld in MasterTable.Fields)
            {
                if (sSlaveTableName.Equals(sPrefix + fld.name, StringComparison.OrdinalIgnoreCase))
                    return fld.name;
                else if(fld.name.Length>sLast.Length && sSlaveTableName.Equals(sPrefix + fld.name.Substring(sLast.Length), StringComparison.OrdinalIgnoreCase))
                    return fld.name;
                else if (fld.name.Length > sLast.Length && sSlaveTableName.Equals(MasterTable.sName+ fld.name.Substring(sLast.Length), StringComparison.OrdinalIgnoreCase))
                    return fld.name;
            }

            return "";
        }
        public EditableInfo(string EditableName, string JsonVarName, string sSlaveKey, Option option, string MasterTable, Field[] MasterFields
            , string SlaveTable, Field[] SlaveFileds,delegateBuildSelectSql delegateBuildSelectSql)
        {
            this.EditableName = EditableName;            
            this.JsonVarName = JsonVarName;
            this.sSlaveKey = sSlaveKey;
            this.MasterTable = new EditableTable(MasterTable,  MasterFields);          
            this.SlaveTables = new EditableTable[] {new EditableTable(SlaveTable,SlaveFileds) };
            this.Option = option;
            Sql = null;
            BuildSelectSql = delegateBuildSelectSql;
        }
        public EditableInfo(string EditableName, string JsonVarName, string sSlaveKey, Option option,  string MasterTable,  Field[] MasterFields
            , string SlaveTable,  Field[] SlaveFileds)
        {
            this.EditableName = EditableName;            
            this.JsonVarName = JsonVarName;
            this.sSlaveKey = sSlaveKey;
            this.MasterTable = new EditableTable(MasterTable,  MasterFields);
            this.SlaveTables = new EditableTable[] { new EditableTable(SlaveTable,  SlaveFileds) };
            this.Option = option;
            Sql = null;
            BuildSelectSql = null;
        }
        public EditableInfo(string EditableName, string JsonVarName, string sSlaveKey, string MasterTable, Field[] MasterFields
            , string SlaveTable, Field[] SlaveFileds)
        {
            this.EditableName = EditableName;
            this.JsonVarName = JsonVarName;
            this.sSlaveKey = sSlaveKey;
            this.MasterTable = new EditableTable(MasterTable,  MasterFields);
            this.SlaveTables = new EditableTable[] { new EditableTable(SlaveTable,  SlaveFileds) };
            this.Option = Option.None;
            Sql = null;
            BuildSelectSql = null;
        }
        public EditableInfo(string EditableName, string JsonVarName, string sSlaveKey, EditableTable MasterTable, EditableTable[] SlaveTables)
        {
            this.EditableName = EditableName;
            this.JsonVarName = JsonVarName;
            this.sSlaveKey = sSlaveKey;
            this.MasterTable = MasterTable;
            this.SlaveTables = SlaveTables;
            this.Option = Option.None;
            Sql = null;
            BuildSelectSql = null;
        }
        public EditableInfo(string EditableName, string JsonVarName, string sSlaveKey, Option option, EditableTable MasterTable, EditableTable[] SlaveTables)
        {
            this.EditableName = EditableName;
            this.JsonVarName = JsonVarName;
            this.sSlaveKey = sSlaveKey;
            this.MasterTable = MasterTable;
            this.SlaveTables = SlaveTables;
            this.Option = option;
            Sql = null;
            BuildSelectSql = null;
        }
        public EditableInfo(string EditableName, string JsonVarName, string sSlaveKey, Option option, EditableTable MasterTable, EditableTable SlaveTable)
        {
            this.EditableName = EditableName;
            this.JsonVarName = JsonVarName;
            this.sSlaveKey = sSlaveKey;
            this.MasterTable = MasterTable;
            this.SlaveTables =  new EditableTable[] {SlaveTable};
            this.Option = option;
            Sql = null;
            BuildSelectSql = null;
        }
        public EditableInfo(string EditableName, string JsonVarName, string sSlaveKey,  EditableTable MasterTable, EditableTable SlaveTable)
        {
            this.EditableName = EditableName;
            this.JsonVarName = JsonVarName;
            this.sSlaveKey = sSlaveKey;
            this.MasterTable = MasterTable;
            this.SlaveTables = new EditableTable[] { SlaveTable };
            this.Option = Option.None;
            Sql = null;
            BuildSelectSql = null;
        }
        public EditableInfo(string EditableName, string JsonVarName, string MasterTable,  Field[] MasterFields)
        {
            this.EditableName = EditableName;            
            this.JsonVarName = JsonVarName;
            this.MasterTable = new EditableTable(MasterTable,  MasterFields);
            this.Option = Option.None;
            Sql = null;
            BuildSelectSql = null;
        }
    }

    public abstract partial class DALBase
    {
        public abstract DataTable GetEditableTable(EditableInfo ei,bool bOnlyArray, string sNameFilter);
        public abstract void SubmitEditableChange(EmployeeInfo emp, Dictionary<string, object>[] Rows, EditableInfo ei);
        public abstract void SubmitEditableChange(EmployeeInfo emp,changeStatus nStatus, bool bCheckChanged, string sEditableName, Dictionary<string, object> row);
        public abstract void SubmitEditableChange(EmployeeInfo emp,changeStatus nStatus, bool bCheckChanged, EditableInfo ei, Dictionary<string, object> row);
    }
}
