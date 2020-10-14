<#
	.SYNOPSIS
		Make request to the OVH API.
	
	.DESCRIPTION
		Make a request to the OVH API by entering the following parameters: ApplicationKey, ApplicationSecret, ConsumerKey, Path, Method.
	
	.PARAMETER ApplicationKey
		Application key of your application.
		To create one, follow this link https://docs.ovh.com/gb/en/customer/first-steps-with-ovh-api/
	
	.PARAMETER ApplicationSecret
		Application secret of your application.
		To create one, follow this link https://docs.ovh.com/gb/en/customer/first-steps-with-ovh-api/
	
	.PARAMETER ConsumerKey
		Consumer key of your application.
		To create one, follow this link https://docs.ovh.com/gb/en/customer/first-steps-with-ovh-api/
	
	.PARAMETER Url
		Enter the URL, if you are not using the European server https://eu.api.ovh.com/1.0
	
	.PARAMETER Path
		Enter the path you want to request. Example: "/sms/MyServiceName/jobs".
	
	.PARAMETER Method
		Choose a method: GET, POST, PUT or DELETE.
	
	.PARAMETER Body
		Enter the body of the request.
	
	.EXAMPLE
		# Send SMS via OVH API
		$To = "+33123456789"
		$Properties = @{
			ApplicationKey    = 'MyApplicationKey'
			ApplicationSecret = 'MyApplicationSecret'
			ConsumerKey	      = 'MyConsumerKey'
			Method		      = 'POST'
			Path			  = "/sms/MyServiceName/jobs"
			Body			  = @{
				charset = 'UTF-8'
				message = "Hello world!"
				noStopClause = $true
				priority = 'high'
				receivers = @($To)
				sender = "Me"
				senderForResponse = $false
			}
		}
		Invoke-BSAOvhApiRequest @Properties
	
#>
function Invoke-BSAOvhApiRequest
{
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[Alias('AK')]
		[string]$ApplicationKey,
		[Parameter(Mandatory = $true)]
		[Alias('AS')]
		[string]$ApplicationSecret,
		[Parameter(Mandatory = $true)]
		[Alias('CK')]
		[string]$ConsumerKey,
		[string]$Url = 'https://eu.api.ovh.com/1.0',
		[Parameter(Mandatory = $true)]
		[string]$Path,
		[Parameter(Mandatory = $true)]
		[ValidateSet('DELETE', 'GET', 'POST', 'PUT')]
		[string]$Method,
		[hashtable]$Body
	)
	
	try
	{
		$Url = $Url.TrimEnd('/')
		$Path = $Path.TrimStart('/')
		
		$Properties = @{
			ContentType = 'application/json;charset=utf-8'
			Headers	    = @{
				'X-Ovh-Application' = $ApplicationKey
				'X-Ovh-Consumer'    = $ConsumerKey
				'X-Ovh-Timestamp'   = (Invoke-WebRequest "$Url/auth/time").Content
			}
			Method	    = $Method
			Uri		    = "$Url/$Path"
			ErrorAction = "Stop"
		}
		
		$TimeStamp = (Invoke-WebRequest "$Url/auth/time").Content
		if ($PSBoundParameters['Body'])
		{
			$JsonBody = $Body | ConvertTo-Json -Compress
			$Properties.Body = $JsonBody
			$PreHash = "$ApplicationSecret+$ConsumerKey+$Method+$Url/$Path+$JsonBody+$TimeStamp"
		}
		else
		{
			$Properties.Body = $null
			$PreHash = "$ApplicationSecret+$ConsumerKey+$Method+$Url/$Path++$TimeStamp"
		}
		
		$Sha1 = [Security.Cryptography.SHA1CryptoServiceProvider]::new()
		$Bytes = [Text.Encoding]::UTF8.GetBytes($PreHash)
		$Hash = [BitConverter]::ToString($Sha1.ComputeHash($Bytes)).Replace('-', '').ToLower()
		$Properties.Headers.'X-Ovh-Signature' = "`$1`$$Hash"
		
		if ('UseBasicParsing' -in (Get-Command Invoke-RestMethod).Parameters.Keys)
		{
			$Properties.UseBasicParsing = $true
		}
		
		Invoke-RestMethod @Properties
	}
	catch
	{
		Write-Host $_.Exception.Message
	}
}


