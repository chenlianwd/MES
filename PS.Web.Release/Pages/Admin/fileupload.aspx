<%@ Page Language="c#" CodeFile="fileupload.aspx.cs" Inherits="fileUpload" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title></title>
    <script language="javascript" type="text/javascript">
        function f_setStatus()
        {
            if (g_nStatus != 2 && parent.f_AfterUpload)
                parent.f_AfterUpload(g_sPurpose, g_nStatus, unescape(g_sErrMsg), g_nObjectID, g_nFileID, g_sNewFileUrl);
        }
    </script>

</head>
<body style="margin-top: -50px; margin-left: -50px;" onload="f_setStatus();">
    <div style="position: absolute; left: -50px; top: -50px;">
        <form method="post" enctype="multipart/form-data" id="UploadForm" runat="server">
            <asp:FileUpload ID="fileUploadArea" runat="server" Style="font-size: 300px;" onchange="f_CheckVal(this);" accept="image/gif, image/jpeg, image/png" />
            <asp:HiddenField runat="server" ID="ownerCtl" />
            <asp:HiddenField runat="server" ID="Purpose" />

            <script type="text/javascript">
                function f_CheckVal(obj)
                {
                    //var fileUpload=document.getElementById("fileUpload");
                    UploadForm.submit();
                }
            </script>
        </form>
    </div>
</body>
</html>
