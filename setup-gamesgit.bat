@echo off

if NOT EXIST "C:\Program Files\Git\bin\git.exe" (
	echo Git is not installed, please install 64-bit Git for Windows Setup
	echo "https://git-scm.com/download/win"
	echo After installing git close and open the console so this can find git
	explorer "https://git-scm.com/download/win"
	exit /b
)

ping gamesgit.falmouth.ac.uk -n 1 -4 | find /i "TTL=">nul
if %ERRORLEVEL% EQU 1 (
	echo Cannot reach gamesgit.falmouth.ac.uk, are you on the VPN?
	exit /b
)

set /p id="Enter University Username (example: AB112233): "

:: Initalise dir + files
echo File and directory initialisation
mkdir -p %UserProfile%\.ssh
type NUL >> "%UserProfile%\.ssh\known_hosts"
type NUL >> "%UserProfile%\.ssh\config"

:: Add to known hosts
echo Checking if GamesGit has been added to SSH hosts
call ssh-keygen -F gamesgit.falmouth.ac.uk
echo %errorlevel%
if %ERRORLEVEL% EQU 1 (
	ssh-keyscan gamesgit.falmouth.ac.uk >> "%UserProfile%\.ssh\known_hosts
	echo Adding GamesGit to SSH hosts
) else (
	echo Found GamesGit in SSH hosts so skipping
)

:: Generate new key pair
echo Checking if SSH key pair exists
if NOT EXIST "%UserProfile%\.ssh\gamesgit" (
	:: gamesgit gamesgit.pub
	echo Generating new SSH key pair
	ssh-keygen -N "" -t rsa -f "%UserProfile%\.ssh\gamesgit
) else (
	echo Found SSH key pair so skipping
)

:: Add t .ssh/config
echo Checking if SSH key is in the config
FINDSTR "gamesgit.falmouth.ac.uk" "%UserProfile%\.ssh\config"
echo %errorlevel%
if %ERRORLEVEL% EQU 1 (
	echo Adding SSH key to config
	echo Host gamesgit.falmouth.ac.uk >> %UserProfile%\.ssh\config
	echo IdentityFile %UserProfile%\.ssh\gamesgit >> %UserProfile%\.ssh\config
	echo User %id%@falmouth.ac.uk >> %UserProfile%\.ssh\config
) else (
	echo Found SSH key in config
)

echo Setting up global git config

:: This was checked and gamesgit converts the name to their real name fine with this
call git config --global user.name %id%
call git config --global user.email %id%@falmouth.ac.uk

echo Copied SSH public key to clipboard
set /p mytextfile=< %UserProfile%\.ssh\gamesgit.pub
echo|set/p=%mytextfile%|clip

echo Opening GamesGit SSH key adding site

explorer "https://gamesgit.falmouth.ac.uk/plugins/servlet/ssh/account/keys/add"


echo Finished!
