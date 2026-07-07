function prompt
{
    $origLastExitCode = $LASTEXITCODE;
    $folderName = (get-item $pwd).Name;
    # $emoji = [char]::ConvertFromUtf32(0x1F914);  

    if ($isNotWindows) {
        # A bug in PSReadline on .NET Core makes all colored write-host output in prompt 
        # function, including write-vcsstatus, echo twice.
        # https://github.com/PowerShell/PowerShell/issues/1897
        # https://github.com/lzybkr/PSReadLine/issues/468
        "$folderName -> ";
    }
    else {
        Write-Host "$env:computername " -ForegroundColor Green -NoNewLine
        Write-Host $(get-date) -ForegroundColor Green
        Write-Host  "PS" $PWD ">" -nonewline -foregroundcolor White
        return " "
        Write-VcsStatus;
        " -> ";
    }

    # Yarn and msbuild have a habit of corrupting console colors when ctrl+c-ing them. Reset colors on each prompt.
    [Console]::ResetColor();

    $LASTEXITCODE = $origLastExitCode;
}