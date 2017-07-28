<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PIS.aspx.cs" Inherits="PisDetail" %>

<%--    ResponseEncoding="utf-8" --%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Language" content="zh-cn" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <%--  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    --%>
    <title>Temperature Humidity Detail Records</title>
    <link href="js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <link href="js/slimbox/css/slimbox2.css" rel="stylesheet" type="text/css" />

    <style type="text/css">
        .SelectedRow {
            font-weight: bold;
        }

        #pageloading {
            position: absolute;
            left: 0px;
            top: 0px;
            background: white url('js/ligerui/Source/lib/images/loading.gif') no-repeat center;
            width: 100%;
            height: 100%;
            z-index: 99999;
        }
    </style>

    <script src="js/jquery-1.9.1.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDialog.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerGrid.js" type="text/javascript"></script>
    <script src="js/slimbox/js/slimbox2.js" type="text/javascript"></script>
    <script src="js/Highcharts-5.0.5/code/highcharts.js" type="text/javascript"></script>

    <script type="text/javascript">
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
        if (!String.prototype.trim)
        {
            String.prototype.trim = function ()
            {
                return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
            };
        }

        var errorLable = null;
        var grdMain = null;

        $(function ()
        {
            errorLable = document.getElementById("errorLabel");

            $("#edtStartTime").ligerDateEditor({ showTime: true, labelWidth: 100, labelAlign: 'left' });
            $("#edtEndTime").ligerDateEditor({ showTime: true, labelWidth: 100, labelAlign: 'left' });
            $("#edtStation").ligerComboBox({
                isShowCheckBox: false, isMultiSelect: false, isTextBoxMode: true
                , url: 'FetchData.ashx?fn=GetPISData'
                , valueField: 'nStationID'
                , textField: 'Name'
                , valueFieldID: 'edtStationValue'
                , root: 'Rows'
                , onSuccess: f_Query
            });

            grdMain = $("#grdMain").ligerGrid({
                columns: [
                        { display: 'SN', name: 'theSN', align: 'right', width: 130, minWidth: 130 },
                        { display: 'Model', name: 'model', align: 'right', width: 130, minWidth: 130, align: 'right' },
                        { display: 'CPK', name: 'y', width: 50, minWidth: 50, align: 'right' },
                        { display: 'Result', name: 'result', width: 60, minWidth: 60, align: 'right', render: f_render },
                        { display: 'Start Time', name: 'starttime', width: 130, minWidth: 130, align: 'right' },
                        { display: 'End Time', name: 'endtime', align: 'right', Width: 130, minWidth: 130 },                        
                ],
                frozen: false,
                height: 400,
                width: 550,
                root: "Rows",
                record: "Total",
                usePager: false,
                checkbox: false,
                MarkDivisor: 3,
                dataAction: 'local',
                heightDiff: -2,
                showTitle: false,
                rownumbers: true,
                resizable: true,
                onSelectRow: f_onSelectRow
            });

            f_InitChart();
        });

        var objChart = null, grdMain = null;
        function f_Query()
        {
            errorLable.innerText = "";

            var sStation = document.getElementById("edtStationValue").value;;
            var sStartDate = $("#edtStartTime").ligerGetDateEditorManager().getValue();
            var sEndDate = $("#edtEndTime").ligerGetDateEditorManager().getValue();

            $.ajax({
                type: 'post',
                url: 'FetchData.ashx?fn=GetPISData',
                data: {
                    StationID: sStation
                    , StartTime: sStartDate.Format("yyyy-MM-dd HH:mm:ss")
                    , EndTime: sEndDate.Format("yyyy-MM-dd HH:mm:ss")
                },
                cache: false,
                dataType: 'json',
                success: function (data)
                {
                    if (data && data.sErrMsg)
                    {
                        errorLable.innerText = data.sErrMsg;
                        return;
                    }
                    objChart.series[0].setData(data.Rows);
                    grdMain.loadData(data);
                    if (data.Rows.length > 0)
                        grdMain.select(0);

                    $("#pageloading").hide();
                }
            });
        }


        function f_render(rowdata, rowindex, value, column)
        {
            var ss = rowdata[column.name];
            if (typeof (ss) == 'string')
                ss = ss.trim();
            return ((/^Pass$/i).test(ss) || (/^Close$/i).test(ss) || (/^OK$/i).test(ss) || ss == 1) ? "Pass" : "<span style='font-weight:bold;color:red'>Fail</span>";
        }


        function f_onSelectRow(rowdata, rowid, rowobj)
        {
            //grdFABDetail.options.url = "../FetchData.ashx?info=GetFABDetail";
            //grdFABDetail.loadServerData({ JobID: rowdata.JobID, isFAI: $("#isFAI").val() });
            //$("#ChartDetail").html("<img src='../getfile.ashx?pis=" + rowdata['id'] + "' height='400'>");

            //数据库读取
            //$("#ChartDetail").html("<a id='myLink' href='getfile.ashx?pis=" + rowdata['id'] + "&tm=true'><img src='getfile.ashx?pis=" + rowdata['id'] + "' height='400'></a>");
            //磁盘读取
            $("#ChartDetail").html("<a id='myLink' href='getfile.ashx?fn=" + rowdata['id'] + "&tm=true'><img src='getfile.ashx?fn=" + rowdata['id'] + "' height='400'></a>");

            $("#myLink").slimbox();

            var grd= $("#grdMain");
            var by =grd.find("div.l-grid-body2");            
            var offset = grd.find("div.l-grid-body-inner").height() * rowdata['__index'] / grdMain.rows.length;
            by.scrollTop(offset);
            return;
        }

        function f_chartClick(event)
        {
            var rowParam = null;
            for (i = 0; i < grdMain.rows.length; i++)
            {
                if (grdMain.rows[i]['id'] == event.point['id'])
                    rowParam = grdMain.rows[i];
            }

            grdMain.select(rowParam);
        }
        function f_InitChart()
        {
            objChart = Highcharts.chart('cpkTrend', {
                credits: {
                    enabled: false
                },
                legend: {
                    enabled: false
                },
                title: {
                    text: ''
                },
                xAxis: {
                    type: 'datetime',
                    title: { enabled: false }
                },
                yAxis: {
                    lineWidth: 2
                    , title: { enabled: true, text: '<b>CPK</b>' }
                    , plotLines: [{ value: 1.33, color: 'red', dashStyle: 'ShortDot', width: 2, id: 'cpkLow', label: { x: 0,rotation:0, text: '1.33', style: { color: 'red', fontWeight: 'bold'}}}]
                    //,events: { afterSetExtremes: f_setExtremes }
                    , softMin: 1.5
                    , softMax: 1.5
                },

                series: [{
                    name: 'CPK',
                    cursor: 'pointer',
                    events: { click: f_chartClick },
                    tooltip: { pointFormat: 'SN:<b>{point.theSN}<b><br>CPK:<b>{point.y}</b>' }
                }]
                });
        }

        function f_setExtremes(e)
        {
            if (e.min < 1.2)
                this.setExtremes(1.2, e.max);
            
            if (e.max < 1.2 )
                this.setExtremes(e.min, 1.2);
                
            //            var extremes = objChart.yAxis[0].getExtremes();
            //            if (extremes.dataMin != null && extremes.dataMin < 1.2)
            //                objChart.yAxis[0].setExtremes(1.2, extremes.dataMax);
            //            
            //            if (extremes.dataMax < 1.2)
            //                objChart.yAxis[0].setExtremes(extremes.dataMin, 1.2);

            return;
        }

    </script>

