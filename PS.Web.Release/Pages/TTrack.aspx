<%@ Page Language="C#" AutoEventWireup="true" CodeFile="TTrack.aspx.cs" Inherits="Pages_TTrack" %>

<%--<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">--%>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">


<head>
    <meta http-equiv="Content-Language" content="zh-cn" />
     <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>TTrack-Reflower Tester</title>

     <link href="js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <link href="js/slimbox/css/slimbox2.css" rel="stylesheet" type="text/css" />
     <link href="style/bootstrap.css" rel="stylesheet" />
    <link href="style/fileinput.css" rel="stylesheet" />
    <link href="style/custom/fileupload.css" rel="stylesheet" />

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

     <%--<script src="js/jquery-1.10.2.js" type="text/javascript"></script>--%>
     <script src="js/bootstrap.js" type="text/javascript"></script>
     <script src="js/respond.js" type="text/javascript"></script>
     <script src="js/fileinput.js" type="text/javascript"></script>
     <script src="js/fileinput_locale_zh.js" type="text/javascript"></script>
    <style type="text/css">
        .FailText
        {
            color: #FF0000;
            text-align: center;
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
         var errorLabel = null;
         var grdMain = null;
         $(function () {
             $('#fileInput').fileinput({
                 language: 'zh', //设置语言
                 //uploadUrl: "/FileUpload/File", 

                 // maxFileCount: 100,
                 enctype: 'multipart/form-data',
                 showUpload: true, //是否显示上传按钮
                 showCaption: false,//是否显示标题
                 browseClass: "btn btn-primary", //按钮样式             
                 previewFileIcon: "<i class='glyphicon glyphicon-king'></i>",
                 msgFilesTooMany: "选择上传的文件数量({n}) 超过允许的最大数值{m}！",
             });
             errorLable = document.getElementById("errorLabel");
             $("#edtStartTime").ligerDateEditor({ showTime: true, labelWidth: 100, labelAlign: 'left' });
             $("#edtEndTime").ligerDateEditor({ showTime: true, labelWidth: 100, labelAlign: 'left' });
            
            
           
             var sStartDate1 = $("#edtStartTime").ligerGetDateEditorManager().getValue();
             var sEndDate1 = $("#edtEndTime").ligerGetDateEditorManager().getValue();
            
                


            
         });
         function f_Query() {
             $.ajax({
                 type: 'post',
                 url: 'ClientUpload.ashx?fn=test',
                 data: {

                 },
                 cache: false,
                 dataType: 'json',
                 success: function (data) {
                     if (data && data.sErrMsg) {
                         errorLable.innerText = data.sErrMsg;
                         return;
                     }



                 }, error: function (XMLHttpRequest, textStatus) {
                     errorLable.innerText = (XMLHttpRequest.responseText.length > 0 ? XMLHttpRequest.responseText : textStatus);
                 }

             });
         }    

          
         function f_onSelectRow(rowdata, rowid, rowobj) {
             var grd = $("#grdMain");
             var by = grd.find("div.l-grid-body2");
             var offset = grd.find("div.l-grid-body-inner").height() * rowdata['__index'] / grdMain.rows.length;
             by.scrollTop(offset);
             return;
         }


      </script>
</head>
<body style="margin-left: 0px; margin-top: 0px;">
    <form id="form1" runat="server">
    <div style="position:absolute; width:100%; height:100%;background:url(images/bkg.png) repeat-y 0 0;">
    <div align="left">
       <%-- <div id="row1">
        <input id="upload" runat="server" type="file" />
        <asp:button id="uploadbtn" runat="server" text="上传" OnClick="uploadbtn_Click"/>       
        <input id="downloadbtn" type="button" value="下载" onclick="downloadbtn_Click()" />
        </div>--%>
        <div id="row2">
            <div class="row">
                <div>
                    <span class="label label-success" id="title" style="height: 30px; display: block; font-size: 24px;">文件上传</span>
                </div>
            </div>
            <div class="row">
                <div class="form-group">
                    <input id="fileInput" name="file" type="file" multiple="multiple" data-upload-url="#"/>
                </div>
                <hr/>
                <div class="form-group" style="display: none;">
                    <button class="btn btn-primary">提交</button>
                </div>
                <hr/>
            </div>

            <div class="row"></div>
        </div>
        <table align="center" style="text-align: center; height: 100%">
            <tr>
                <td>
                    
                </td>
            </tr>
            <tr>
                <td class="FailText" id="errorLabel">
                    &nbsp;
                </td>
                
            </tr>
            <tr>
                <td align="center">
                    <div id="grdMain">
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
   </div>
        </form>
</body>
</html>
