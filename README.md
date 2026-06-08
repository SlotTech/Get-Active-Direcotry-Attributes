Authenticates: It logs into the Microsoft Graph PowerShell SDK securely using a certificate and application ID loaded from an external file (connection-lib.ps1).
Reads Input: It prompts you to enter the name of a CSV file (which must contain a column header named upn). It expects this file to be in the exact same folder as the script.
Fetches Data: It loops through each user email, tracks the overall progress visually in the console using cyan text, and pulls three specific synced on-premises fields: extensionAttribute2, extensionAttribute4, and extensionAttribute14.
Handles Errors: If it cannot find a user or lacks permissions for a specific account, it throws a yellow warning message but keeps moving down the list instead of crashing.
Exports Results: Once finished, it creates a brand new spreadsheet in the same folder named Extension_Attributes_Output.csv containing the UPN, Display Name, and the three custom attributes for every successfully processed user.
