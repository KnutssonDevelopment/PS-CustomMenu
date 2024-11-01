function Show-ConsoleMenu {
    param (
        [string]$Header,  # Menu header text
        [hashtable]$MenuOptions  # Hashtable containing indexed menu options
    )

    while ($true) {
        # Clear the console and display the menu header
        Clear-Host
        Write-Host $Header -ForegroundColor Cyan
        Write-Host "==================================="

        # Display each menu option with the shortcut, name, description, and optional status in order
        foreach ($index in ($MenuOptions.Keys | Sort-Object)) {
            $option = $MenuOptions[$index]
            $shortcut = $option['Shortcut']
            $status = if ($option.ContainsKey('Status')) { "($($option.Status))" } else { "" }
            Write-Host "[$shortcut] $($option.Name) - $($option.Description) $status"
        }

        # Prompt user for input
        $choice = Read-Host -Prompt "Choose an option (or 'q' to quit)"

        # Check if the user wants to quit
        if ($choice -eq 'q') {
            Write-Host "Exiting menu..." -ForegroundColor Yellow
            break
        }

        # Find the selected option based on the shortcut key
        $selectedOption = $MenuOptions.Values | Where-Object { $_.Shortcut -eq $choice }
        if ($selectedOption) {
            # Execute the function associated with the menu option
            if ($selectedOption.Function -is [scriptblock]) {
                # Pass the entire menu hashtable to allow status updates
                $result = & $selectedOption.Function $MenuOptions
                if ($result) {
                    Write-Host "Status: $result" -ForegroundColor Green
                }
            }
            else {
                Write-Host "Error: No valid function defined for this option." -ForegroundColor Red
            }
        }
        else {
            Write-Host "Invalid option. Please try again." -ForegroundColor Red
        }

        # Pause before showing the menu again
        Start-Sleep -Seconds 1
    }
}

# Example Usage with Indexed Menu Options
$menuOptions = @{
    1 = @{
        Shortcut    = '1'
        Name        = 'Option 1'
        Description = 'Run function 1 and update status'
        Function    = {
            param($menuOptions)
            Write-Output "Function 1 executed"
            $menuOptions[1].Status = "Success"  # Update its own status
            return "Status updated to Success"
        }
        Status      = 'Pending'
    }
    2 = @{
        Shortcut    = '2'
        Name        = 'Option 2'
        Description = 'Run function 2 and update status'
        Function    = {
            param($menuOptions)
            Write-Output "Function 2 executed"
            $menuOptions[2].Status = "Completed"  # Update its own status
            return "Status updated to Completed"
        }
        Status      = 'Pending'
    }
    3 = @{
        Shortcut    = '3'
        Name        = 'Reset Status'
        Description = 'Reset status of all other options to Pending'
        Function    = {
            param($menuOptions)
            foreach ($key in $menuOptions.Keys) {
                $menuOptions[$key].Status = "Pending"
            }
            return "All statuses reset to Pending"
        }
        Status      = 'Pending'
    }
    'q' = @{
        Shortcut    = 'q'
        Name        = 'Quit'
        Description = 'Exit the menu'
        Function    = { Write-Output "Exiting menu" }
    }
}

Show-ConsoleMenu -Header "My PowerShell Console Menu" -MenuOptions $menuOptions
