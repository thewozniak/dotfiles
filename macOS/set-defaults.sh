#!/bin/sh

# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `set-default.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Clear terminal and display information
clear
echo -e "\n\n"
text="Setting up you Mac..."
tput setaf 0 
tput bold
for (( i=0; i<15; i++ )); do
  echo -n "${text:$i:1}"
  sleep 0.05
done
tput sgr0
tput setaf 6 
tput bold
for (( i=15; i<18; i++ )); do
  echo -n "${text:$i:1}"
  sleep 0.05
done
tput sgr0
for (( i=18; i<${#text}; i++ )); do
  echo -n "${text:$i:1}"
  sleep 0.05
done
echo -e "\n"
sleep 1

# Setting up computer name
computer_name=$(system_profiler SPHardwareDataType | awk '/Model Name/ {print $3$4}')
# Check if the computer name is Macmini, MacBookPro, MacStudio or MacPro
case "$computer_name" in
  "Macmini")
    computer_name="Mac mini"
    ;;
  "MacBookAir"|"MacBookPro")
    computer_name="MacBook"
    ;;
  "MacStudio")
    computer_name="Mac Studio"
    ;;
  "MacPro")
    computer_name="Mac Pro"
    ;;             
esac

echo -e "[\033[1m\033[34mSetting up\033[0m\033[0m] computer name: \033[1m$computer_name\033[0m"
sudo scutil --set ComputerName "$computer_name"

