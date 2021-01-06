<#
.SYNOPSIS
    This script will check the status of the database and services before patching.
    The servers whose patching have been scheduled and need to check the status of them before patching to cross verify after patching,
    then two Scripts named Precheck and Postcheck build for.
    Gives the email alert as well as HTML file with the table of all database and services status with required details for passed servers in server list.
    jsonData file is also generated which will be taken by Postcheck script as an input to compare the results.
    
.DESCRIPTION
    Independent Script.
    For Services Name, Display Name, Status, Start Type.
    For Database Instance Name,	Database Name, and its State	
    It will send an email, if scheduled then it is monitoring technique for Database and Service status Pre-Post check on bunch of servers during patching.
    
.INPUTS
    Server List - txt file with the name of the machines/servers which to examine.
    Please set varibles like server list path, output file path, E-Mail id and password as and when guided by comment through code.

.EXAMPLE
    .\Precheck.ps1
    This will execute the script and gives HTML file and email with the details in body.

.NOTES
    PUBLIC
    SqlServer Module need to be installed if not than type below command in powershell prompt.
    Install-Module -Name SqlServer

.AUTHOR & OWNER
    Harsh Parecha
    Sahista Patel
#>

Import-Module SqlServer

#Set Email From
$EmailFrom = “example@outlook.com”

#Set Email To
$EmailTo = “exaplme@outlook.com"

#Set Email Subject
$Subject = “Pre-Check”

#Set SMTP Server Details
$SMTPServer = “smtp.outlook.com”

$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential(“example@outlook.com”, “Password”);
$ServerList = "C:\Serverlist.txt"
$jsonData = "C:\Precheck.json"
$PreHTML = "C:\PreCheck.html"
$count = 0
$Precheck = @()
$date = Get-Date
$obj=Get-Content -Path $ServerList
$Precheck = "{"
$id = 0
$obj.Length

$Row = '<html>
            <head>
                <style type="text/css">
                    .tftable {font-size:12px;color:#333333;width:100%;border-width: 1px;border-color: #729ea5;border-collapse: collapse;}
                    .tftable th {font-size:12px;background-color:#acc8cc;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;text-align:left;}
                    .caption1 {font-size:28px;background-color:#e6983b;border-width: 1px; height: 35px;border-style: solid;border-color: #729ea5;text-align:left; vertical-align:middle; font-weight: bold;}
                    .tftable tr {background-color:#ffffff;}
                    .tftable td {font-size:12px;border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;}
                    .tftable tr:hover {background-color:#ffff99;}
                    .OFFLINE {background-color:#ff3300;}
                    .ONLINE {background-color:#33cc33;}
                </style>
                <title>Pre-Checks</title>
            </head>
            <h2>Pre-Check Status on '+ $date +'</h2>
            <body>'

[System.IO.File]::ReadLines($ServerList) | ForEach-Object {
    
    try{
        
        $count += 1      
        $ol = Get-WmiObject -Class Win32_Service -ComputerName "$_"
        if ($ol -ne $null){
            $id++
            $Precheck += '"' + $id + '": {"Server": "' + $_ + '", "Services": '
            $Row += "<div class='caption1'>"+ $_  +"</div><table class='tftable' border='1'>
                        <tr>
                            <th style='background-color:#3399ff; font-size:15px; font-weight: bold; border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;text-align:left;'>Services</th>
                        </tr>
                        <tr>
                            <th>Name</th>
                            <th>Display Name</th>
                            <th>Status</th>
                            <th>Start Type</th>
                        </tr>"
            $Service = Get-service -ComputerName "$_" -Displayname *SQL* | Select-Object -Property Name, DisplayName, @{ n='StartType'; e={ $_.StartType.ToString() } }, @{ n='Status'; e={ $_.Status.ToString() } }
            ForEach($servicelist in $Service){
                $Row += "<tr>
                            <td>"+ $servicelist.Name +"</td>
                            <td>"+ $servicelist.DisplayName +"</td>
                            <td>"+ $servicelist.Status +"</td>
                            <td>"+ $servicelist.StartType +"</td>
                         </tr>"
            }
            $Precheck  += $Service | ConvertTo-Json
            $Row += "<tr>
                        <th style='background-color:#3399ff; font-size:15px; font-weight: bold; border-width: 1px;padding: 8px;border-style: solid;border-color: #729ea5;text-align:left;'>DB Status</th>
                     </tr> 
                     <tr>
                        <th>Instance Name</th>
                        <th>DB Name</th>
                        <th>State</th>
                     </tr>"
            $Precheck += ',"DBStatus": ['
            $Inst_list = $_ | Foreach-Object {Get-ChildItem -Path "SQLSERVER:\SQL\$_"} 
            Foreach ($Inst_list_item in $Inst_list){
                $Result = Invoke-Sqlcmd -Query "SELECT name AS Name, state_desc AS State FROM sys.databases;" -ServerInstance $Inst_list_item.Name
                $sqlCount = 0
                ForEach($line in $Result){
                    $sqlCount += 1
                    $l1 = ($Inst_list_item.Name).Replace("\","/")
                    $Precheck += ' { "Instance": "'+ $l1 + '", "Name": "'+ $line.Name + '", "State": "'+ $line.State + '" '
                    $Row += "<tr>
                                <td>"+ $Inst_list_item.Name +"</td>
                                <td>"+ $line.Name +"</td>
                                <td class='"+ $line.State +"'>"+ $line.State +"</td>
                             </tr>"
                     # if($sqlCount -ne $Result.Count){
                        $Precheck  += "},"
                   # }
                }          
            }
            $Precheck = $Precheck.Substring(0,$Precheck.Length-1)
            $Precheck += "]}"

            if($count -eq $obj.Length){
                $Precheck  += "}"
            }
            else{
                $Precheck  += ","
            }
            $Row += "</table></br/br>"
        }
    }

    catch{

    }

}

$Row += "</body></html>"
Set-Content $PreHTML $Row
Set-Content $jsonData $Precheck
$Body = $Row
$SMTPClient.EnableSsl = $true
# Create the message
$mail = New-Object System.Net.Mail.Mailmessage $EmailFrom, $EmailTo, $Subject, $Body
$mail.IsBodyHTML=$true
$SMTPClient.Send($mail) 
