# Invoke-BSAOvhApiRequest

Make request to the OVH API.

## Getting Started

Follow this link https://docs.ovh.com/gb/en/customer/first-steps-with-ovh-api/ to create an Application Key, Application Secret and get your Consumer Key.

### Prerequisites

* Windows 7+ / Windows Server 2003+
* PowerShell v3+

## Description

Make a request to the OVH API by entering the following parameters: ApplicationKey, ApplicationSecret, ConsumerKey, Path, Method.

## Example

Send SMS via OVH API
> $To = "+33123456789"
>		$Properties = @{
>			ApplicationKey    = 'MyApplicationKey'
>			ApplicationSecret = 'MyApplicationSecret'
>			ConsumerKey	      = 'MyConsumerKey'
>			Method		      = 'POST'
>			Path			  = "/sms/MyServiceName/jobs"
>			Body			  = @{
>				charset = 'UTF-8'
>				message = "Hello world!"
>				noStopClause = $true
>				priority = 'high'
>				receivers = @($To)
>				sender = "Me"
>				senderForResponse = $false
>			}
>		}
>		Invoke-BSAOvhApiRequest @Properties