</head>
<body style="margin-left: 10px; margin-top: 10px;">
<%--    <div id="pageloading">
    </div>--%>

    <form id="Form1" runat="server">
        <table align="center" style="text-align: center;">
            <tr>
                <td>
                    <table align="center">
                        <tr>
                            <td>
                                <label for="cbStation">
                                    Station:</label>
                            </td>
                            <td>
                                <label for="edtStartTime">
                                    Start Time:</label>
                            </td>
                            <td>
                                <label for="edtEndTime">
                                    End Time:</label>
                            </td>
                            <td></td>
                        </tr>
                        <tr>
                            <td>
                                <asp:TextBox ID="edtStation" runat="server" Width="100px" />
                            </td>
                            <td>
                                <asp:TextBox ID="edtStartTime" runat="server" ReadOnly="true" />
                            </td>
                            <td>
                                <asp:TextBox ID="edtEndTime" runat="server" ReadOnly="true" />
                            </td>
                            <td>
                                <input type="button" class="l-button btn" value="Inquiry" onclick="f_Query();" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Panel ID="errorLabel" ForeColor="Red" runat="server">
                    </asp:Panel>
                </td>
            </tr>
            <tr>
                <td>
                    <div id="cpkTrend" style="height: 200px; width: 1050px"></div>
                </td>
            </tr>
            <tr>
                <td>
                    <table>
                        <tr>
                            <td>
                                <div id="grdMain"></div>
                            </td>
                            <td>
                                <div id="ChartDetail"></div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
