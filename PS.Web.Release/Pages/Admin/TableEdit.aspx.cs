using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

using PS;

public partial class TableEdit : AdminBasePage
{
    protected LanguageHelper LangHelper = null;

    private List<string> FilledFieldList = null, JsonList = null;
    private string sEditableInfo = null;
    protected void Page_Load(object sender, EventArgs e)
    {
        //查看是否有用户级语言辅助器，没有则用公共的
        LangHelper = FetchData.GetLanguageHelper(Session);
        

        sEditableInfo = Request["ei"];
        if (sEditableInfo == null)
            sEditableInfo = "_Employee";

        if (sEditableInfo != null)
        {
            EditableInfo selEI = Common.SelectEditableInfo(sEditableInfo);
            if (selEI != null)
            {  
                //先为选择编辑字段创建初始的Json列表
                string sJosn = "";
                JsonList = new List<string>();

                //再生成网格上的字段列表
                bool bReadOnlyTable=((selEI.Option & Option.ReadOnly) != Option.None);

                string sHtml="";
                FilledFieldList = new List<string>();
                foreach (Field fld in selEI.MasterTable.Fields)
                {
                    CreateJSForColumn(fld, bReadOnlyTable, ref sHtml);
                    GetJson(fld, ref sJosn);
                }

                foreach(EditableTable tbl in selEI.SlaveTables)
                {
                    foreach (Field fld in tbl.Fields)
                    {
                        CreateJSForColumn(fld, bReadOnlyTable, ref sHtml);
                        GetJson(fld, ref sJosn);
                    }
                }
                if ((selEI.Option & Option.ReadOnly) == Option.None)
                    sHtml += "\n,  { display: '" + LangHelper.GetText("Operate") + "', isSort: false, width: 120, render: " + ((selEI.Option & Option.ManualSort) != Option.None ? "f_OperateUpDown" : "f_Operate") + " }";

                ListHolder.Controls.Add(new LiteralControl("<script type=\"text/javascript\">\n var gColumns=[" + sHtml + "];\n"
                    + "var gList = {};\n"
                    + sJosn
                    + "var gUrl= '../FetchData.ashx?fn=TableEdit&rp=get&ei=" + sEditableInfo + "'; \n"
                    + "var gUpUrl='../FetchData.ashx?fn=TableEdit&rp=update&ei=" + sEditableInfo + "'; \n"
                    + "var gEnabledSort=" + ((selEI.Option & Option.ManualSort) != Option.None ? "false" : "true") + "; \n"
                    + "var gEnabledEdit=" + (bReadOnlyTable ? "false" : "true") + "; \n"
                    + "var gSelEI= '" + sEditableInfo + "'; \n"
                    + "</script>"));
            }
        }
    }


    private void GetJson(Field fld, ref string sJosn)
    {
        string sName = Field.AdjustName(fld);
        Editor editor = fld.editor;
        editor &= Editor.MaskNA;//屏蔽表示是否有<N/A>选项的高位
        editor &= Editor.MaskReadOnly;//屏蔽表示是否只读readOnly选项的高位

        if (editor == Editor.select && (!JsonList.Contains(sName, StringComparer.OrdinalIgnoreCase)))
        {
            JsonList.Add(sName);
            EditableInfo ei = Common.SelectEditableInfo(sName);
            if (ei != null)
            {
                bool bOnlyArray = true;

                DataTable tbl = Common.DAL.GetEditableTable(ei, bOnlyArray, "");

                sName = Field.AdjustName(fld);

                sJosn += "gList['" + sName + "']=" + (new LigerGridRows(tbl, "yyyy-MM-dd HH:mm:ss")).ToJson((fld.editor & Editor.HasNA) != Editor.none, bOnlyArray) + ";\n";
            }
        }
    }

    private void CreateJSForColumn(Field fld,bool bReadOnlyTable, ref string sHtml)
    {
        if (!FilledFieldList.Contains(fld.name, StringComparer.OrdinalIgnoreCase))
        {
            Editor editor = fld.editor;
            editor &= Editor.MaskNA;//屏蔽表示是否有<N/A>选项的高位
            editor &= Editor.MaskReadOnly;//屏蔽表示是否只读readOnly选项的高位

            if (editor != Editor.none)
            {
                FilledFieldList.Add(fld.name);

                if (sHtml != "")
                    sHtml += "\n, ";
                string sRender = "", sEditor = "",sListName="";

                if (editor == Editor.chk )
                    sRender = ", render: f_renderUsed";
                else if (editor == Editor.select)
                {
                    sRender = ", render: f_renderSelect";
                    sListName = "listName: '" + Field.AdjustName(fld) + "',";
                }

                if (bReadOnlyTable == false && (fld.editor & Editor.readOnly) == Editor.none)//只读的不需要editor
                {
                    if (editor == Editor.select)
                    {
                        sEditor = string.Format(", editor: {{ type: 'select' , valueField: '_ID', textField: 'Name', selectBoxWidth: 260, selectBoxHeight: 560, triggerToLoad: true,"
                            + " url: '../FetchData.ashx?fn=TableEdit&rp=get&ei={0}&oa=1&na={1}', HoldFld: '{0}', onBeforeSetData: f_onBeforeSetData }}"
                            ,Field.AdjustName(fld),((fld.editor & Editor.HasNA) != Editor.none ? "1" : "0") );
                    }
                    else if (editor != Editor.none)
                        sEditor = string.Format(", editor: {{ type: '{0}' }}", editor.ToString());
                }

                sHtml += string.Format(" {{ display: '{0}', name: '{1}', width: {2}, align: '{3}',{4} type: '{5}' {6} {7} }}", LangHelper.GetText(fld.display), fld.name, fld.width, fld.align.ToString()
                    , sListName, Field.FieldTypeName[(int)fld.type], sRender, sEditor);
            }
        }
    }
}