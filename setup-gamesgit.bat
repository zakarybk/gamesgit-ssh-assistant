@echo off

set keygenPath = ""
set keyscanPath = ""
set gitPath = ""

if NOT EXIST "C:\Program Files\Git\bin\git.exe" (
	echo Git is not installed, please install 64-bit Git for Windows Setup
	echo "https://git-scm.com/download/win"
	echo After installing git close and open the console so this can find git
	explorer "https://git-scm.com/download/win"
	pause
	exit /b
)

:: Check for git PATH - above verifies if git.exe exists
where git > temp.txt

if %ERRORLEVEL% EQU 0 (
	set /p gitPath=< temp.txt
) else (
	set gitPath=C:\Program Files\Git\bin\git.exe
	echo WARNING git is not set on the PATH!
)

:: Check for keyscan PATH
where ssh-keyscan > temp.txt

if %ERRORLEVEL% EQU 0 (
	set /p keyscanPath=< temp.txt
) else (
	set keyscanPath=C:\Program Files\Git\usr\bin\ssh-keyscan.exe
)

if NOT EXIST "%keyscanPath%" (
	echo ssh-keyscan not found on PATH or installation directory!
	echo Make sure it was installed with https://git-scm.com/download/win
	del temp.txt
	pause
	exit
)

:: Check for keygen PATH
where ssh-keygen > temp.txt

if %ERRORLEVEL% EQU 0 (
	set /p keygenPath=< temp.txt
) else (
	set keygenPath=C:\Program Files\Git\usr\bin\ssh-keygen.exe
)

if NOT EXIST "%keygenPath%" (
	echo ssh-keygen not found on PATH or installation directory!
	echo Make sure it was installed with https://git-scm.com/download/win
	del temp.txt
	pause
	exit
)

:: Creating startup for allow Tortoise git etc to use SSH keys
if NOT EXIST "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\ssh.bat" (
	echo setx HOME "%UserProfile%" >> "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\ssh.bat"
	echo setx GIT_SSH "C:\Program Files\Git\usr\bin\ssh.exe" >> "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\ssh.bat"
	echo CALL "C:\Program Files\Git\cmd\start-ssh-agent.cmd" >> "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\ssh.bat"
	echo SETX SSH_AUTH_SOCK "%SSH_AUTH_SOCK%" >> "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\ssh.bat"
	echo SETX SSH_AGENT_PID "%SSH_AGENT_PID%" >> "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\ssh.bat"
	echo exit >> "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\ssh.bat"
	
	setx HOME "%UserProfile%"
	setx GIT_SSH "C:\Program Files\Git\usr\bin\ssh.exe"
	CALL "C:\Program Files\Git\cmd\start-ssh-agent.cmd"
	SETX SSH_AUTH_SOCK "%SSH_AUTH_SOCK%"
	SETX SSH_AGENT_PID "%SSH_AGENT_PID%"
)

:: Check for VPN connection
ping gamesgit.falmouth.ac.uk -n 1 -4 | find /i "TTL=">nul
if %ERRORLEVEL% EQU 1 (
	echo Cannot reach gamesgit.falmouth.ac.uk, are you on the VPN?
	echo Get the VPN at https://learningspace.falmouth.ac.uk/course/view.php?id=3301
	pause
	exit /b
)

:GetUsername
set /p id="Enter University Username (example: AB112233): "
echo Is "%id%" correct and contain no spaces?
echo This would make your email %id%@falmouth.ac.uk, does that look right?

set /p confirmed="y/n: "
if NOT "%confirmed%" == "y" GOTO GetUsername

:: Initalise dir + files
echo File and directory initialisation
mkdir %UserProfile%\.ssh
type NUL >> "%UserProfile%\.ssh\known_hosts"
type NUL >> "%UserProfile%\.ssh\config"

:: Add to known hosts
echo Checking if GamesGit has been added to SSH hosts
call "%keygenPath%" -F gamesgit.falmouth.ac.uk
echo %errorlevel%
if %ERRORLEVEL% EQU 1 (
	%keyscanPath% gamesgit.falmouth.ac.uk >> "%UserProfile%\.ssh\known_hosts
	echo Adding GamesGit to SSH hosts
) else (
	echo Found GamesGit in SSH hosts so skipping
)

:: Generate new key pair
echo Checking if SSH key pair exists
if NOT EXIST "%UserProfile%\.ssh\gamesgit" (
	:: gamesgit gamesgit.pub
	echo Generating new SSH key pair
	"%keygenPath%" -N "" -t rsa -f "%UserProfile%\.ssh\gamesgit"
) else (
	echo Found SSH key pair so skipping
)

:: Add t .ssh/config
echo Checking if SSH key is in the config
FINDSTR "gamesgit.falmouth.ac.uk" "%UserProfile%\.ssh\config"
echo %errorlevel%
if %ERRORLEVEL% EQU 1 (
	echo Adding SSH key to config
	echo Host gamesgit.falmouth.ac.uk >> "%UserProfile%\.ssh\config"
	echo IdentityFile %UserProfile%\.ssh\gamesgit >> "%UserProfile%\.ssh\config"
	echo User %id%@falmouth.ac.uk >> "%UserProfile%\.ssh\config"
) else (
	echo Found SSH key in config
)

echo Setting up global git config

:: This was checked and gamesgit converts the name to their real name fine with this
call "%gitPath%" config --global user.name %id%
call "%gitPath%" config --global user.email %id%@falmouth.ac.uk

echo Copied SSH public key to clipboard
set /p mytextfile=< "%UserProfile%\.ssh\gamesgit.pub"
echo|set/p=%mytextfile%|clip

echo Opening GamesGit SSH key adding site https://gamesgit.falmouth.ac.uk/plugins/servlet/ssh/account/keys/add
explorer "https://gamesgit.falmouth.ac.uk/plugins/servlet/ssh/account/keys/add"

echo Finished! (press control + v to paste your key into the website)
echo Don't forget to change the SSH client in tortoise git/your version control software!
del temp.txt
pause