# Replace any spaces in the computer name with hyphens
local_host_name=${computer_name// /-}
# Hostname - change to lowercase letters
host_name=$(echo "$local_host_name" | tr '[:upper:]' '[:lower:]')

# Set the local host name
echo -e "[\033[1m\033[35mSetting up\033[0m\033[0m] localhost name: \033[1m$local_host_name\033[0m"
sudo scutil --set LocalHostName $local_host_name

# Set the hostname
echo -e "[\033[1m\033[33mSetting up\033[0m\033[0m] hostname: \033[1m$host_name\033[0m"
sudo scutil --set HostName $host_name

# Ask the user to choose the appearance
echo -e "[\033[1m\033[36mSetting up\033[0m\033[0m] appearance to: Light "
defaults write -g "AppleInterfaceStyle" "Light"

#######################################################################
# Regional Settsings & Language (System Preferences → General)
#######################################################################

echo -e "[\033[1mSetting up\033[0m] clock settings..."

# Show the clock in the menu bar with seconds
defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock DateFormat -string "HH:mm:ss"
defaults write com.apple.menuextra.clock ShowSeconds -bool true

# Flash the date separators
defaults write com.apple.menuextra.clock FlashDateSeparators -bool true

# Show 24-hour time instead of 12-hour
defaults write com.apple.menuextra.clock "24HourTime" -bool true

# Do not show language menu in the top right corner of the boot screen
sudo defaults write /Library/Preferences/com.apple.loginwindow showInputMenu -bool false

#######################################################################
# Software Updates (System Preferences → General → Updates)
#######################################################################

echo -e "[\033[1m\033[34mSetting up\033[0m\033[0m] software updates settings..."

# Enable automatic checking for updates
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Disable automatic download and installation of updates
defaults write com.apple.SoftwareUpdate AutomaticDownload -bool false
defaults write com.apple.SoftwareUpdate AutomaticInstallMacOSUpdates -bool false
defaults write com.apple.SoftwareUpdate AutomaticAppUpdates -bool false

# Enable automatic installation of security responses and system files
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -bool true

#######################################################################
# AirDrop & Handoff (System Preferences → General → AirDrop)
#######################################################################

echo -e "[\033[1m\033[35mSetting up\033[0m\033[0m] Handoff & AirDrop settings..."

# Enable Handoff
defaults write com.apple.coreservices.useractivityd ActivityAdvertisingAllowed -bool true

# Set AirDrop to Contacts Only
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool false

#######################################################################
# Time Machine (System Preferences → General → Time Machine)
#######################################################################

echo -e "[\033[1m\033[33mSetting up\033[0m\033[0m] Time Machine settings..."

# Prevent Time Machine from prompting to use new hard drives as a backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

#######################################################################
# Finder and Appearance (System Preferences → Appearance)
#######################################################################

echo -e "[\033[1m\033[36mSetting up\033[0m\033[0m] Finder settings..."

# Show hard drives on the desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

# Use icons view in all Finder windows by default
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`, `Nlsv`
defaults write com.apple.finder FXPreferredViewStyle -string "icnv"

# Set new Finder windows to show the Computer view
defaults write com.apple.finder NewWindowTarget -string "PfCm"

# Change the width of the Finder sidebar
defaults write com.apple.finder SidebarWidth -int 210

# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Add the "Desktop" folder to the Finder sidebar
defaults write com.apple.finder ShowDesktop -bool true

# Add the "Documents" folder to the Finder sidebar
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

# Hide the "Recents" folder from the Finder sidebar
defaults write com.apple.finder ShowRecentTags -bool false

# Disable sidebar recent tags
defaults write com.apple.Finder ShowRecentTags -bool false

# Allow text selection in Quick Look
defaults write com.apple.finder QLEnableTextSelection -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Don't show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool false

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Show the path bar in Finder windows
defaults write com.apple.finder ShowPathbar -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Remove duplicates in the "Open With" menu
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# Enable snap-to-grid for icons on the desktop and arranbe by kind in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy kind" ~/Library/Preferences/com.apple.finder.plist

# Show the ~/Library folder
chflags nohidden ~/Library

# Expand the following File Info panes:
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

#######################################################################
# Control Center Appearance (System Preferences → Control Center)
#######################################################################

# Show the Wi-Fi icon in the Menu Bar
defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/AirPort.menu"

# Show the Bluetooth icon in the Menu Bar
defaults write com.apple.systemuiserver menuExtras -array-add "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"

#######################################################################
# Siri & Spotlight (System Preferences → Siri & Spotlight)
#######################################################################

echo -e "[\033[1mSetting up\033[0m] Siri & Spotlight settings..."

# Disable Ask Siri
defaults write com.apple.Siri StatusMenuVisible -bool false

# Enable Applications, System Preferences, Directories, Developer, Documents, and Fonts search results in Spotlight
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 1;"name" = "APPLICATIONS";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 1;"name" = "SYSTEM_PREFS";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 1;"name" = "DIRECTORIES";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 1;"name" = "DOCUMENTS";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 1;"name" = "FONTS";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "PDF";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "MESSAGES";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "CONTACT";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "EVENT_TODO";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "IMAGES";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "BOOKMARKS";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "MUSIC";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "MOVIES";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "PRESENTATIONS";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "SPREADSHEETS";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "SOURCE";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "MENU_DEFINITION";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "MENU_OTHER";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "MENU_CONVERSION";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "MENU_EXPRESSION";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}'
defaults write com.apple.spotlight orderedItems -array '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

# Load new settings before rebuilding the index
killall mds > /dev/null 2>&1

# Make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null

# Rebuild the index from scratch
sudo mdutil -E / > /dev/null

#######################################################################
# Privacy & Security (System Preferences → Privacy & Security)
#######################################################################

echo -e "[\033[1m\033[34mSetting up\033[0m\033[0m] Privacy & Security settings..."

# Allow applications to be downloaded from the App Store and identified developers
sudo spctl --master-enable

# Prevent Photos from opening automatically when devices are plugged in
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

#######################################################################
# Lock Screen (System Preferences → Lock Screen)
#######################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Don't allow to login as a guest
sudo defaults write /Library/Preferences/com.apple.loginwindow.plist GuestEnabled -bool false

# Sleep the display after 10 minutes
sudo pmset -a displaysleep 10

#######################################################################
# Desktop & Dock (System Preferences → Desktop & Dock)
#######################################################################

echo -e "[\033[1m\033[35mSetting up\033[0m\033[0m] Desktop & Dock..."

# Change the position of the Dock to the bottom of the screen
defaults write com.apple.dock orientation -string bottom

# Change the minimize window effect to the scale effect
defaults write com.apple.dock mineffect -string scale

# Change the behavior of minimizing windows to minimize them into the application icon
defaults write com.apple.dock minimize-to-application -bool true

# Enable animations when opening apps
defaults write com.apple.dock launchanim -bool true

# Show indicators for open apps
defaults write com.apple.dock show-process-indicators -bool true

# Disable the display of recent apps in the Dock
defaults write com.apple.dock show-recents -bool false

# Minimize on double click
defaults write -g AppleMiniaturizeOnDoubleClick -bool true

# Prevent the menu bar from automatically hiding and showing
defaults write NSGlobalDomain _HIHideMenuBar -bool false

# Disable the recent apps section in the Dock
defaults write com.apple.dock show-recents -bool false

# Set the Launchpad to have 9 columns and 7 rows
defaults write com.apple.dock springboard-columns -int 9
defaults write com.apple.dock springboard-rows -int 7

# Set the size of the icons in the Dock to 44 pixels
defaults write com.apple.dock tilesize -int 44

#######################################################################
# Displays
#######################################################################

echo -e "[\033[1m\033[33mSetting up\033[0m\033[0m] Displays settings..."

# Enable HiDPI display modes
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

# Enable subpixel font rendering on non-Apple LCDs
# Reference: https://github.com/kevinSuttle/macOS-Defaults/issues/17#issuecomment-266633501
defaults write NSGlobalDomain AppleFontSmoothing -int 1

#######################################################################
# Energy Saver (System Preferences → Energy Saver)
#######################################################################

echo -e "[\033[1m\033[36mSetting up\033[0m\033[0m] Energy Saver settings..."

# Check if the computer is a laptop
if [[ $(system_profiler SPHardwareDataType | awk '/Model Name/ {print $3}') == 'MacBook' ]]; then

    # Menu bar: show battery percentage
    defaults write com.apple.menuextra.battery ShowPercent YES

    # Enable lid wakeup (macbooks)
    sudo pmset -a lidwake 1

    # Disable machine sleep while charging (macbooks)
    sudo pmset -c sleep 0

    # Set machine sleep to 5 minutes on battery (macbooks)
    sudo pmset -b sleep 5 

fi

# Enable waking up from network access
sudo pmset -a womp 1

# Restart automatically on power loss
sudo pmset -a autorestart 1

# Hibernation mode
# 0: Disable hibernation (speeds up entering sleep mode)
# 3: Copy RAM to disk so the system state can still be restored in case of a
#    power failure.
sudo pmset -a hibernatemode 0

# Disable the sudden motion sensor as it’s not useful for SSDs
sudo pmset -a sms 0

#######################################################################
# Keyboard (System Preferences → Keyboard)
#######################################################################

# Add the keyboard shortcut ⌘ + Enter to send an email in Mail.app
defaults write com.apple.mail NSUserKeyEquivalents -dict-add "Send" "@\U21a9"

# Stop iTunes from responding to the keyboard media keys
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

# Disable smart quotes and dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

#######################################################################
# Mouse (System Preferences → Mouse)
#######################################################################

echo -e "[\033[1mSetting up\033[0m] Mouse settings..."

# Enable the secondary (right) click on a Magic Mouse (System Preferences → Mouse)
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode TwoButton

# Enable natural scrolling for a Magic Mouse (System Preferences → Mouse)
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# Disable swipe between pages for a Magic Mouse
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseOneFingerVertSwipeGesture -int 0

# Enable swipe between screens for a Magic Mouse
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseTwoFingerHorizSwipeGesture -int 2

# Enable double tap to show Mission Control for a Magic Mouse
defaults write com.apple.driver.AppleBluetoothMultitouch.mouse MouseTwoFingerDoubleTapGesture -int 2

# Set mouse tracking speed
defaults write -g com.apple.mouse.scaling 1.25

#######################################################################
# Printers
#######################################################################

# Automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

#######################################################################
# Safari & WebKit  
#######################################################################

echo -e "[\033[1m\033[34mSetting up\033[0m\033[0m] Safari & WebKit settings..."

# Privacy: don’t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Disable the thumbnail cache for History
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Disable the thumbnail cache for Top Sites
defaults write com.apple.Safari PreloadTopHit -bool false

# Enable Safari’s debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

#######################################################################
# Others
#######################################################################

echo -e "[\033[1m\033[35mSetting up\033[0m\033[0m] other essentials settings..."

# File System Access
sudo defaults write com.apple.AppleFileServer guestAccess -bool false
sudo defaults write SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool false

# Save screenshots to the $HOME/Screenshots
mkdir $HOME/Screenshots
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Enable audio feedback when volume is changed
defaults write com.apple.sound.beep.feedback -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"
# Possible values: `WhenScrolling`, `Automatic` and `Always`

# Disable the over-the-top focus ring animation
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false

# Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

#######################################################################
# Xcode-command-line
#######################################################################

# Check if Xcode is already installed
echo -e "\n[\033[1m\033[33mChecking up\033[0m\033[0m] Xcode command-line tools..."
if test ! $(which xcode-select); then
  # Xcode is not installed
  echo -e "\n[\033[1m\033[31mnot found\033[0m\033[0m] \033[1minstallation is recommended\033[0m"
  sleep 2
  # Install Xcode command-line tools
  echo -e "\033[1m\033[36m==>\033[0m\033[0m \033[1mlaunching:\033[0m \033[4m\033[3mxcode-select --install\033[0m\033[0m\n"
  sleep 2  
  xcode-select --install
else
  # Xcode is already installed
  # No action needed
  echo "\033[1m\033[36m==>\033[0m\033[0m Xcode is \033[4malready installed\033[0m. \033[1mSkipping...\033[0m"
fi

# Done!

# Display information about the need to restart the machine
echo -e "\n[\033[1m\033[32mDONE\033[0m\033[0m] \033[1mNote that some of these changes require a restart to take effect.\033[0m\n\n"
