<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DisplayBoardGeneral.aspx.cs" Inherits="Pages_DisplayBoardGeneral" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>DisplayBoardGeneral</title>
    <link rel="stylesheet" type="text/css" href="css/bootstrap.css" />
    <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css" />
    <link href="js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" type="text/css" href="js/easyui/themes/default/easyui.css" />
    <link rel="stylesheet" type="text/css" href="js/easyui/themes/icon.css" />
    <script src="js/jquery-1.9.1.js" type="text/javascript"></script>
    <script src="js/easyui/jquery.min.js" type="text/javascript"></script>
    <script src="js/easyui/jquery.easyui.min.js" type="text/javascript"></script>
    <script src="js/easyui/plugins/jquery.switchbutton.js" type="text/javascript"></script>
    <script src="js/easyui/plugins/jquery.datetimebox.js" type="text/javascript"></script>
    <script src="js/easyui/plugins/jquery.combobox.js" type="text/javascript"></script>
    <script src="js/easyui/datagrid-filter.js" type="text/javascript"></script>
    <script src="js/bootstrap.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDialog.js" type="text/javascript"></script>
    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerGrid.js" type="text/javascript"></script>
    <script src="js/slimbox/js/slimbox2.js" type="text/javascript"></script>

     <script src="js/Highcharts-5.0.5/code/highcharts.js" type="text/javascript"></script>
     <style type="text/css">
        .StationNameTH
        {
            font-size: 18px;
            font-weight: bold;
            text-align: center;
            color: Black;
        }
         #divcss{margin:0 auto;border:1px solid #000;width:300px;height:100px} 
    </style>

    <script type="text/javascript">


        var errLabel = null;
        $(function () {


            
            $.ajax({
                type: 'post',
                url: 'FetchData.ashx?fn=GetDisPlayBoardGeneralData',
                cashe: false,
                dataType: 'json',
                success: function (data) {
                    if (data && data.sErrMsg) {
                        errLabel.innerText = data.sErrMsg;
                        return;
                    }
                    if (data.length > 0) {
                        for (var i = 0; i < data.length; i++) {
                            if (data[i]["pistable"] && data[i]["pistable"].length > 0){
                                var pisdata = data[i]["pistable"][0];
                                var cpkcolor = pisdata.result ? "yellowgreen" : "Red";
                                var pishtml = "<span class=\"StationNameTH\" >" + pisdata.proline + "</span><br>"
                                    + "<div style=\"cursor:pointer;\"  onclick=\"f_PisDetailDlg_open('" + pisdata.proline + "','" + pisdata.Name + "','" + pisdata.starttime + "');\">"
                                    + "<span class=\"ValueLable\">Model:</span><span class=\"OK\">" + pisdata.model + "</span><br>"
                                    + "<span class=\"ValueLable\">SN:</span><span class=\"OK\">" + pisdata.theSN + "</span><br>"
                                    + "<span class=\"ValueLable\">CPK:</span><span id=\"cpkspan\" class=\"OK\" style=\"background:"+ cpkcolor +"\">" + parseFloat(pisdata.cpk).toFixed(2) + "</span><br>"
                                    + "<span class=\"ValueLable\">Start Time:</span><span class=\"OK\">" + pisdata.starttime + "</span><br>"
                                    + "<span class=\"ValueLable\">End Time:</span><span class=\"OK\">" + pisdata.endtime + "</span><br>"
                                    + "<img src=\"getfile.ashx?tb=true&fn=" + pisdata.id + "\" />"
                                    + "</div>"
                                //var cpkspan = $("#cpkspan");
                                //cpkspan.css("background", pisdata.result ? "yellowgreen" : "Red");
                            } else {
                                var pishtml = "<span class=\"StationNameTH\" >" + "未查询到数据" + "</span><br>";
                            }


                            if (data[i]["soldertable"] && data[i]["soldertable"].length > 0) {
                                var solderdata = data[i]["soldertable"][0];
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
                                var solderhtml = "<span class=\"StationNameTH\" id=\"productlinespan\">" + solderdata.ProductLine + "</span><br>"
                                    + "<div style=\"cursor:pointer;\"  onclick=\"f_AutoSolderDetailDlg_open(" + solderdata.RemainSolderPercent + ",'" + solderdata.ProductLine + "','" + solderdata.TimePoint + "');\">"                                  
                                    + "<span class=\"ValueLable\">timepoint:</span><span class=\"OK\">" + solderdata.TimePoint + "</span><br>"
                                    + "<span class=\"ValueLable\">temperature:</span><span class=\"OK\">" + solderdata.Temperature + "</span><br>"
                                    + "<span class=\"ValueLable\">humidity:</span><span class=\"OK\">" + solderdata.Humidity + "</span><br>"
                                    + "<span class=\"ValueLable\">remain:</span><span class=\"OK\">" + "</span><br>"
                                    + "<div id=\"divcss\" style=\"background-color:" + color + ";width:150px;height: 75px; border: 1px solid #000; font-size:20px\">" + solderdata.RemainSolderPercent + "%" + "</div>"
                                    + "<span class=\"ValueLable\">used:</span><span class=\"OK\">" + solderdata.UsedSolderNum + "</span><br>"
                                    + "</div>";
                                var productlinespan = $("#productlinespan");
                                productlinespan.css("background", flag ? "yellowgreen" : "Red");
                            } else {
                                var solderhtml = "<span class=\"StationNameTH\" id=\"productlinespan\">" + "未查询到数据" + "</span><br>";
                            }



                            $('#dg').datagrid('appendRow', {
                                itemid: i + 1,
                                linename: pisdata.proline,
                                PIS: pishtml,
                                AutoSolder: solderhtml,
                                Status: '',
                                Detail: '<a href="DisplayBoard.aspx?line=' + pisdata.proline + '" class="easyui-linkbutton">open</a>',
                                Comments:''
                            });
                        }
                    } else {
                        errLabel.innerText = "未查询到任何线别信息";
                    }


                }, error: function (XMLHttpRequest, textStatus) {
                    errLabel.innerText = (XMLHttpRequest.responseText.length > 0 ? XMLHttpRequest.responseText : textStatus);
                }
            })
           
            //$('#dg').datagrid('enableFilter');
            //$('#dg').datagrid('enableFilter',
            //    [
            //        {
            //        field: 'linename',
            //        type: 'text',
            //        options: { precision: 1 },
            //        op: ['equal', 'notequal',  'contains']
            //        }
            //        ,
            //        {
            //            filed: 'ieamid',
            //        type: 'text',
            //        options: { precision: 1 },
            //        op: ['equal', 'notequal', 'less', 'greater']
            //        }
            //        ,
            //            {
            //         field: 'status',
            //         type: 'combobox',
            //         options: {
            //             panelHeight: 'auto',
            //             data: [{ value: '', text: 'All' }, { value: 'P', text: 'P' }, { value: 'N', text: 'N' }],
            //             onChange: function (value) {
            //                 if (value == '') {
            //                     dg.datagrid('removeFilterRule', 'Status');
            //                 } else {
            //                     dg.datagrid('addFilterRule', {
            //                         field: 'Status',
            //                         op: 'equal',
            //                         value: value
            //                     });
            //                 }
            //                 dg.datagrid('doFilter');
            //                }   
            //                }  
            //        }
            //    ]);
            $('#dg').datagrid('getPager').pagination({
                pageSize: 10,
                pageNumber: 1,
                pageList: [10, 20, 30, 40, 50],
                beforePageText: '第',//页数文本框前显示的汉字   
                afterPageText: '页    共 {pages} 页',
                displayMsg: '当前显示 {from} - {to} 条记录   共 {total} 条记录',
            });  
        });
        
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
<body>
   
	    
     <%-- <h2>Basic Layout</h2>
	 <p>The layout contains north,south,west,east and center regions.</p>
        <asp:Panel ID="errorLabel"  ForeColor="Red" runat="server"></asp:Panel>
	<div style="margin:20px 0;"></div>--%>
	<div class="easyui-layout" style="width:100%;height:100%;" fit="true"><%--fit=true 不加IE、FF可能出现宽高变成0px--%>
		<div data-options="region:'north'" style="height:50px">
		</div>
		<div data-options="region:'south',split:true" style="height:50px;"></div>
		<div data-options="region:'east',split:true" title="East" style="width:260px;">
            <embed type="application/x-shockwave-flash" src="http://cdn.abowman.com/widgets/hamster/hamster.swf" width="250" height="210" id="flashID" name="flashID" bgcolor="#FFFFFF" quality="high" flashvars="up_backgroundColor=FFFFFF" wmode="opaque" allowscriptaccess="always">
		</div>
		<div data-options="region:'west',split:true" title="West" style="width:160px;">
            <div height="120" width="150" align="center"><embed height="120" width="150" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" src="http://chabudai.sakura.ne.jp/blogparts/honehoneclock/honehone_clock_wh.swf" quality="high" autostart="1" wmode="transparent"></div>
		</div>
		<div data-options="region:'center',title:'Main Title',iconCls:'icon-ok'">
			<table class="easyui-datagrid" id="dg" data-options="border:false,singleSelect:true,fit:true,fitColumns:true,pagination: true,remoteSort:false,emptyMsg: '<span>无记录</span>',loadMsg: '正在加载中，请稍等... '">
				<thead>
					<tr>
                        <th data-options="field:'itemid',align:'center',sortable:'true'" width="60" >itemid</th>
						<th data-options="field:'linename',align:'center'" width="60">LineName</th>
						<th data-options="field:'PIS',align:'center'" width="100">PIS</th>
						<th data-options="field:'AutoSolder',align:'center'" width="100">AutoSolder</th>
						<th data-options="field:'Status',align:'center'" width="80">Status</th>
						<th data-options="field:'Detail',align:'center'" width="80">Detail</th>
						<th data-options="field:'Comments',align:'center'" width="100">Comments</th>
					</tr>
				</thead>
                <tbody>
               
                </tbody>
                <tfoot>
                
                </tfoot>
			</table>
            
		</div>
	</div>

</body>
</html>
