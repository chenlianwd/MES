<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Preferences.aspx.cs" Inherits="Preferences" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="X-UA-Compatible" content="IE=9; IE=8; IE=7; IE=EDGE" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title></title>
    <link href="../js/ligerui/Source/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .auto-style1 {
        }

        fieldset {
            display: block;
            margin-left: 2px;
            margin-right: 2px;
            padding-top: 0.35em;
            padding-bottom: 0.625em;
            padding-left: 0.75em;
            padding-right: 0.75em;
            border: 1px groove;
        }

        .FailText {
            color: #FF0000;
            text-align: left;
        }

        .fieldTitle {
            width: 120px;
            text-align: right;
        }

        td {
            margin-left: 2px;
            margin-right: 2px;
            padding-top: 0.2em;
            padding-bottom: 0.2em;
            padding-left: 0.1em;
            padding-right: 0.1em;
        }
        .auto-style2 {
            height: 31px;
        }
    </style>
    <script src="../js/jquery-1.7.1.min.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/core/base.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerLayout.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerTab.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerDateEditor.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerAccordion.js" type="text/javascript"></script>
    <script src="../js/ligerui/Source/lib/ligerUI/js/plugins/ligerComboBox.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(function ()
        {
        });

        
        function f_OnLoad_uploadFrame(sFrameName,sPurpose,nObjectID)
        {
            var bLoadOK = false;
            try
            {
                var frames;
                if (document.all)
                    frames = document.frames;
                else
                    frames = document.getElementsByTagName("IFRAME");
                var frame = frames[sFrameName];
                if (frame)
                {
                    var wnd = frame.contentWindow; //FF,chrome
                    if (!wnd) wnd = frame.window; //IE                                                            
                    var doc = frame.document; //IE
                    if (!doc) doc = frame.contentDocument; //FF,chrome
                    if (doc)
                    {                     
                        var uploadFile = doc.getElementById("fileUploadArea");
                        if (uploadFile)
                        {
                            bLoadOK = true;
                            doc.getElementById("Purpose").value = sPurpose;
                            doc.getElementById("ObjectID").value = nObjectID;
                        }
                    }
                }
            }
            catch (e)
            {
            }
            if (!bLoadOK)
                window.open("fileupload.aspx", sFrameName);
        }

        function f_AfterUpload(sPurpose, bStatus, sErrMsg, nObjectID, nFileID, sNewFileUrl)
        {
            if (sErrMsg)
                document.getElementById("errorLable").innerHTML = sErrMsg;
            else if (bStatus==1)
                document.getElementById("imgLogo").src = "../getFile.ashx?fn="+ sNewFileUrl;
        }
    </script>
