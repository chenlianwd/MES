<%@ Page Language="C#" AutoEventWireup="true" CodeFile="pageMgr.aspx.cs" Inherits="pageMgr" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=9; IE=8; IE=7; IE=EDGE" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <link href="js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        body {
        }

        .l-button {
            padding: 5px;
        }

        .l-panel-topbar {
            background-color: #E0EDFF;
        }
    </style>
    <script src="js/jquery-1.7.1.min.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerLayout.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerTab.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerAccordion.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerGrid.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerToolBar.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerTextBox.js" type="text/javascript"></script>
    <script type="text/javascript">
        var grdPage = null;

        $(function ()
        {
            f_initPageGrid();

        });

        Date.prototype.Format = function (fmt)
        { //author: meizz
            var o = {
                "M+": this.getMonth() + 1, //月份
                "d+": this.getDate(), //日
                "H+": this.getHours(), //小时
                "m+": this.getMinutes(), //分
                "s+": this.getSeconds(), //秒
                "q+": Math.floor((this.getMonth() + 3) / 3), //季度
                "S": this.getMilliseconds() //毫秒
            };
            if (/(y+)/.test(fmt)) fmt = fmt.replace(RegExp.$1, (this.getFullYear() + "").substr(4 - RegExp.$1.length));
            for (var k in o)
                if (new RegExp("(" + k + ")").test(fmt)) fmt = fmt.replace(RegExp.$1, (RegExp.$1.length == 1) ? (o[k]) : (("00" + o[k]).substr(("" + o[k]).length)));
            return fmt;
        }

        function f_initPageGrid()
        {
            grdPage = $("#grdPage").ligerGrid({
                columns: [
                { display: 'Caption Of Page', name: 'sCaption', width: 230, editor: { type: 'text' } },
                { display: 'Create Time', name: 'dtCreate', width: 160 },
                { display: 'Creator', name: 'sCreator' },
                { display: 'Operate', isSort: false, width: 120, render: f_Operate }
                ],
                enabledEdit: true,
                clickToEdit: true,
                isScroll: false,
                width: 600,
                usePager: false,
                enabledSort: false,
                toolbar: {
                    items: [
                               { line: true },
                               { text: 'Add New', click: f_AddNewRow },
                               { line: true },
                    { text: 'Submit Change', click: f_Submit },
                    { line: true }
                    ]
                },
                onAfterEdit: f_onAfterEdit
            });
        }
        function f_onAfterEdit(rowdata)
        {
            rowdata.record.dtCreate = (new Date()).Format("yyyy-MM-dd HH:mm:ss");
            rowdata.record.sCreator = "me";
            return;
        }
        function f_Operate(rowdata, rowindex, value)
        {
            var h = "";
            if (rowdata._editing)
            {
                h += "<a href='javascript:f_EndEdit(" + rowindex + ")'>OK</a> ";
            }
            else
            {
                h += "<a href='javascript:f_up(" + rowindex + ")'>Up</a> ";
                h += "<a href='javascript:f_down(" + rowindex + ")'>Down</a> ";
                h += "<a href='javascript:f_DeleteRow(" + rowindex + ")'>Delete</a> ";
            }
            return h;
        }

        function f_up(rowid)
        {
            grdPage.up(rowid);
        }
        function f_down(rowid)
        {
            grdPage.down(rowid);
        }

        function f_BeginEdit(rowid)
        {
            grdPage.beginEdit(rowid);
        }
        function f_CancelEdit(rowid)
        {
            grdPage.cancelEdit(rowid);
        }
        function f_EndEdit(rowid)
        {
            grdPage.endEdit(rowid);
        }

        function f_DeleteRow(rowid)
        {
            if (confirm('确定删除?'))
            {
                grdPage.deleteRow(rowid);
            }
        }
        function f_AddNewRow()
        {
            grdPage.addEditRow();
        }
        function f_Submit()
        {

        }


    </script>
</head>
<body>
    <div style="text-align: center">
        <form id="form1" runat="server" style="text-align: center">
            <div id="grdPage" style="margin: 0 auto; margin-top: 20px;">
            </div>
        </form>
    </div>
</body>
</html>
