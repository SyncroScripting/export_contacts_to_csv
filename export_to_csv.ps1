######### Secrets #########
$apiKey = "your API token"
$apiUri = "https://your_subdomain.syncromsp.com/api/v1/"
######### Secrets #########

$query = [System.Web.HTTPUtility]::UrlEncode($(Read-Host "Please enter client name"))
$companySyncroID = (Invoke-RestMethod -Uri "$apiUri/customers?query=$query" -Method Get -Header @{ "Authorization" = "Bearer "+$apiKey } -ContentType "application/json")[0].customers.id


    if ($companySyncroID -eq $null) {
        write-host "Client $($Customer.Name) not found SyncroMSP" -ForegroundColor Red 
    } else {
        $Syncro = (Invoke-RestMethod -Method Get -Uri "$apiUri/contacts?customer_id=$companySyncroID" -Header @{ "Authorization" = "Bearer "+$apiKey } -ContentType "application/json")
        $allusersSyncro = $syncro.contacts
        $totalPages = $Syncro.meta.total_pages
        if ($totalPages -ne 1) {
            for($i=2; $i -le $totalPages; $i++){
                $allusersSyncro += (Invoke-RestMethod -Method Get -Uri "$apiUri/contacts?customer_id=$companySyncroID&page=$i" -Header @{ "Authorization" = "Bearer "+$apiKey } -ContentType "application/json").contacts
            }
        }
        $allusersSyncro | Export-Csv -Path "$PSScriptRoot\Contacts_for_$query.csv" -NoTypeInformation
    }
