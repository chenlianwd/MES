 <%@ Page Language="C#" AutoEventWireup="true" CodeFile="DisplayBoard.aspx.cs" Inherits="Pages_DisplayBoard" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>Display Board</title>
    <link href="js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" type="text/css" href="js/easyui/themes/default/easyui.css" />
    <link rel="stylesheet" type="text/css" href="js/easyui/themes/icon.css" />

     <script src="js/jquery-1.9.1.js" type="text/javascript"></script>
    <script src="js/Highcharts-5.0.5/code/highcharts.js" type="text/javascript"></script>
    <script src="js/easyui/jquery.min.js" type="text/javascript"></script>
    <script src="js/easyui/jquery.easyui.min.js" type="text/javascript"></script>
    <script src="js/easyui/plugins/jquery.switchbutton.js" type="text/javascript"></script>
    <script src="js/easyui/plugins/jquery.datetimebox.js" type="text/javascript"></script>
  

    <script src="js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDialog.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerGrid.js" type="text/javascript"></script>
    <script src="js/slimbox/js/slimbox2.js" type="text/javascript"></script>
    
    <style type="text/css">
        /*.AllButton
        {
            padding: 0px 0px 0px 0px;
            margin: 0px 0px 0px 0px;
            height: 25px;
            border-spacing: 0px;
            border-collapse: collapse;
        }*/
        .PanelTH
        {
            background-color: black;
            border-color: blue;
            border-style: solid;
            border-width: 3px;
            color: white;
        }
        .StationNameTH
        {
            font-size: 18px;
            font-weight: bold;
            text-align: center;
            color: Black;
        }
        .ValueLable
        {
            font-size: 9px;
            text-align: left;
            color: black;
        }
         .OK
        {
            font-weight: bold;
            font-size: 14px;
            text-align: left;
            color: Black;
        }
         #divcss{margin:0 auto;border:1px solid #000;width:300px;height:100px} 
    </style>
      <script type="text/javascript">
          Date.prototype.Format = function (fmt) { //author: meizz 
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
          if (!String.prototype.trim) {
              String.prototype.trim = function () {
                  return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
              };
          }

          var errLabel = null;
          var switchbtn = null;
          $(function () {

              errLabel = document.getElementById("errorLabel");
              $("#edtStartTime").ligerDateEditor({ showTime: true, labelWidth: 100, labelAlign: 'left' });
              $("#edtEndTime").ligerDateEditor({ showTime: true, labelWidth: 100, labelAlign: 'left' });
              var combox = $("#combobox").combobox({
                  valueField: 'id',
                  textField: 'proline',
                  editable: true,
                  required: true,
                  mode: 'remote',
                  url: 'FetchData.ashx?fn=GetCommonProductLine'
                  ,
                  onLoadSuccess: function (data) {
                      if (data && data.sErrMsg) {
                          errLabel.innerText = data.sErrMsg;
                          return;
                      }
                      if (data) {
                          $('#combobox').combobox('setValue', data[0].id);                        
                      }
                  },
                  onSelect: function (newrecord) {
                      //alert("你选择了newrecord=" + newrecord.proline);
                      f_search(newrecord.proline);
                  },
                  onLoadError: function (err) {
                      errLabel.innerText = err;
                  }
              });
              //改为默认查询最近有数据的一天之类的数据
              switchbtn = $("#switchbutton").switchbutton({
                  checked: false,
                  onChange: function (checked) {
                      //alert(checked);
                      var line = $('#combobox').combobox('getText');                    
                          f_search(line);                 
                  }
              });

          });
          var pisChart = null;
          var autosolderChart = null;
          function f_showChart(sline) {
              errLabel.innerText = "";
              //var sStartDate = $("#edtStartTime").ligerGetDateEditorManager().getValue();
              //var sEndDate = $("#edtEndTime").ligerGetDateEditorManager().getValue();
            
              $.ajax({
                  type: 'post',
                  url: 'FetchData.ashx?fn=GetAllDeviceDataChart',
                  data: {
                      line: sline,
                      //StartTime: sStartDate.Format("yyyy-MM-dd HH:mm:ss"),
                      //EndTime: sEndDate.Format("yyyy-MM-dd HH:mm:ss")
                  },
                  cache: false,
                  dataType: 'json',
                  success: function (data) {
                      if (data && data.sErrMsg) {

                          errLabel.innerText = data.sErrMsg;
                          return;
                      }
                      //var PisDiagram = $("#PisDiagram");
                      //var productlinespan = $("#productlinespan");
                      if (data.pistable && data.pistable.length > 0) {
                          var pisdata = data.pistable;
                          pisChart = Highcharts.chart('PisDiagram', {
                              credits: {
                                  enabled: false
                              },
                              legend: {
                                  enabled: false
                              },
                              title: {
                                  text: 'pis chart'
                              },
                              xAxis: {
                                  type: 'datetime',
                                  title: { enabled: false }
                              },
                              yAxis: {
                                  lineWidth: 2
                                  , title: { enabled: true, text: '<b>CPK</b>' }
                                  , plotLines: [{ value: 1.33, color: 'red', dashStyle: 'ShortDot', width: 2, id: 'cpkLow', label: { x: 0, rotation: 0, text: '1.33', style: { color: 'red', fontWeight: 'bold' } } }]                                
                                  , softMin: 1.5
                                  , softMax: 1.5
                              },

                              series: [{
                                  name: 'CPK',
                                  cursor: 'pointer',                                
                                  tooltip: { pointFormat: 'CPK:<b>{point.y}</b>' },
                                  data: pisdata
                              }]
                          });
                      } else {
                          var PisDiagram = $("#PisDiagram");
                          PisDiagram.html("<span class=\"StationNameTH\" >" + "未查询到数据" + "</span><br>");
                      }

                      if (data.soldertable && data.soldertable.length > 0) {
                          var autosolderdata = data.soldertable;
                          autosolderChart = Highcharts.chart('AutosolderDiagram', {
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
                                  title: { enabled: false },
                                  labels: {
                                      enable: true,
                                      //rotation: 90,
                                      formatter: function () {
                                          return Highcharts.dateFormat('%H:%M', this.value);
                                      }
                                  }
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
                              legend: {
                                  layout: 'vertical',
                                  align: 'left',
                                  x: 120,
                                  verticalAlign: 'top',
                                  y: 100,
                                  floating: true,
                                  backgroundColor: (Highcharts.theme && Highcharts.theme.lengthBackgroundColor) || '#FFFFFF'
                              },

                              series: [{
                                  name: 'Temperature',
                                  type: 'spline',
                                  cursor: 'pointer',
                                  //data: autosolderdata,
                                  tooltip: {
                                      pointFormat: 'Temperature:<b>{point.y}</b>'
                                      //enabled: true,
                                      //formatter: function () {
                                      //    return '<b>' + this.series.name + '</b><br/>' + unix_to_datetime(this.x) + 'Temperature: ' + this.y + 'mm';
                                      //}
                                  }
                              }, {
                                  name: 'Humidity',
                                  type: 'spline',
                                  cursor: 'pointer',                                
                                  tooltip: {
                                      pointFormat: 'Humidity:<b>{point.y}</b>'
                                      //enabled: true,
                                      //formatter: function () {
                                      //    return '<b>' + this.series.name + '</b><br/>' + unix_to_datetime(this.x) + 'Humidity: ' + this.y + 'mm';
                                      //}
                                  }
                              }]

                          });
                          var dataArrX = new Array();
                          var dataTemperature = new Array();
                          var dataHumidity = new Array();
                          for (var i = 0; i < autosolderdata.length; i++) {
                              //var str = autosolderdata[i].x;                             
                              //var d = new Date(str);                              
                              //dataArrX[i] = d.Format("HH:mm");
                              dataArrX[i] = autosolderdata[i].x;
                              dataTemperature[i] = autosolderdata[i].y;
                              dataHumidity[i] =  autosolderdata[i].y2;
                          }
                          autosolderChart.xAxis[0].setCategories(dataArrX);
                          autosolderChart.series[0].setData(dataTemperature);
                          autosolderChart.series[1].setData(dataHumidity);

                      } else {
                          var AutosolderDiagram = $("#AutosolderDiagram");
                          AutosolderDiagram.html("<span class=\"StationNameTH\" id=\"productlinespan\">" + "未查询到数据" + "</span><br>");
                      }



                  },error: function (XMLHttpRequest, textStatus) {
                      errLabel.innerText = (XMLHttpRequest.responseText.length > 0 ? XMLHttpRequest.responseText : textStatus);
                  }
              });
          }
          function f_search(sline) {
              var status = $("#switchbutton").switchbutton("options").checked;
              if (status) {

                  f_showChart(sline);
                  return;
              }
              //var sline = $('#combobox').combobox('getText');
              //alert("search for " + sline);
              $.ajax({
                  type: 'post',
                  url: 'FetchData.ashx?fn=GetAllDeviceData',
                  data: {
                      line: sline
                  },
                  cache: false,
                  dataType: 'json',
                  success: function (data) {
                      if (data && data.sErrMsg) {
                        
                          errLabel.innerText = data.sErrMsg;
                          return;
                      }
                      var PisDiagram = $("#PisDiagram");
                      if (data.pistable && data.pistable.length > 0) {
                         
                          var pisdata = data.pistable[0];
                          PisDiagram.html("<span class=\"StationNameTH\" >" + pisdata.proline + "</span><br>"
                              + "<div style=\"cursor:pointer;\"  onclick=\"f_PisDetailDlg_open('" + pisdata.proline + "','" + pisdata.Name + "','" + pisdata.starttime + "');\">"
                              + "<span class=\"ValueLable\">Model:</span><span class=\"OK\">" + pisdata.model + "</span><br>"
                              + "<span class=\"ValueLable\">SN:</span><span class=\"OK\">" + pisdata.theSN + "</span><br>"
                              + "<span class=\"ValueLable\">CPK:</span><span id=\"cpkspan\" class=\"OK\">" + parseFloat(pisdata.cpk).toFixed(2) + "</span><br>"
                              + "<span class=\"ValueLable\">Start Time:</span><span class=\"OK\">" + pisdata.starttime + "</span><br>"
                              + "<span class=\"ValueLable\">End Time:</span><span class=\"OK\">" + pisdata.endtime + "</span><br>"
                              //数据库存放换成磁盘存放
                              // + "<img src=\"getfile.ashx?tb=true&pis=" + pis.id + "\" />"
                              + "<img src=\"getfile.ashx?tb=true&fn=" + pisdata.id + "\" />"
                              + "</div>");
                          var cpkspan = $("#cpkspan");
                          cpkspan.css("background", Location.result ? "yellowgreen" : "Red");
                      } else {
                          PisDiagram.html("<span class=\"StationNameTH\" >" + "未查询到数据" + "</span><br>");
                      }


                      var AutosolderDiagram = $("#AutosolderDiagram");
                      if (data.soldertable && data.soldertable.length > 0) {                        
                          var solderdata = data.soldertable[0];

                          var flag = true;
                          if (solderdata.TimePoint == null || solderdata.RemainSolderPercent == null || solderdata.UsedSolderNum == null) {
                              solderdata.RemainSolderPercent = "未查询到数据";
                              flag = false;
                          }
                          var color = null;
                          if (solderdata.RemainSolderPercent > 20) {
                              color = "Green";
                          } else if (solderdata.RemainSolderPercent < 20 && solderdata.RemainSolderPercent > 10) {
                              color = "Yellow";
                          } else {
                              color = "Red";
                          }

                          AutosolderDiagram.html("<span class=\"StationNameTH\" id=\"productlinespan\">" + solderdata.ProductLine + "</span><br>"
                              + "<div style=\"cursor:pointer;\"  onclick=\"f_AutoSolderDetailDlg_open(" + solderdata.RemainSolderPercent + ",'" + solderdata.ProductLine + "','" + solderdata.TimePoint + "');\">"
                              //+ "<span class=\"ValueLable\">ip:</span><span class=\"OK\">" + solderdata.ip + "</span><br>"

                              //+ "<span class=\"ValueLable\">port:</span><span class=\"OK\">" + solderdata.port + "</span><br>"
                              //+ "<span class=\"ValueLable\">Start Time:</span><span class=\"OK\">" + solderdata.starttime + "</span><br>"
                              //+ "<span class=\"ValueLable\">End Time:</span><span class=\"OK\">" + solderdata.endtime + "</span><br>"
                              + "<span class=\"ValueLable\">timepoint:</span><span class=\"OK\">" + solderdata.TimePoint + "</span><br>"
                              + "<span class=\"ValueLable\">temperature:</span><span class=\"OK\">" + solderdata.Temperature + "</span><br>"
                              + "<span class=\"ValueLable\">humidity:</span><span class=\"OK\">" + solderdata.Humidity + "</span><br>"
                              + "<span class=\"ValueLable\">remain:</span><span class=\"OK\">" + "</span><br>"
                              + "<div id=\"divcss\" style=\"background-color:" + color + ";width:150px;height: 75px; border: 1px solid #000; font-size:20px\">" + solderdata.RemainSolderPercent + "%" + "</div>"
                              + "<span class=\"ValueLable\">used:</span><span class=\"OK\">" + solderdata.UsedSolderNum + "</span><br>"               
                              + "</div>");
                          var productlinespan = $("#productlinespan");
                          productlinespan.css("background", flag ? "yellowgreen" : "Red");
                      } else {
                          AutosolderDiagram.html("<span class=\"StationNameTH\" id=\"productlinespan\">"+ "未查询到数据" +"</span><br>");
                      }


                  }, error: function (XMLHttpRequest, textStatus) {
                      errLabel.innerText = (XMLHttpRequest.responseText.length > 0 ? XMLHttpRequest.responseText : textStatus);
                  }
              });
          }
          var PisDetailDlg = null;
          function f_PisDetailDlg_open(nID, name, time) {
              if (PisDetailDlg != null)
                  return;
              PisDetailDlg = $.ligerDialog.open({
                  title: "Detail Data From PIS",
                  url: "PIS.aspx?StationID=" + nID + "&name=" + name + "&time=" + time,
                  width: 1300,
                  height: 730,
                  showMax: false,
                  showToggle: false,
                  showMin: false,
                  isResize: false,
                  slide: true,
                  isHidden: false,
                  onClose: function () {
                      PisDetailDlg = null;
                  }
              });
          }
          var AutoSolderDetialDlg = null;
          function f_AutoSolderDetailDlg_open(remain, line, time) {
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
     </script>
</head>

  
<body style="margin-left: 10px; margin-top: 10px;">
    <form id="from" runat="server">

     <div style="position: absolute; width: 100%; height: 100%; background: url(images/bkg.png) 0 0 no-repeat;">
   
      <table  style="margin:0px auto;" align="center">
        <tr>
            <td>
                <p>产线选择</p>
            </td>
            <td>              
                <input id="combobox" class="easyui-combobox" />
               
            </td>
            <td>
               <%--<a href="#" class="easyui-linkbutton" data-options="iconCls:'icon-search'" style="width:80px" onclick="f_search()">Search</a>--%>
            </td>
            <td>
                <input id="switchbutton"  class="easyui-switchbutton" data-options="onText:'chart',offText:'label'"/>
            </td>
        </tr>
        <tr id="datetimebox" style="display:none"> 
             <td>                 
                    <p>开始时间</p>                               
                    <p>结束时间</p>                            
            </td>
           <td>
               <div style="white-space:nowrap">
                  <asp:TextBox ID="edtStartTime" runat="server" ReadOnly="true" />          
               </div>
                <div style="white-space:nowrap">
                     <asp:TextBox ID="edtEndTime" runat="server" ReadOnly="true" />   
                </div>             
           </td>
            <td>               
            </td>
             <td>                              
            </td>
            
        </tr>
          <tr>
              <td>
                   
              </td>
              <td>
                  <asp:Panel ID="errorLabel"  ForeColor="Red" runat="server"></asp:Panel>
              </td>
          </tr>
          </table>
         
    
    <table style="width:100%;text-align: center;">
        <tr>
            <td width='50%'>
                <div id="PisDiagram"></div>
            </td>
            <td width='50%'>
                <div id="AutosolderDiagram"></div>
            </td>
           
        </tr>
        <tr>
             <td>
                <div id="ReflowTester"></div>
            </td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
    </table>
      </div>
    
   
    </form>
</body>
</html>
