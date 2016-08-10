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

    IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or Set-ArdoqAPIHeader'-ErrorAction Stop}
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

    IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or Set-ArdoqAPIHeader' -ErrorAction Stop}
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
                $URI = "$BaseURI/component/search?workspace=$WorkSpaceID"
            }
        }
    }

    #$ObjectTypeName = "Ardoq.Component"
    #if(-not (Get-TypeData -TypeName Ardoq.Component))
    #{
    #    Update-TypeData -TypeName Ardoq.Component -DefaultDisplayPropertySet "name","type","_id" -Force
    #}
    
    $objects = Invoke-RestMethod -Uri $URI -Headers $headers -Method GET -ContentType JSON
    #$object.PSObject.TypeNames.Insert(0, "Ardoq.Component")
    $objects
}
Function Update-ArdoqComponent{
    [CmdletBinding()] 
    Param(
        [parameter(Mandatory=$false)] 
        [string]
        $Id
        ,
        [Parameter(Mandatory=$True, 
        ValueFromPipeline=$True)]
        [Object]
        $Object
        ,
        [parameter(Mandatory=$false)] 
        [string]
        $Token = $Token
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

    IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or Set-ArdoqAPIHeader' -ErrorAction Stop}
    IF(!$BaseURI){Write-error -Message 'Ardoq Base API URI not specified. Use -BaseURI parameter or Set-ArdoqAPIBaseUri' -ErrorAction Stop}
    
    IF ($Force)
    {
        $ForceObject = Get-ArdoqComponentbyID -Id $Object._id
        $Object._version = $ForceObject._version
    }

    $json = ConvertTo-Json $Object
    
    $URI = "$BaseURI/component/$($Object._id)"

    $Object = Invoke-RestMethod -Uri $URI -Headers $headers -Method PUT -Body $json
    
    IF ($PassTruh)
    {
        $Object
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

    IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or Set-ArdoqAPIHeader' -ErrorAction Stop}
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

    IF(!$Headers){Write-error -Message 'Ardoq API header not specified. Use -Headers parameter or Set-ArdoqAPIHeader' -ErrorAction Stop}
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