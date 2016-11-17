#region Functions
Function Set-ArdoqAPIBaseUri{
    Param(
        [parameter(Mandatory=$false)] 
        [string]
        $URI = "https://app.ardoq.com/api"
        ,
        [parameter(Mandatory=$true)] 
        [switch]
        $SetGlobal = $false
        )

    IF ($SetGlobal)
    {
        Set-Variable -Name ArdoqAPIBaseUri -Value ($URI) -PassThru -Scope Global 
    }
}
Function New-ArdoqAPIHeader{
    Param(
        [parameter(Mandatory=$true)] 
        [string]
        $Token
        ,
        [parameter(Mandatory=$false)] 
        [switch]
        $SetGlobal = $false
        ,
        [parameter(Mandatory=$false)] 
        [switch]
        $BaseURI
        )

    $Headers = @{
        "Authorization" = "Token token=$token"
        "Content-type" = "application/json"
        "Accepts" = "application/json"
        }
    
    IF ($SetGlobal)
    {
        IF ($ArdoqAPIBaseUri)
        {
            Write-verbose "ArdoqAPIBaseUri variable already set to $ArdoqAPIBaseUri"
        }
        ELSE
        {
            Write-verbose "ArdoqAPIBaseUri set to deafult value"
            Set-ArdoqAPIBaseUri -SetGlobal
        }
        Set-Variable -Name ArdoqAPIHeader -Value ($Headers) -PassThru -Scope Global 
    }
    ELSE
    {
        $Headers
    }
}
Function Clear-ArdoqVariabels{
    $ArdoqAPIHeader = $null
    $Global:ArdoqAPIHeader = $null
    $ArdoqAPIBaseUri = $null
    $Global:ArdoqAPIBaseUri = $null
    $ArdoqWorkspaceId = $null
    $Global:ArdoqWorkspaceId = $null
}
Function Get-ArdoqWorkspace{
    [CmdletBinding()] 
    Param(
        [parameter(Mandatory=$false)] 
        [string]
        $Id
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $Name
        ,
        [parameter(Mandatory=$false)] 
        [hashtable]
        $Headers = $ArdoqAPIHeader
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $BaseURI = $ArdoqAPIBaseUri
    )

    IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or New-ArdoqAPIHeader'-ErrorAction Stop}
    IF(!$BaseURI){Write-error -Message 'Ardoq Base API URI not specified. Use -BaseURI parameter or Set-ArdoqAPIBaseUri'-ErrorAction Stop}

    IF ($Id)
    {
        $URI = "$BaseURI/workspace/$id"
    }
    Else
    {
        IF ($Name)
        {
            $URI = "$BaseURI/workspace/search?name=$name"
        }
        ELSE
        {
            $URI = "$BaseURI/workspace/"
        }
    }
    
    $Objects = Invoke-RestMethod -Uri $URI -Headers $headers -Method GET -ContentType JSON
    $Objects
}
Function Get-ArdoqComponent{
    [CmdletBinding()] 
    Param(
        [parameter(Mandatory=$false)] 
        [string]
        $Id
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $WorkspaceID = $ArdoqWorkspaceID
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $org = $ArdoqOrganization
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $Name
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $Field
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $Value
        ,
        [parameter(Mandatory=$false)] 
        [hashtable]
        $Headers = $ArdoqAPIHeader
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $BaseURI = $ArdoqAPIBaseUri
    )

    IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or New-ArdoqAPIHeader' -ErrorAction Stop}
    IF(!$BaseURI){Write-error -Message 'Ardoq Base API URI not specified. Use -BaseURI parameter or Set-ArdoqAPIBaseUri' -ErrorAction Stop}

    IF ($Id)
    {
        $URI = "$BaseURI/component/$ID"
    }
    ELSE
    {
        IF(!$WorkspaceID){Write-error -Message 'Ardoq Workspace ID not specified. Use -WorkspaceID parameter or define variabel $ArdoqWorkspaceID' -ErrorAction Stop}
        IF ($Field)
        {
            IF(!$Value){Write-error -Message 'When using the -Field parameter, -Value must be spesified' -ErrorAction Stop}
            $URI = "$BaseURI/component/fieldsearch?workspace=$WorkSpaceID&$Field=$Value"
        }
        ELSE
        {
            IF ($Name)
            {
                $URI = "$BaseURI/component/search?workspace=$WorkSpaceID&name=$Name"
            }
            ELSE
            {
                $URI = "$BaseURI/component/search?workspace=$WorkSpaceID?org=$org"
            }
        }
    }

    $objects = Invoke-RestMethod -Uri $URI -Headers $headers -Method GET -ContentType JSON
    $objects
}
Function Update-ArdoqComponent{
    [CmdletBinding()] 
    Param(
        [Parameter(Mandatory=$True, 
        ValueFromPipeline=$True)]
        [Object]
        $Object
        ,
        [parameter(Mandatory=$false)] 
        [switch]
        $Force
        ,
        [parameter(Mandatory=$false)] 
        [switch]
        $PassTruh
        ,
        [parameter(Mandatory=$false)] 
        [hashtable]
        $Headers = $ArdoqAPIHeader
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $BaseURI = $ArdoqAPIBaseUri
    )

    Begin{
        IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or New-ArdoqAPIHeader' -ErrorAction Stop}
        IF(!$BaseURI){Write-error -Message 'Ardoq Base API URI not specified. Use -BaseURI parameter or Set-ArdoqAPIBaseUri' -ErrorAction Stop}
    }
    Process
    {
        IF ($Force)
        {
            $ForceObject = $null
            $ForceObject = Get-ArdoqComponent -Id $_._id
            $_._version = $ForceObject._version
        }

        $json = ConvertTo-Json $_
    
        $DefaultEncoding = [System.Text.Encoding]::GetEncoding('ISO-8859-1')
        $UTF8Encoding = [System.Text.Encoding]::UTF8
        $jsonUTF8 = $null
        [System.Text.Encoding]::Convert($DefaultEncoding, $DefaultEncoding, $UTF8Encoding.GetBytes(($json))) | % { $jsonUTF8 += [char]$_}
       
        $URI = "$BaseURI/component/$($_._id)"

        $Object = Invoke-RestMethod -Uri $URI -Headers $Headers -Method PUT -Body $jsonUTF8
    
        IF ($PassTruh)
        {
            $Object
        }
    }
    End
    {
    }
}
Function Remove-ArdoqComponent{
    [CmdletBinding()] 
    Param(
        [parameter(Mandatory=$false)]
        [string]
        $id
        ,
        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$True)]
        [Object]
        $Object
        ,
        [parameter(Mandatory=$false)] 
        [hashtable]
        $Headers = $ArdoqAPIHeader
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $BaseURI = $ArdoqAPIBaseUri
    )
    Begin
    {
        IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or New-ArdoqAPIHeader' -ErrorAction Stop}
        IF(!$BaseURI){Write-error -Message 'Ardoq Base API URI not specified. Use -BaseURI parameter or Set-ArdoqAPIBaseUri' -ErrorAction Stop}
    }
    Process
    {
        IF($Id)
        {
            $URI = "$BaseURI/component/$id"
            $Object = Invoke-RestMethod -Uri $URI -Headers $headers -Method Delete
        }
        ELSE
        {
            IF (!$_._id) { Write-error -Message 'Ardoq Component Id not specified.' -ErrorAction Stop}
            $URI = "$BaseURI/component/$($_._id)"
            $Object = Invoke-RestMethod -Uri $URI -Headers $headers -Method Delete
        }
    }
    End
    {
        #write-host "Ending"
    } 
}
Function New-ArdoqComponent{
    [CmdletBinding()] 
    Param(
        [parameter(Mandatory=$true)]
        [string] 
        $name
        ,
        [parameter(Mandatory=$true)] 
        [string]
        $description
        ,
        [parameter(Mandatory=$true)] 
        [string]
        $parentid
        ,
        [parameter(Mandatory=$true)] 
        [string]
        $typeId
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $WorkspaceId = $ArdoqWorkspaceId
        ,
        [parameter(Mandatory=$false)] 
        [hashtable]
        $Headers = $ArdoqAPIHeader
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $BaseURI = $ArdoqAPIBaseUri
    )

    IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or New-ArdoqAPIHeader' -ErrorAction Stop}
    IF(!$BaseURI){Write-error -Message 'Ardoq Base API URI not specified. Use -BaseURI parameter or Set-ArdoqAPIBaseUri' -ErrorAction Stop}
    IF(!$WorkspaceID){Write-error -Message 'Ardoq Workspace ID not specified. Use -WorkspaceID parameter or define variabel $ArdoqWorkspaceID' -ErrorAction Stop}
    
    $parameters = @{
        "name" = $name
        "description" = $description
        "rootWorkspace" = $WorkspaceId
        "parent" = $parentid
        "typeId" = $typeId
        }
    
    $json = ConvertTo-Json $parameters
    

    $DefaultEncoding = [System.Text.Encoding]::GetEncoding('ISO-8859-1')
    $UTF8Encoding = [System.Text.Encoding]::UTF8
    [System.Text.Encoding]::Convert($DefaultEncoding, $DefaultEncoding, $UTF8Encoding.GetBytes(($json))) | % { $jsonUTF8 += [char]$_}
    

    $URI = "$BaseURI/component"

    Write-verbose $jsonUTF8
    $Object = Invoke-RestMethod -Uri $URI -Headers $Headers -Method Post -Body $jsonUTF8
    $Object
}
Function New-ArdoqReference{
    [CmdletBinding()] 
    Param(
        [parameter(Mandatory=$true)]
        [string] 
        $sourceid
        ,
        [parameter(Mandatory=$true)] 
        [string]
        $targetid
        ,
        [parameter(Mandatory=$true)] 
        [int]
        $type
        ,
        [parameter(Mandatory=$true)] 
        [string]
        $displayText = $displayText
        ,
        [parameter(Mandatory=$false)] 
        [hashtable]
        $Headers = $ArdoqAPIHeader
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $BaseURI = $ArdoqAPIBaseUri
    )

    IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or New-ArdoqAPIHeader' -ErrorAction Stop}
    IF(!$BaseURI){Write-error -Message 'Ardoq Base API URI not specified. Use -BaseURI parameter or Set-ArdoqAPIBaseUri' -ErrorAction Stop}
    
    $parameters = @{
        "source" = $sourceid
        "target" = $targetid
        "type" = $type
        "displayText" = $displayText
        }
    
    $json = ConvertTo-Json $parameters
    

    $DefaultEncoding = [System.Text.Encoding]::GetEncoding('ISO-8859-1')
    $UTF8Encoding = [System.Text.Encoding]::UTF8
    [System.Text.Encoding]::Convert($DefaultEncoding, $DefaultEncoding, $UTF8Encoding.GetBytes(($json))) | % { $jsonUTF8 += [char]$_}
    

    $URI = "$BaseURI/reference"

    Write-verbose $jsonUTF8
    $Object = Invoke-RestMethod -Uri $URI -Headers $Headers -Method Post -Body $jsonUTF8
    $Object
}
Function Remove-ArdoqReference{
    [CmdletBinding()] 
    Param(
        [parameter(Mandatory=$false)]
        [string]
        $id
        ,
        [Parameter(Mandatory=$false, 
        ValueFromPipeline=$True)]
        [Object]
        $Object
        ,
        [parameter(Mandatory=$false)] 
        [hashtable]
        $Headers = $ArdoqAPIHeader
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $BaseURI = $ArdoqAPIBaseUri
    )
    Begin
    {
        IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or New-ArdoqAPIHeader' -ErrorAction Stop}
        IF(!$BaseURI){Write-error -Message 'Ardoq Base API URI not specified. Use -BaseURI parameter or Set-ArdoqAPIBaseUri' -ErrorAction Stop}
    }
    Process
    {
        IF($Id)
        {
            $URI = "$BaseURI/reference/$id"
            $Object = Invoke-RestMethod -Uri $URI -Headers $headers -Method Delete
        }
        ELSE
        {
            IF (!$_._id) { Write-error -Message 'Ardoq Reference Id not specified.' -ErrorAction Stop}
            $URI = "$BaseURI/reference/$($_._id)"
            $Object = Invoke-RestMethod -Uri $URI -Headers $headers -Method Delete
        }
    }
    End
    {
        #write-host "Ending"
    } 
}
Function Get-ArdoqModel{
    [CmdletBinding()] 
    Param(
        [parameter(Mandatory=$false)] 
        [string]
        $Id
        ,
        [parameter(Mandatory=$false)] 
        [hashtable]
        $Headers = $ArdoqAPIHeader
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $BaseURI = $ArdoqAPIBaseUri
    )

    IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or New-ArdoqAPIHeader' -ErrorAction Stop}
    IF(!$BaseURI){Write-error -Message 'Ardoq Base API URI not specified. Use -BaseURI parameter or Set-ArdoqAPIBaseUri' -ErrorAction Stop}
    
    IF ($Id)
    {
        $URI = "$BaseURI/model/$Id"
    }
    ELSE
    {
        $URI = "$BaseURI/model/"
    }

    $Objects = Invoke-RestMethod -Uri $URI -Headers $headers -Method GET -ContentType JSON
    $Objects
}
Function Get-ArdoqReference{
    [CmdletBinding()] 
    Param(
        [parameter(Mandatory=$false)] 
        [string]
        $Id
        ,
        [parameter(Mandatory=$false)] 
        [hashtable]
        $Headers = $ArdoqAPIHeader
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $BaseURI = $ArdoqAPIBaseUri
    )

    IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or New-ArdoqAPIHeader' -ErrorAction Stop}
    IF(!$BaseURI){Write-error -Message 'Ardoq Base API URI not specified. Use -BaseURI parameter or Set-ArdoqAPIBaseUri' -ErrorAction Stop}
    
    IF ($Id)
    {
        $URI = "$BaseURI/reference/$Id"
    }
    ELSE
    {
        $URI = "$BaseURI/reference/"
    }

    $Objects = Invoke-RestMethod -Uri $URI -Headers $headers -Method GET -ContentType JSON
    $Objects
}
#endregion