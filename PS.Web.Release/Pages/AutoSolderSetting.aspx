<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AutoSolderSetting.aspx.cs" Inherits="Pages_AutoSolderSetting" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
     <meta http-equiv="Content-Language" content="zh-cn" />
     <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>AutoSolder NetServer Setting</title>

    
    <link href="js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
     <link href="js/slimbox/css/slimbox2.css" rel="stylesheet" type="text/css" />
    <script src="js/jquery-1.9.1.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" type="text/css"></script>
    <script src="js/ligerui/Source/lib/ligerUI/skins/ligerui-icons.css"  type="text/css"></script>
    <script src="js/ligerui/Source/lib/ligerUI/skins/Gray/css/all.css"  type="text/css"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerToolBar.js" type="text/javascript"></script>
    
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDialog.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerGrid.js" type="text/javascript"></script>
    <script src="js/slimbox/js/slimbox2.js" type="text/javascript"></script>
    <script src="js/Highcharts-5.0.5/code/highcharts.js" type="text/javascript"></script>

    <script type="text/javascript">

       //验证IP地址合法性
        var isIp = function () {
            var regexp = /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;

            return function (value) {
                var valid = regexp.test(value);

                if (!valid) {//首先必须是 xxx.xxx.xxx.xxx 类型的数字，如果不是，返回false
                    return false;
                }

                return value.split('.').every(function (num) {
                    //切割开来，每个都做对比，可以为0，可以小于等于255，但是不可以0开头的俩位数
                    //只要有一个不符合就返回false
                    if (num.length > 1 && num.charAt(0) === '0') {
                        //大于1位的，开头都不可以是‘0’
                        return false;
                    } else if (parseInt(num, 10) > 255) {  //10:保存的进制
                        //大于255的不能通过
                        return false;
                    }
                    return true;
                });
            }
        }();
        

        var DetailSetting = null;
        function f_DetailSetting()
        {
           
            DetailSetting = $.ligerDialog.open({
                title: "Detail Net Setting " ,
                //url: "NetSetting.aspx",
                modal: true,
                target: $("#showKey"),
                width: 500,
                height: 250,
                showMax: false,
                showToggle: false,
                showMin: false,
                isResize: false,
                slide: true,
                isHidden: true, //关闭的时候是隐藏还是销毁
                buttons: [{
                    text: '增加', onclick: function (item, dialog) {
                        //dialog.frame.f_ok();  
                        //alert(dialog.document.getElementById('Textline').value);
                        var linekey = $("#lineKey").val();
                        var ipkey = $("#ipKey").val();
                        var portkey = $("#portKey").val();

                        var pat = new RegExp("[^a-zA-Z0-9-\_\u4e00-\u9fa5]", "i");
                        if (pat.test(linekey) == true) {
                            alert("线别名称中含有非法字符");
                            return;
                        }

                        if (isIp(ipkey) == false) {
                            alert("ip地址不合法")
                            return;
                        }
                        if (linekey == "" || ipkey == "" || portkey == "") {
                            alert("输入不能为空");
                            return;
                        }
                        if (isNaN(portkey)) {
                            alert("端口号请输入数字");
                            return;
                        } else if (portkey < 0 || portkey > 65534) {
                            alert("端口号请输入0~65535以内的数字");
                            return;
                        }
                        
                        grdMain.addRow({
                            line: linekey,
                            ip: ipkey,
                            port: portkey,
                         });                      
                    }
                }
                    //,
                    //{
                    //    text: '关闭', onclick: function (item, dialog) {
                    //        //dialog.close();
                    //        //DetailSetting = null;
                            
                    //    }
                    //}
                ] ,   
                onClose: function () {
                   
                   
                   
                }
                
            });
        }
        function AddItemclick(item)
        {
            //var row = grdMain.getSelectedRow();
            f_DetailSetting();

           
        }
        function SaveItemclick(item)
        {
          
            var ndata = grdMain.getData();
            ndata = JSON.stringify(ndata);
            //alert(ndata);
            $.ajax({
                type: 'post',
                url: 'FetchData.ashx?fn=SaveNetSetting',
                data: { data: ndata},
                cache: false,
                dataType: 'json',
                success: function (data) {

                    if (data && data.sErrMsg) {
                       // errorLable.innerText = data.sErrMsg;
                        return;
                    }
                    alert(data);
                    
                }, error: function (json) {
                    alert(JSON.stringify(json));
                }
            });
        }
        function DeleteItemclick(item)
        {
            grdMain.deleteSelectedRow();
        }
        var grdMain = null;

        $(function ()
        {
            f_Query();
            window['g'] =
                grdMain = $("#maingrid").ligerGrid({
                    height: '100%', 
                columns: [
                   //
                    { display: 'ip', name: 'ip', minWidth: 140, editor: { type: 'text' } },//
                    { display: 'port', name: 'port', minWidth: 120, editor: { type: 'text' } },//
                    { display: 'line', name: 'line', align: 'left', width: 250, minWidth: 60, editor: { type: 'string' } }
                    ], pageSize: 30, rownumbers: true, enabledEdit: false, checkbox: true, 
                    //onSelectRow: function (rowdata, rowindex, rowobj) {
                    //    alert(rowdata.name);
                    //    var row = grdMain.getSelectedRow();
                    //    row.val(rowindex);
                    //},
                toolbar: { items: [
                { text: '增加', click: AddItemclick },
                { line: true },               
                { text: '删除', click: DeleteItemclick },
                { text: '保存', click: SaveItemclick },
                { line: true }
                ]}
                });
            $(document).bind("maingrid", function (event) {
                if (event.keyCode == 13) //enter,也可以改成9:tab
                {
                    grdMain.endEditToNext();
                }
            });
           
 
            $("#pageloading").hide();
        });
    
       

        function f_Query() {
            $.ajax({
                type: 'post',
                url: 'FetchData.ashx?fn=GetProductLineData',
                cache: false,
                dataType: 'json',
                success: function (data) {
                    

                    grdMain.loadData(data);
                    //if (data.Rows.length > 0)
                        //grdMain.select(0);
                }


            });
        }
    </script>
 

</head>
<body>
    <form id="form1" runat="server">
    <div class="l-loading" style="display:block" id="pageloading"></div>
 <a class="l-button" style="width:120px;float:left; margin-left:10px; display:none;" onclick="deleteRow()">删除选择的行</a>
 
  
 <div id="mydiv" class="l-clear"></div>
 
    <div id="maingrid"></div>

    <div id="showKey" style="display:none">
        <table style="width: 100%;">
            <tr>
                <td> <b>line:</b></td>
                <td><input type="text" id="lineKey"/></td>              
            </tr>
            <tr>
                <td><b>ip:</b></td>
                <td> <input type="text" id="ipKey"/></td>               
            </tr>
            <tr>
                <td><b>port:</b></td>
                <td> <input type="text" id="portKey"/></td>               
            </tr>
        </table>
    </div>
  <div style="display:none;">
   
</div>
    </form>
</body>
</html>
