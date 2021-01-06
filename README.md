# Pre-PostCheck_ForServerPatching
## Pre-Check
This script will check the status of the database and services before patching. The servers whose patching have been scheduled and need to check the status of them before patching to cross verify after patching, then two Scripts named Precheck and Postcheck build for. Gives the email alert as well as HTML file with the table of all database and services status with required details for passed servers in server list. jsonData file is also generated which will be taken by Postcheck script as an input to compare the results.

Independent Script.
For Services Name, Display Name, Status, Start Type.
For Database Instance Name,	Database Name, and its State	
It will send an email, if scheduled then it is monitoring technique for Database and Service status Pre-Post check on bunch of servers during patching.

## Prerequisites

Windows OS - Powershell
SqlServer Module need to be installed if not than type below command in powershell prompt.
Install-Module -Name SqlServer

## Note
  
Server Name - Name of the target Machine<br>
-=-=-=-=-=-=- Services -=-=-=-=-=-=-<br>
Services Name - Name of the Service<br>
Display Name - Service's display Name<br>
Status - Service state Running, Stopped, etc<br>
Start Type - The Service type like Manual, Automatic, etc<br>
-=-=-=-=-=-=- Database -=-=-=-=-=-=-<br>
Instance Name - The SQL server Instance Name<br>
Database Name - The Database Name<br>
State - The State of the Database like Online, Offlie<br>

## Use

Open Powershell<br>
"C:\Precheck.ps1"<br>
Run before patching.

## Input
Server list file path to (example) {$path = "C:\server_list.txt"}<br>
The output txt file path for next script input (example) {$jsonData = "C:\Precheck.json"}<br>
The output file path to (example) {$outpath = "C:\disk_status_htm.html"}<br>
Set Email From (example) {$EmailFrom = “example@outlook.com”}<br>
Set Email To (example) {$EmailTo = “example@outlook.com"}<br>
Set Email Subject (example) {$Subject = “Precheck”}<br>
Set SMTP Server Details (example) {<br> 
$SMTPServer = “smtp.outlook.com” <br>
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)<br>
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential(“example@outlook.com”, “Password”);}

## Example O/P

![alt text](https://github.com/Sahista-Patel/Pre-PostCheck_ForServerPatching/blob/Powershell/preservices.PNG)
![alt text](https://github.com/Sahista-Patel/Pre-PostCheck_ForServerPatching/blob/Powershell/predb.PNG)

## Post-Check
This script will parse the json file created by Script - Precheck and then compare the status after patching, it also gives verification OK or KNOT.
Dependent Script.
It is important to execute Script - Precheck before patching to run this Script - Postcheck after patching.

## Prerequisites

Windows OS - Powershell
It is important to execute Script - Precheck before patching to run this Script - Postcheck after patching.

## Note
  
Include the servers whose patching has been scheduled or pre-check post check needs to be done.


## Use

Open Powershell
"C:\Postcheck.ps1"


## Input
Server list file path to (example) {$path = "C:\server_list.txt"}<br>
The input json file path created by Script - Precheck (example) {$jsonData = "C:\Precheck.json"}<br>


## Output

![alt text](https://github.com/Sahista-Patel/Pre-PostCheck_ForServerPatching/blob/Powershell/postservices.PNG)
![alt text](https://github.com/Sahista-Patel/Pre-PostCheck_ForServerPatching/blob/Powershell/postdb.PNG)

## License

Copyright 2020 Harsh & Sahista

## Contribution

* [Harsh Parecha] (https://github.com/TheLastJediCoder)
* [Sahista Patel] (https://github.com/Sahista-Patel)<br>
We love contributions, please comment to contribute!

## Code of Conduct

Contributors have adopted the Covenant as its Code of Conduct. Please understand copyright and what actions will not be abided.
