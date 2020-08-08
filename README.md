# CloneApp
CloneApp exports the API Permissions of an AzureAD App to an XML file. CloneApp can create a new App and import the API Permissions from the XML file. The import can be in the same or another tenant. A client secret and admin consent URL can be generated for the new app. The XML file can also be imported via a GIST.

## Prerequisite when TLS1.2 is not enforced
If you receive an error attempting to installing the module. Run this and try again.
```
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
```

## Prerequisite Module required
```
Install-Module AzureAD -Force
```

## How to install
```
Install-Module CloneApp -Force
```

## Install without admin access
```
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
Install-Module CloneApp -Force -Scope CurrentUser
```

### Export
```
Export-AzureADApp -Name TestApp -Path C:\temp\apps
```

### Import from GIST
```
$params = @{
    Owner               = 'admin@contoso.onmicrosoft.com'
    GithubUsername      = 'kevinblumenfeld'
    GistFilename        = 'testapp.xml'
    Name                = 'NewApp'
    SecretDurationYears = 4
    ConsentAction       = 'Both'
}
Import-AzureADApp @params
```

### Import from file
```

$params = @{
    Owner               = 'admin@contoso.onmicrosoft.com'
    XMLPath             = 'C:\Scripts\TestApp-20200808-0349.xml'
    Name                = 'NewApp01'
    SecretDurationYears = 1
    ConsentAction       = 'OutputUrl'
}
Import-AzureADApp @params
```
