<#

.SYNOPSIS
	This script is custom built for security to count repositories, size of each repository as well as the number of lines of code in each repository

.DESCRIPTION
	This script checks out (Clones) all the repositories that a user has rights to, processes each repository for requirements and outputs the results into a CSV.

.PARAMETER githubUserName
	The username that the API will clone with
.PARAMETER githubAccessToken
	The token for the username to interact with the API
.PARAMETER apiUrl
    Base organisational URL, eg https://api.github.com/orgs/MyOrganisation


.NOTES 
    Author         :  Igor Loza - igor@loza.net.au, rogiloza@gmail.com, ILoza@agl.com.au
    Role           :  DevOps

.EXAMPLE
    .\githubSecurityAudit.ps1 -githubUserName 'username' -githubAccessToken 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' -organisation 'MyOrganisation'
#> 
[CmdletBinding()]
param(	

	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [String]
	$githubUserName,	
		
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [String[]]
	$githubAccessToken,

	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [String[]]
	$organisation
)


#Github authorization token (username:Token)
$Token=$githubUserName+':'+$githubAccessToken

$Base64Token =[System.Convert]::ToBase64String([char[]]$Token);

$Headers = @{
    Authorization = 'Basic {0}' -f $Base64Token;
    };

$Body = @{
    name = 'Git-Audit';
    location = 'Melbourne, Australia';
} | ConvertTo-Json;

$apiUrl = 'https://api.github.com/orgs/' + $organisation;
$countOfRepos = Invoke-RestMethod -Headers $Headers -Uri $apiUrl -Method GET

#Base Backup Path
$basePathObject= pwd;
$basePath = $basePathObject.Path + "\";
$csvFileName = 'repositorySummary.csv';
$csvHeader='Repository,Size (kb),Lines'
$csvHeader > $csvFileName;
$itemsPerPage = 100;
$totalRepos = $countOfRepos.total_private_repos;
$totalPagesDouble = $totalRepos[0] / $itemsPerPage[0];
$totalPages = [int][Math]::Ceiling($totalPagesDouble)
Write-Host "Total Repositories: " $countOfRepos.total_private_repos;
$item = 0;
for($i=1; $i -le $totalPages; $i++) {
        $apiUrl = 'https://api.github.com/orgs/' + $organisation  + '/repos?page='+$i+'&per_page='+$itemsPerPage
        $page = Invoke-RestMethod -Headers $Headers -Uri $apiUrl -Method GET

        foreach ($extract in $page) {
            $item++;
            $progress = "------- " + "Processing repository " + $item + " of " + $countOfRepos.total_private_repos + " -------";
            Write-Host $progress;
            # Clone Repository
            $cloneURL = 'https://github.com/' + $organisation + '/'+$extract.name + '.git';
            $path = $basePath + $extract.name;
            git clone $cloneURL $path;
            
            # Jump into repo to count lines
            cd $path;
            $lines = gci -Recurse |ForEach-Object { if (!($_.PSIsContainer)) { $_}} | gc | Measure-Object -Line
            cd $basePath;

            # Remove Processed Repository save results to csv file
            rm $path -Recurse -Force;
            $extract.name + "," + $extract.size +"," + $lines.Lines >> $csvFileName;
        }
}