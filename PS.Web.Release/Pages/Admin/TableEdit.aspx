<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TableEdit.aspx.cs" Inherits="TableEdit" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
     <meta http-equiv="X-UA-Compatible" content="IE=9; IE=8; IE=7; IE=EDGE" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <link href="../js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <link href="../css/TableEdit.css" rel="stylesheet" type="text/css" />
    
    <script src="../js/jquery-1.7.1.min.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerLayout.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerTab.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerResizable.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerCheckBox.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerTextBox.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerCheckBox.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerToolBar.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerGrid.js" type="text/javascript"></script>

    <script src="../js/settings.js" type="text/javascript"></script>
    <script src="../js/TabelEdit.js" type="text/javascript"></script>    

    <asp:PlaceHolder ID="ListHolder" runat="server" />
    <script type="text/javascript">

        var grdMain = null;
        var lblInfo = null;
        var gToolBar = {
                    items: [
                               { line: true },
                               { text: '<% =LangHelper.GetText("Add New") %>', click: f_AddNewRow },
                               { line: true },
                               { text: '<% =LangHelper.GetText("Submit Changes") %>', click: f_Submit }
                    ]
                };
                

        function f_initGrid()
        {
            errorLable = document.getElementById("errorLable");
            lblInfo = document.getElementById("lblInfo");

            grdMain = $("#grdMain").ligerGrid({
                columns: gColumns,
                url: gUrl,
                upUrl: gUpUrl,
                frozen: false,
                usePager: false,
                checkbox: false,
                MarkDivisor: 3,
                dataAction: 'local',
                heightDiff: -2,
                showTitle: false,
                rownumbers: true,
                enabledEdit: gEnabledEdit,
                enabledSort: gEnabledSort,
                toolbar: gEnabledEdit ? gToolBar : null,
                onBeforeEdit: f_onBeforeEdit,
                onAfterEdit: f_onAfterEdit,
                onError: f_OnError,
                onSuccess: f_onSuccess
            });
        }

        function f_onBeforeEdit(rowid)
        {
            if (gSelEI != '_Page' && rowid.record.Name == 'Default')
                return false;
        }

        $(function ()
        {
            f_initGrid();
        });

    </script>
   

    <style type="text/css">
        #lblInfo {
            text-align: left;
        }
    </style>
</head>
<body>
    <table align="center">
        <tr>
            <td>
                <div class="FailText" id="errorLable">
                </div>
            </td>
        </tr>
        <tr>
            <td>
                <div class="InfoText" id="lblInfo">
                </div>
            </td>
        </tr>
        <tr>
            <td>
                <div id="grdMain" style="margin: 0 auto; margin-top: 20px;">
                </div>
            </td>
        </tr>
    </table>
</body>
</html>
