# ffxivlauncherlogin
Uses AutoHotkey to automate the login process from desktop to in-game just by starting the script.

---DOES NOT WORK WITH ONE-TIME PASSWORDS---

Requires AHK v2 to be downloaded. (find at https://www.autohotkey.com)

In order you use this you must input your local directory to the launcher exe file, and input the password for your account.
This is very easy to do.

1. Right click on the script.
2. Open with -> Notepad
3. Edit the text on **line 1** that specifies the directory to your launcher's file in your PC. Place this directory inside the double quotation marks (there is an example directory present - replace that with your directory).
        a. The file you're looking for is called 'ffxivboot.exe'. Ensure the directory you have provided begins with the drive that the file is stored on ("C:\...") and ends with the ffxivboot.exe launcher ("...ffxivboot.exe").
4. Add your password **on line 2** into the middle of the double quotation marks provided. This password is locally stored only in the script file, and that information and this script do not communicate with the internet.
