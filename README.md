# Ardoq
PowerShell wrapper for the public Ardoq REST API - https://ardoq.com/api/

Available from PowerShell Gallery: https://www.powershellgallery.com/packages/Ardoq

You would need a token to access your organization. Read the Authorization documentation located at the Ardoq REST API Documentation to get your token: https://app.ardoq.com/presentation/ardoqAPI/slide/0/

## Release notes
0.0.1.5 - Added UTF8 encoding to Update-ArdoqComponent and New-ArdoqComponent<br>
0.0.1.4 - Removed verbose from New-ArdoqComponent<br>
0.0.1.3 - Added function New-ArdoqComponent<br>
0.0.1.2 - Fixed -Force argument on Function Update-ArdoqComponent<br>
0.0.1.1 - Initial version

##Example
<pre>
PS C:\> Find-Package Ardoq -Source PSGallery|Install-Module
PS C:\> New-ArdoqAPIHeader -Token 11223344556677889900aabbccddeeff -SetGlobal

Name                           Value                                                                                                  
----                           -----                                                                                                  
ArdoqAPIBaseUri                https://app.ardoq.com/api                                                                              
ArdoqAPIHeader                 {Authorization, Content-type, Accepts}  

PS C:\> $Workspace = Get-ArdoqWorkspace -Name DEMO
PS C:\> Get-ArdoqComponent -WorkspaceID $Workspace._id|select name,type,lastModifiedByName,version

name                 type               lastModifiedByName version
----                 ----               ------------------ -------
Predefined Process 1 Predefined Process Dummy User         0.0.1  
Terminal 1           Terminal           Dummy User         0.0.1  
Connection 1         Connection         Dummy User         0.0.1  
Process 1            Process            Dummy User         0.0.1  
Preparation 1        Preparation        Dummy User         0.0.1  
Result 1             Result             Dummy User         0.0.1  
State 1              State              Dummy User         0.0.1  
Item 1               Item               Dummy User         0.0.1  
Input/Output 1       Input/Output       Dummy User         0.0.1  
Decision 1           Decision           Dummy User         0.0.1  
</pre>
