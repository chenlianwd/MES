<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Default.aspx.cs" Inherits="HomePage" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=9; IE=8; IE=7; IE=EDGE" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <link href="js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet"
        type="text/css" />
    <link href="css/LoginStyle.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .l-link
        {
            display: block;
            height: 26px;
            line-height: 26px;
            padding-left: 10px;
            text-decoration: underline;
            color: #333;
        }
        .l-layout-top
        {
        	background: #8EA9D8;
        }
    </style>

    <script src="js/jquery-1.7.1.min.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerLayout.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerTab.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerAccordion.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>

    <script src="js/ligerui/Source/lib/ligerUI/js/plugins/ligerDialog.js" type="text/javascript"></script>

    <script src="js/settings.js" type="text/javascript"></script>

    <script type="text/javascript">
        var tab = null;
        var accordion = null;

        $(function() {

            $("#layout1").ligerLayout({ leftWidth: 120, topHeight: 60, height: '100%', heightDiff: -24, space: 4, onHeightChanged: f_heightChanged });
            var height = $(".l-layout-center").height();
            //Tab
            tab = $("#framecenter").ligerTab({ height: height });
            //accordion = $("#accordion1").ligerGetAccordionManager();

            $("#pageloading").hide();

            f_GetCurrUserInfo();
        });

        function f_heightChanged(options) {
            if (tab)
                tab.addHeight(options.diff);
            if (accordion && options.middleHeight - 24 > 0)
                accordion.setHeight(options.middleHeight - 24);
        }
        function f_addTab(tabid, text, url) {
            tab.addTabItem({
                tabid: tabid,
                text: text,
                url: url
            });
        }

        function f_SetCurrentUserLabel(sHtml) {
            lbl = document.getElementById("currentUserLabel");
            if (lbl)
                lbl.innerHTML = sHtml;
        }
        var LoginDlg;
        function f_LoginDlg_open() {
            if (LoginDlg != null)
                return;
            LoginDlg = $.ligerDialog.open({
                height: null,
                title: 'Login',
                url: 'Login.aspx',
                width: 650,
                height: 420,
                showMax: false,
                showToggle: false,
                showMin: false,
                isResize: false,
                slide: true,
                isHidden: false,
                onClose: function() {
                    f_GetCurrUserInfo();
                    LoginDlg = null;
                }
            });
        }
        var f_LoginAuthenticated = function() {
            f_GetCurrUserInfo();
            if (LoginDlg)
                LoginDlg.close();
            LoginDlg = null;

            window.top.document.location = ".";
        }
        
        function f_Open_SettingTab()
        {
            f_addTab('Settings', "Settings", 'Admin');
        }
        
        function f_GetCurrUserInfo() {
            var sHtml = "<span style='font-size:9px' onclick='javascript:f_LoginDlg_open()' onmouseover='SetMouseOverColor(this)' onmouseout='SetMouseLeaveColor(this)' style='cursor:pointer;'>[Login]</span>";
            $.ajax({
                type: 'post',
                url: 'FetchData.ashx?fn=GetLogedUserName',
                cache: false,
                dataType: 'json',
                success: function(data) {
                    if (data && data.Fullname) {
                        g_nLogedUserID = data.Fullname;
                        sHtml = "<span style='color:#ff00ff;font-size:12px'>" + data.Fullname + "</span>"
                          + "<span style='font-size:9px' onclick='javascript:f_logout(this)' onmouseover='SetMouseOverColor(this)' onmouseout='SetMouseLeaveColor(this)' style='cursor:pointer;'>[Logout]</span>"
                        //  + "<span onclick='javascript:f_LoginDlg_open()' onmouseover='SetMouseOverColor(this)' onmouseout='SetMouseLeaveColor(this)' style='cursor:pointer;'>[Change User/Re-Login]</span>"
                          + "<span onclick='javascript:f_Open_SettingTab()' onmouseover='SetMouseOverColor(this)' onmouseout='SetMouseLeaveColor(this)' style='cursor:pointer;'>[Settings]</span>";
                        //g_nUserLevelID = data.nUserLevelID;
                        //if (g_nUserLevelID == g_UserLevels.userLvlAdmins.id)
                        //    sHtml += "<span onclick='javascript:parent.f_UsrMgrDlg_open()' onmouseover='SetMouseOverColor(this)' onmouseout='SetMouseLeaveColor(this)' style='cursor:pointer;'>[Users Manager]</span>";
                    }
                    f_SetCurrentUserLabel(sHtml);
                },
                error: function(XMLHttpRequest, textStatus) {
                    f_SetCurrentUserLabel(sHtml);
                }
            });
        }

        function f_logout() {
            $.ajax({
                type: 'post',
                url: 'FetchData.ashx?fn=logout',
                cache: false,
                dataType: 'json',
                success: function(data) {
                    f_GetCurrUserInfo();
                },
                error: function(XMLHttpRequest, textStatus) {
                    f_GetCurrUserInfo();
                }
            });
        }

    </script>

</head>
<body scroll="no" style="background-position: #8EA9D8; padding: 0px; background: #EAEEF5;
    margin: 0px 0px 0px 0px">
    <div id="pageloading">
    </div>
    <form id="form1" runat="server">
    <asp:Panel ID="layout1" runat="server" Style="width: 100%; height: 100%; margin: 0 auto;
        margin-top: 0px;">
        <div position="top" style="background: #8EA9D8; color: White; width: 100%;">
            <table cellpadding="0" class="topheader" cellspacing="0" border="0" width="100%"
                style="margin-top: -4px;">
                <tr>
                    <td width="270px" align="left" style="width: 10%">
                        <img src="images/jhd.png" height="53px" />
                    </td>
                    <td style="vertical-align: middle; text-align: left; width: 18%">
                        <div id="userinfo" style="vertical-align: middle; padding-top: 3px; padding-right: 14px;
                            font-weight: bold; text-align: left; color: White;">
                        </div>
                    </td>
                    <td style="width: 30%;">
                    </td>
                    <td align="right" style="">
                        &nbsp;</td>
                    <td style="vertical-align: middle; padding-top: 3px; padding-right: 14px; font-weight: bold;
                        text-align: right; color: White;">
                        <span id="currentUserLabel" class="lblLogin"></span>
                    </td>
                </tr>
            </table>
        </div>
        <asp:Panel ID="framecenter" runat="server" position="center">
            <div tabid="Th1F" title="eDashBoard Page1">
                <iframe frameborder="0" name="Th1FIframe" src="DashPage.aspx"></iframe>
            </div> 
            <div tabindex="2" title="autosolder Page">
                <iframe style="border:none" name="Th2FIframe" src="AutoSolder.aspx"></iframe>
            </div>
            <%--<div id="TTrack" title="Reflower Tester Page">
                <iframe style="border:none" name="Th3FIframe" src="TTrack.aspx"></iframe>
            </div>--%>
            <div id="Display Board" title="Display Board">
                <iframe style="border:none" name="Th4FIframe" src="DisplayBoard.aspx"></iframe>
            </div>
        </asp:Panel>
    </asp:Panel>
    <div position="bottom" style="height: 16px; line-height: 16px; text-align: center;">
        Copyright © 2016
    </div>
    </form>
</body>
</html>
