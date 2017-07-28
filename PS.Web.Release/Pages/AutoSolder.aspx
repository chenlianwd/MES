<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AutoSolder.aspx.cs" Inherits="Pages_AutoSolder" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>AutoSolder</title>
    <link href="js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet"
        type="text/css" />
    <link href="css/LoginStyle.css" type="text/css" rel="stylesheet" />
    <style type="text/css">
        .FailText
        {
            color: #FF0000;
            text-align: left;
        }
         td
        {
            padding-left: 2px;
        }
         .deletedItem
        {
            text-decoration: line-through;
        }
    </style>

    <script src="js/jquery-1.7.1.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerGrid.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDrag.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDialog.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerResizable.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerToolBar.js" type="text/javascript"></script>

    <script src="js/settings.js" type="text/javascript"></script>

    <script type="text/javascript">
        String.prototype.bool = function () {
            return (/^true$/i).test(this) || (/^yes$/i).test(this) || (/^ok$/i).test(this);
        };
        var isIE = !!window.ActiveXObject;
        var Stations;
        var errorLable = null;
        
        $(function () {
            errorLable = document.getElementById("errorLable");          
            ShowAutoSolderValues();
            setInterval(" ShowAutoSolderValues()", 60000);
        });
        
        function ShowAutoSolderValues()
        {
            errorLable.innerText = "";
            $.ajax({
                type:'post',
                url: 'FetchData.ashx?fn=GetProductLineData',
                data: { Layout: "2F" },
                cache: false,
                dataType: 'json',
                success: function (data)
                {
                    if (data && data.sErrMsg) {
                        errorLable.innerText = data.sErrMsg;
                        return;
                    }
                    if (data.Rows)
                        data = data.Rows;
                    //遍历data 赋值给Stations
                    var Stations = new Array();
                    for (var i = 0; i < data.length; i++) {
                       
                        Stations[i] = { Name: data[i].line, Left: 100 + i % 7 * 200, Top: 250 + Math.floor(i / 7) * 200 };
                      
                       
                    }
                   

                    var LayoutDiagram = $("#LayoutDiagram");//获取id为LayoutDiagram的jquery对象
                    //var LayoutImg = LayoutDiagram.find("#LayoutImg");
                    

                    for (var i = 0; i < Stations.length; i++) {
                        var station = Stations[i];
                        var Location = null;
                        for (var j = 0; j < data.length; j++) {
                            if (station.Name.toLowerCase() == data[j].line.toLowerCase()) {
                                Location = data[j];

                                break;
                            }
                        }
                        
                        if (Location) {
                            var flag = true;
                            if (Location.timepoint == "" || Location.remain == "" || Location.used == "") {
                               // Location.timepoint = "未查询到数据";
                                Location.remain = "未查询到数据";
                                //Location.used = "以及重新建立连接";
                                flag = false;
                            }
                            var color = null;
                            if (Location.remain > 20) {
                                color = "Green";
                            } else if (Location.remain < 20 && Location.remain > 10) {
                                color = "Yellow";
                            } else {
                                color = "Red";
                            }

                            var stationDiv = LayoutDiagram.find("#" + Location.line);
                            if (stationDiv.length == 0) {
                                stationDiv = LayoutDiagram.append("<div class=\"PanelTH\" id=\"" + Location.line
                                   + "\" style=\"position:absolute;top:" + station.Top
                                    + "px;left:" + station.Left + "px\" />");
                                stationDiv = LayoutDiagram.find("#" + Location.line);
                                $('#' + Location.line).ligerDrag({
                                    //不使用代理
                                    //proxy: false 
                                    onStopDrag: function (current, e)
                                    {                                        
                                        var lastX = current.diffX + station.Left;
                                        var lastY = current.diffY + station.Top;
                                        //不必要保存控件历史位置
                                        
                                    }

                                });
                            }
                           
                            stationDiv.html("<span class=\"StationNameTH\" >" + station.Name + "</span><br>"
                                + "<div style=\"cursor:pointer;\"  onclick=\"f_AutoSolderDetailDlg_open(" + Location.remain + ",'" + Location.line + "','" + Location.starttime + "');\">"
                                //+ "<span class=\"ValueLable\">ip:</span><span class=\"OK\">" + Location.ip + "</span><br>"

                            //+ "<span class=\"ValueLable\">port:</span><span class=\"OK\">" + Location.port + "</span><br>"                         
                            //+ "<span class=\"ValueLable\">Start Time:</span><span class=\"OK\">" + Location.starttime + "</span><br>"
                            //+ "<span class=\"ValueLable\">End Time:</span><span class=\"OK\">" + Location.endtime + "</span><br>"
                                + "<span class=\"ValueLable\"><% =LangHelper.GetText("TimePoint") %>:</span><span class=\"OK\">" + Location.timepoint + "</span><br>"
                                + "<span class=\"ValueLable\"><% =LangHelper.GetText("Temperature") %>:</span><span class=\"OK\">" + Location.temperature + "</span><br>"
                                + "<span class=\"ValueLable\"><% =LangHelper.GetText("Humidity") %>:</span><span class=\"OK\">" + Location.humidity + "</span><br>"
                                + "<span class=\"ValueLable\"><% =LangHelper.GetText("Remain") %>:</span><span class=\"OK\">"  + "</span><br>"

                                + "<div style=\"background-color:" + color + ";width:150px;height: 75px; border: 1px solid #000; font-size:20px\">" + Location.remain + "%" + "</div>"

                                + "<span class=\"ValueLable\"><% =LangHelper.GetText("Used") %>:</span><span class=\"OK\">" + Location.used + "</span><br>"
                            //+ "<img src=\"getfile.ashx?tb=true&AutoSolder=" + Location.id + "\" />"
                            + "</div>");

                            stationDiv.css("background", flag ? "yellowgreen" : "Red");
                        }
                    }

                },
                error: function (XMLHttpRequest, textStatus) {
                    errorLable.innerText = (XMLHttpRequest.responseText.length > 0 ? XMLHttpRequest.responseText : textStatus);
                }
            });
        }

        var AutoSolderDetialDlg = null;
        function f_AutoSolderDetailDlg_open(remain, line, time)
        {
            if (AutoSolderDetialDlg != null) {
                return;
            }
            AutoSolderDetialDlg = $.ligerDialog.open({
                title: "Detail Data From AutoSolder " + line,
                url: "AutoSolderDetail.aspx?line=" + line,
                urlParms: { Remain: remain },
                width: 1300,
                height: 730,
                showMax: false,
                showToggle: false,
                showMin: false,
                isResize: false,
                slide: true,
                isHidden: false,
                onClose: function () {
                    AutoSolderDetialDlg = null;
                   
                }

            });
        }
        var settingDlg = null;
        function settingbtn_Click()
        {
            //alert("settingbtn_Click");
            if (settingDlg != null)
            {
                return;
            }
            settingDlg = $.ligerDialog.open({
                title: "setting",
                url: "AutoSolderSetting.aspx",
                width: 1000,
                height: 500,
                showMax: false,
                showMin: false,
                isResize: false,
                slide: true,
                isHidden: false,
                onClose: function () {
                    settingDlg = null;
                    location.reload(true);
                }
            });
        }

    </script>
</head>
<body style="margin-left: 0px; margin-top: 0px;">   
    <div style="position:absolute; width:100%; height:100%;background:url(images/bkg.png) repeat-y 0 0;">
         <div align="right">
             <input id="settingbtn" type="button" value="<% =LangHelper.GetText("AutosolderSetting") %>" onclick="settingbtn_Click()"/>           
        </div>
    <table align="center" style="text-align: center; height: 100%">
            <tr>
                <td class="FailText" id="errorLable">
                    &nbsp;
                </td>               
            </tr>
            <tr>
                <td align="center">
                    <div id="LayoutDiagram">
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <div style="display: none">
                    </div>
                </td>
            </tr>
        </table>
       
        
    </div>
    
</body>
</html>
