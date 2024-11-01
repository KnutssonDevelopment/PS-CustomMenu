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

        # Determine maximum lengths for formatting
        $maxNameLength = ($MenuOptions.Values | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum
        $maxDescriptionLength = ($MenuOptions.Values | ForEach-Object { $_.Description.Length } | Measure-Object -Maximum).Maximum
        $statusColumnStart = $maxNameLength + $maxDescriptionLength + 12  # Adjust for formatting

        # Display each menu option with indentation, shortcut, name, description, and optional status in order
        $previousIndentLevel = 0
        $menuKeys = $MenuOptions.Keys | Sort-Object  # Get sorted keys for ordered display

        for ($i = 0; $i -lt $menuKeys.Count; $i++) {
            $index = $menuKeys[$i]
            $option = $MenuOptions[$index]

            if ($option.ContainsKey('Type') -and $option.Type -eq 'Separator') {
                # Display separator line or text
                $indentation = " " * ($option['IndentLevel'] * 4)
                Write-Host "$indentation--- $($option.Text) ---" -ForegroundColor Gray
                continue
            }

            $shortcut = $option['Shortcut']
            $indentation = " " * ($option['IndentLevel'] * 4)  # 4 spaces per indent level
            $nameAndDescription = "[$shortcut] $($option.Name) - $($option.Description)"
            $paddingLength = $statusColumnStart - $nameAndDescription.Length - $indentation.Length
            $padding = if ($paddingLength -gt 0) { " " * $paddingLength } else { "" }
            $status = if ($option.ContainsKey('Status')) { "($($option.Status))" } else { "" }
            Write-Host "$indentation$nameAndDescription$padding$status"

            # Check if the next item has a lower indentation to add a space
            if ($i + 1 -lt $menuKeys.Count) {
                $nextIndentLevel = $MenuOptions[$menuKeys[$i + 1]].IndentLevel
                if ($nextIndentLevel -lt $option.IndentLevel) {
                    Write-Host ""  # Add a blank line for visual separation
                }
            }
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

# Example Usage with Indexed Menu Options, Indentation Levels, and a Separator
$menuOptions = @{
    1 = @{
        Shortcut    = '1'
        Name        = 'Main Option 1'
        Description = 'Run function 1 and update status'
        Function    = {
            param($menuOptions)
            Write-Output "Function 1 executed"
            $menuOptions[1].Status = "Success"  # Update its own status
            return "Status updated to Success"
        }
        Status      = 'Pending'
        IndentLevel = 0  # No indentation
    }
    2 = @{
        Shortcut    = '2'
        Name        = 'Sub Option 1'
        Description = 'Run function 2 and update status'
        Function    = {
            param($menuOptions)
            Write-Output "Function 2 executed"
            $menuOptions[2].Status = "Completed"  # Update its own status
            return "Status updated to Completed"
        }
        Status      = 'Pending'
        IndentLevel = 1  # Indented once
    }
    3 = @{
        Type        = 'Separator'
        Text        = 'Section Divider'
        IndentLevel = 0  # No indentation
    }
    4 = @{
        Shortcut    = '3'
        Name        = 'Reset Status'
        Description = 'Reset status of all other options to Pending'
        Function    = {
            param($menuOptions)
            foreach ($key in $menuOptions.Keys) {
                if ($menuOptions[$key].ContainsKey('Status')) {
                    $menuOptions[$key].Status = "Pending"
                }
            }
            return "All statuses reset to Pending"
        }
        IndentLevel = 0  # No indentation
    }
    'q' = @{
        Shortcut    = 'q'
        Name        = 'Quit'
        Description = 'Exit the menu'
        Function    = { Write-Output "Exiting menu" }
        IndentLevel = 0  # No indentation
    }
}

Show-ConsoleMenu -Header "My PowerShell Console Menu" -MenuOptions $menuOptions