</head>
<body>
    <form id="frmPreferences" runat="server">
        <table style="align-content: center" align="center">
            <tr>
                <td class="FailText" id="errorLable"></td>
            </tr>
            <tr>
                <td>
                    <fieldset>
                        <legend>
                            <asp:Label ID="lblGenericSetting" runat="server"> Generic Setting:</asp:Label></legend>
                        <table>
                            <tr>
                                <td class="fieldTitle">
                                    <asp:Label ID="lblLanguage" runat="server" AssociatedControlID="lstLanguage">Default Language:</asp:Label>
                                </td>
                                <td>
                                    <asp:DropDownList ID="lstLanguage" runat="server" Width="300px"  /></td>
                                <td class="Tips"></td>
                            </tr>
                            <tr>
                                <td class="fieldTitle">
                                    <asp:Label ID="lblHomePageTitle" runat="server" AssociatedControlID="edtHomgePageTitle">Home Page Title:</asp:Label>
                                </td>
                                <td class="auto-style1">
                                    <asp:TextBox ID="edtHomgePageTitle" runat="server" Width="300px" TextMode="MultiLine" Height="60px" Style="text-align: right;"  /></td>
                                <td class="Tips"></td>
                            </tr>
                              <tr>
                                <td class="fieldTitle">
                                    <asp:Label ID="lblMustLogin" runat="server" AssociatedControlID="chkMustLogin">Must Login:</asp:Label>
                                </td>
                                <td class="auto-style1">
                                    <asp:CheckBox ID="chkMustLogin" runat="server" Style="text-align: right;" /></td>
                                <td class="Tips"></td>
                            </tr>
                            <tr>
                                <td class="fieldTitle">
                                    <asp:Label ID="lblHomePageLogo" runat="server">Home Page Logo:</asp:Label>
                                </td>
                                <td style="background: #225FB2; color: White;">
                                    <div style="position: absolute; filter: alpha(opacity:0); opacity: 0; z-index: 1000;">
                                        <iframe id="uploadFrame" name="uploadFrame" src="fileupload.aspx" onload="f_OnLoad_uploadFrame('uploadFrame', 'LogoOfHome', 0);"
                                            frameborder="1" scrolling="no" style="width: 300px; height: 60px; filter: alpha(opacity:0); opacity: 0;"></iframe>
                                    </div>
                                    <asp:Image ID="imgLogo" runat="server" Style="width: 300px; height: 60px;" />                                    
                                </td>
                                <td class="Tips"></td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td>
                    <fieldset>
                        <legend>
                            <asp:Label ID="lblDatabaseSetting" runat="server"> Database:</asp:Label></legend>
                        <table>
                            <tr>
                                <td class="fieldTitle">
                                    <asp:Label ID="lblDatabaseType" runat="server" AssociatedControlID="lstDatabaseType"> Type:</asp:Label></td>
                                <td>
                                    <asp:DropDownList ID="lstDatabaseType" runat="server" Width="300px" AutoPostBack="false" /></td>
                                <td class="Tips"></td>
                            </tr>
                            <tr>
                                <td class="fieldTitle">
                                    <asp:Label ID="lblDbServer" runat="server" AssociatedControlID="edtDbServer"> Server:</asp:Label></td>
                                <td>
                                    <asp:TextBox ID="edtDbServer" runat="server" Width="300px" /></td>
                            </tr>
                            <tr>
                                <td class="fieldTitle">
                                    <asp:Label ID="lblPort" runat="server" AssociatedControlID="edtPort"> Port:</asp:Label></td>
                                <td>
                                    <asp:TextBox ID="edtPort" runat="server" Width="300px" Text="3306" /></td>
                                <td class="Tips"></td>
                            </tr>
                            <tr>
                                <td class="fieldTitle">
                                    <asp:Label ID="lblUser" runat="server" AssociatedControlID="edtUser"> User:</asp:Label></td>
                                <td>
                                    <asp:TextBox ID="edtUser" runat="server" Width="300px" Text="root" /></td>
                                <td class="Tips"></td>
                            </tr>
                            <tr>
                                <td class="fieldTitle">
                                    <asp:Label ID="lblPwd" runat="server" AssociatedControlID="edtPwd"> Password:</asp:Label></td>
                                <td>
                                    <asp:TextBox ID="edtPwd" runat="server" Width="300px" /></td>
                                <td class="Tips"></td>
                            </tr>
                            <tr>
                                <td style="text-align: right" colspan="2" class="auto-style2">
                                    <asp:Button ID="btnTestConnection" runat="server" Text="Test Connection" /></td>
                            </tr>
                            <tr>
                                <td class="fieldTitle">
                                    <asp:Label ID="lblDatabase" runat="server" AssociatedControlID="lstDatabse"> Database:</asp:Label></td>
                                <td>
                                    <asp:DropDownList ID="lstDatabse" runat="server" Width="300px" AutoPostBack="false"/></td>
                                <td class="Tips"></td>
                            </tr>
                            <tr>
                                <td style="text-align: right" colspan="2">
                                    <asp:Button ID="btnInitDatabase" runat="server" Text="Create Tables For Init Database" /></td>
                                <td class="Tips"></td>
                            </tr>
                        </table>
                    </fieldset>

                </td>
                <td></td>
            </tr>
            <tr>
                <td align="center">
                    <asp:Button ID="btnSubmit"  Text="Submit" 
                        runat="server" OnClientClick="f_Submit();" /></td>
                <asp:HiddenField runat="server" ID="hdnLstLanguage" />
                <asp:HiddenField runat="server" ID="hdnLstDatabaseType" />
                <asp:HiddenField runat="server" ID="hdbMustLogin" />
                <asp:HiddenField runat="server" ID="hdbLogUrl" />
                  <script type="text/javascript">
                      function f_Submit(obj)
                      {
                          document.getElementById("hdnLstLanguage").value = document.getElementById("lstLanguage").value;
                          document.getElementById("hdnLstDatabaseType").value = document.getElementById("lstDatabaseType").value;
                          document.getElementById("hdbMustLogin").value = document.getElementById("chkMustLogin").checked;
                          document.getElementById("hdbLogUrl").value = document.getElementById("imgLogo").checked;
                          frmPreferences.submit();
                      }
                  </script>
            </tr>
        </table>
    </form>
</body>
</html>
