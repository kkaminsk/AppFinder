# AppFinder

Easily search for an application and get the necessary information such as Uninstall String, Version, Publisher, and Install location without having to search in the registry manually. 

Originally written by Marin Alexandruradu. This is a fork by Kevin Kaminski to add some extra functionality.

## Requirements
Run this code with PowerShell 5.

## Features

- GUI-based application search
- Console mode for quick searches
- Retrieves information from Windows registry
- Copy search results to clipboard
- Open search results in Notepad
- Uninstall applications directly from the tool

## Usage

### GUI Mode

1. Run the `AppFinder.ps1` script in PowerShell.
2. Enter the application name or partial name in the text box.
3. Click the "Search" button or press Enter to perform the search.
4. View the results in the output text box.
5. Use the "Copy" button to copy results to clipboard or "Notepad" to open results in Notepad.
6. Click the "Uninstall" button to uninstall the selected application. If multiple uninstall strings are available, you'll be prompted to choose one.

![AppFinderOneSearch](https://github.com/kkaminsk/AppFinder/blob/main/docs/assets/1.gif?raw=true)

![AppFinderOutput](https://github.com/kkaminsk/AppFinder/blob/main/docs/assets/2.gif?raw=true)

### Console Mode

Run the script from the command line to perform a quick search and then launch the GUI:

```powershell
powershell -ExecutionPolicy Bypass -File .\AppFinder.ps1
```

When run in console mode, the script will prompt you to enter an application name to search for. After performing the search, it will display the results in the console and then launch the GUI for further use.

## PowerShell Script Overview

The `AppFinder.ps1` script includes the following main components:

1. GUI creation using Windows Forms
2. Search function that queries the Windows registry
3. Error handling and logging
4. Console mode for command-line usage

The script searches the following registry paths for installed applications:
- `HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall`
- `HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall`
- `HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall`

## Requirements

- Windows operating system
- PowerShell 5.1 or later

## Known Issues

1. There's an unexpected "0 0" output at the beginning of the script execution. This doesn't affect the core functionality but may be confusing for users. We're investigating this issue for future improvements.

2. The uninstall feature executes the uninstall string as-is. Some applications may require elevated privileges or have silent install options. Users may need to modify the uninstall string manually in some cases.

## Security Note

The uninstall feature executes commands based on the information stored in the Windows registry. Always verify the uninstall string before proceeding with the uninstallation process.

## Contributing

Contributions to improve AppFinder are welcome. Please feel free to submit pull requests or create issues for bugs and feature requests.

## License

This project is open-source and available under the [MIT License](LICENSE).
