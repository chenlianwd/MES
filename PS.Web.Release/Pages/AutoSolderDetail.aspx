<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AutoSolderDetail.aspx.cs" Inherits="Pages_AutoSolderDetail" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
     <meta http-equiv="Content-Language" content="zh-cn" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Temperature Humidity Detail Records</title>

    <link href="js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <link href="js/slimbox/css/slimbox2.css" rel="stylesheet" type="text/css" />


    <script src="js/jquery-1.9.1.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDialog.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerGrid.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerMenuBar.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerMenu.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerToolBar.js" type="text/javascript"></script>
   
    <script src="js/slimbox/js/slimbox2.js" type="text/javascript"></script>
    <script src="js/Highcharts-5.0.5/code/highcharts.js" type="text/javascript"></script>

    <style type="text/css">

        #Solder {
	
    left:50px;
	width: 200px;

	height: 200px;

	background-color:aqua;
   

}

   
    </style>

    <script type="text/javascript">
        Date.prototype.Format = function (fmt) { //js日期格式化
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
        //sting原型添加trim()方法
        if (!String.prototype.trim) {
            String.prototype.trim = function () {
                return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
            };
        }
        var errorLable = null;
        var grdMain = null;
        var used = null;
        var solder = null;
       
       

        $(function () {

            
            //document.getElementById("used").style.height = SolderH;
            used = document.createElement("div");
            //if存在删除该div
            solder = document.getElementById("Solder");
            //if (document.getElementById("used") != null) {
            //    solder.remove(used);
            //}

            used.id = "used";
           
            //used.style.height = SolderH;
            solder.appendChild(used);

            errorLable = document.getElementById("errorLabel");
            $("#edtStartTime").ligerDateEditor({ showTime: true, labelWidth: 100, labelAlign: 'left' });
            $("#edtEndTime").ligerDateEditor({ showTime: true, labelWidth: 100, labelAlign: 'left' });
            $("#edtStation").ligerComboBox({
                isShowCheckBox: false, isMultiSelect: false, isTextBoxMode: true
                , url: 'FetchData.ashx?fn=GetProductLineData'
                , valueField: 'line'
                , textField: 'line'
                , valueFieldID: 'line'
                , root: 'Rows'
                , onSuccess: f_Query
            });

            var sStation1 = document.getElementById("edtStation").value;
                //document.getElementById("line").value;
            var sStartDate1 = $("#edtStartTime").ligerGetDateEditorManager().getValue();
            var sEndDate1 = $("#edtEndTime").ligerGetDateEditorManager().getValue();
            grdMain = $("#grdMain").ligerGrid({
                columns: [
                    //{ display: 'id', name: 'id', align: 'right', width: 20, minWidth: 20, align: 'right'},
                        { display: 'Temperature', name: 'Temperature', align: 'right', width: 80, minWidth: 80, align: 'right' },
                        { display: 'Humidity', name: 'Humidity', width: 60, minWidth: 60, align: 'right' },
                        { display: 'Product Line', name: 'ProductLine', width: 110, minWidth: 110, align: 'right' },
                        { display: 'Remain(%)', name: 'RemainSolderPercent', width: 70, minWidth:70, align: 'right'},
                        { display: 'Used', name: 'UsedSolderNum', width: 60, minWidth: 60, align: 'right' },
                        { display: 'Add Times', name: 'AddTimes', align: 'right', Width: 50, minWidth: 50, align: 'right'},
                        { display: 'Time Point', name: 'TimePoint', align: 'right', Width: 200, minWidth: 200, align: 'right' }
                ],
                //分页
                dataAction: "server",
                dataType: "server",
                page: "1",
                pageSize: "500",
                pageSizeOptions: [200, 500, 1000],
                method: 'post',               
                url: 'FetchData.ashx?fn=GetAutoSolderData_Grid',
                parms: { line: sStation1, StartTime: sStartDate1.Format("yyyy-MM-dd HH:mm:ss"), EndTime: sEndDate1.Format("yyyy-MM-dd HH:mm:ss"), temp: false },             
                isScroll: true,
                frozen: false,
                height: '100%',
                width: '100%',
                root: "Rows",
                record: "Total",
                usePager: true,
                checkbox: false,
                MarkDivisor: 3,
                //dataAction: 'local',
                heightDiff: -2,
                showTitle: false,
                rownumbers: true,
                resizable: true,
                onSelectRow: f_onSelectRow,               
                pageParmName: 'page',
                pagesizeParmName: 'pagesize',
                onToNext: f_ToNext,
                onToPrev: f_ToPre,
                onToFirst: f_ToFirst,
                onToLast: f_ToLast
                
               
            });
            //grdMain.set('dataAction', 'server');
            f_InitChart();
            
        });
        var ratio = 0;
        function f_ToNext() {
            ratio = 1;
            f_Query();
        }
        function f_ToPre() {
            ratio = -1;
            f_Query();
        }
        function f_ToFirst() {
            ratio = 2;
           f_Query();
        } 
        function f_ToLast() {
            ratio = -2;
           f_Query();
        }
        
       
        //
        var objChart = null, grdMain = null;
        var page = 1, pagesize = 200;
        //因为grdMain.options.page获取到的是当前页面值，因此用参数来适应
        function f_Query() {
            errorLable.innerText = "";

            var sStation = document.getElementById("edtStation").value;
            
            var sStartDate = $("#edtStartTime").ligerGetDateEditorManager().getValue();
            var sEndDate = $("#edtEndTime").ligerGetDateEditorManager().getValue();
            var  total = grdMain.options.total;
            page = grdMain.options.page;
            pagesize = grdMain.options.pageSize;
            if (ratio == 1) {
                page += 1;
                if (page == Math.ceil(total / pagesize) + 1) page = Math.ceil(total / pagesize);
            } else if (ratio == -1) {
                page -= 1;
                if (page == 0) page = 1;
            } else if (ratio == 2) {
                page = 1;
            } else if (ratio == -2) {
                page = total / pagesize;
                //向上取整
                page =  Math.ceil(page);
            }

            grdMain.set('parms', { line: sStation, StartTime: sStartDate.Format("yyyy-MM-dd HH:mm:ss"), EndTime: sEndDate.Format("yyyy-MM-dd HH:mm:ss"), temp: false });
            grdMain.loadData();

            $.ajax({
                type: 'post',
                url: 'FetchData.ashx?fn=GetAutoSolderData',
                data: {
                    line: sStation
                    , StartTime: sStartDate.Format("yyyy-MM-dd HH:mm:ss")
                    , EndTime: sEndDate.Format("yyyy-MM-dd HH:mm:ss")
                    , Page: page
                    , PageSize: pagesize
                },
                cache: false,
                dataType: 'json',
                success: function (data) {
                    if (data && data.sErrMsg) {
                        errorLable.innerText = data.sErrMsg;
                        return;
                    }
                    
                    var dateArrX = new Array();                                 
                    var dataAll1 = new Array();
                    var dataAll2 = new Array();
                    for (var i = 0; i < data.Rows.length; i++) {
                        var str = data.Rows[i].TimePoint.replace(/-/g, "/");
                        // var d = new Date(data.Rows[i].TimePoint);
                        var d = new Date(str);
                        //dateArrX[i] = new Date("2016/07/01 08:00:00"); //d.Format("HH:mm");    
                        dateArrX[i] = d.Format("HH:mm");
                        dataAll1[i] = { y: parseFloat(data.Rows[i].Temperature), id: parseInt(data.Rows[i].id) };
                        dataAll2[i] = { y: parseFloat(data.Rows[i].Humidity), id: parseInt(data.Rows[i].id) };
                    }
                    
                    objChart.xAxis[0].setCategories(dateArrX);                 
                    objChart.series[0].setData(eval(dataAll1));
                    objChart.series[1].setData(dataAll2);
                    //grdMain.loadData(data);
                    if (data.Rows.length > 0) {
                        //grdMain.select(0);

                        //设置剩余量
                        //var SolderP = data.Rows[data.Rows.length - 1].RemainSolderPercent;
                        //var SolderH = (100 - parseFloat(SolderP)) * 2;
                        //used.innerText = SolderP + "%";
                        //used.style.cssText = "font-size:20px;width:200px;height:" + SolderH + "px;background:antiquewhite";
                        f_refreshSolderRemain(data.Rows[data.Rows.length - 1]);
                    }
                       

                    $("#pageloading").hide();
                },
                error: function (XMLHttpRequest, textStatus) {
                    errorLable.innerText = (XMLHttpRequest.responseText.length > 0 ? XMLHttpRequest.responseText : textStatus);
                }
            });
        }
        
        function f_Export() {
            //errorLable.innerText = "";

            var sStation = document.getElementById("line").value;

            var sStartDate = $("#edtStartTime").ligerGetDateEditorManager().getValue();
            var sEndDate = $("#edtEndTime").ligerGetDateEditorManager().getValue();
           
            //var form = $("<form>");
            //form.attr("style", "display:none");
            //form.attr("method", "post")
            //form.attr("action", "FetchData.ashx?fn=ExportExcel");
            //$("body").append(form);
            //var input1 = $("<input>");
            //input1.attr("type", "hidden");
            //input1.attr("line", sStation);
            //input1.attr("StartTime", sStartDate);
            //input1.attr("EndTime", sEndDate);
            //form.append(input1);
            //form.submit();
            window.location.href = "FetchData.ashx?fn=ExportExcel&line=" + sStation + "&StartTime=" + sStartDate.Format("yyyy-MM-dd HH:mm:ss") + "&EndTime=" + sEndDate.Format("yyyy-MM-dd HH:mm:ss");

            //alert("test something");
        }
         //刷新锡膏剩余量
        function f_refreshSolderRemain(solderData) {
            var SolderP = solderData.RemainSolderPercent;
            var SolderH = (100 - parseFloat(SolderP)) * 2;

            used.innerText = SolderP + "%";

            used.style.cssText = "font-size:20px;width:200px;height:" + SolderH + "px;background:antiquewhite";
        }
        //单击回滚到当前行
        function f_onSelectRow(rowdata, rowid, rowobj) {
            //grdFABDetail.options.url = "../FetchData.ashx?info=GetFABDetail";
            //grdFABDetail.loadServerData({ JobID: rowdata.JobID, isFAI: $("#isFAI").val() });
            //$("#ChartDetail").html("<img src='../getfile.ashx?pis=" + rowdata['id'] + "' height='400'>");
            //$("#ChartDetail").html("<a id='myLink' href='getfile.ashx?autosolder=" + rowdata['id'] + "&tm=true'><img src='getfile.ashx?autosolder=" + rowdata['id'] + "' height='400'></a>");
            //$("#myLink").slimbox();

            var grd = $("#grdMain");
            var by = grd.find("div.l-grid-body2");
            var offset = grd.find("div.l-grid-body-inner").height() * rowdata['__index'] / grdMain.rows.length;
            by.scrollTop(offset);
           
            
            f_refreshSolderRemain(rowdata);

            return;
        }
        function f_chartClick(event) {
            var rowParam = null;
            for (i = 0; i < grdMain.rows.length; i++) {
                if (grdMain.rows[i]['id'] == event.point['id'])
                    rowParam = grdMain.rows[i];
            }

            grdMain.select(rowParam);
        }
        function f_InitChart() {
            objChart = Highcharts.chart('TempHumdCurve', {
                credits: {
                    enabled: false
                },
                legend: {
                    enabled: false
                },
                title: {
                    text: 'AutoSolder Temperature And Humidity'
                },
                xAxis: {
                    type: 'datetime',
                    title: { enabled: false }
                },
                yAxis:
                    [{//Primary yAxis
                       lineWidth: 2
                       , title: { enabled: true, text: '<b>Temperature</b>' }
                        //, plotLines: [{ value: 1.33, color: 'red', dashStyle: 'ShortDot', width: 2, id: 'cpkLow', label: { x: 0, rotation: 0, text: '1.33', style: { color: 'red', fontWeight: 'bold' } } }]
                        //,events: { afterSetExtremes: f_setExtremes }
                       , softMin: 1.5
                       , softMax: 1.5
                    }, {//Secondary yAxis
                        lineWidh: 2
                        , title: { enabled: true, text: '<b>Humidity</b>' }
                        , softMin: 1.5
                        , softMax: 1.5
                        , opposite: true
                    }],
                legend:{
                    layout: 'vertical',
                    align:'left',
                    x:120,
                    verticalAlign:'top',
                    y:100,
                    floating: true,
                    backgroundColor:(Highcharts.theme && Highcharts.theme.lengthBackgroundColor) || '#FFFFFF'
                },   
                
                series: [{
                    name: 'Temperature',
                    type :'spline',
                    cursor: 'pointer',
                    events: { click: f_chartClick },
                    tooltip: { pointFormat: 'Temperature:<b>{point.y}</b>' }//SN:<b>{point.theSN}<b><br>
                }, {
                    name: 'Humidity',
                    type :'spline',
                    cursor: 'pointer',
                    events: { click: f_chartClick },
                    tooltip: { pointFormat: 'Humidity:<b>{point.y}</b>' }//SN:<b>{point.theSN}<b><br>
                }]
            });
        }
        function f_setExtremes(e) {
            if (e.min < 1.2)
                this.setExtremes(1.2, e.max);

            if (e.max < 1.2)
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
    <form id="Form1" runat="server">
        <table align="center" style="text-align: center;">
            <tr>
                <td>
                    <table align="center">
                        <tr>
                            <td>
                                <label for="line">
                                    line:</label>
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
                                <input type="button" class="l-button btn" value="<% =LangHelper.GetText("Autosolder_query") %>" onclick="f_Query();" />
                            </td>
                            <td>
                                 <input type="button" id="Export" class="l-button btn" value="<% =LangHelper.GetText("Autosolder_export") %>" onclick="f_Export();"/>
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
                    <div id="TempHumdCurve" style="height: 200px; width: 1050px"></div>
                </td>
            </tr>
            <tr>
                <td>
                    <table>
                        <tr>
                            <td>                               
                                <div id="grdMain"></div>
                            </td>
                            <td style="width:100px">     </td>
                            <td >
                                
                                <div style="height:50px"></div>
                                <div id="Solder" >
                                    
                                        
                                </div>
                               
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
