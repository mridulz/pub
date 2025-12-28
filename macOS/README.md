
#### General


```shell
    # Reset macOS Terminal
    rm ~/Library/Preferences/com.apple.Terminal.plist

	# Get Current Font Smoothing settings
	defaults -currentHost read -g AppleFontSmoothing

	0: Font smoothing is off.
	1: Light font smoothing.
	2: Medium font smoothing (the default).
	3: Strong font smoothing.

	# Change Font smoothing settings to light
	defaults -currentHost write -g AppleFontSmoothing -int 1

	# Change default location for saving screenshots
	defaults write com.apple.screencapture location ~/Desktop/Screenshots
    
    # Change the default filename Prefix for Screenshots
    defaults write com.apple.screencapture name Capture
    
    # Enable key repeats
    defaults write -g ApplePressAndHoldEnabled -bool false

    # Enable three finger drag
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

    # Disable prompting to use new exteral drives as Time Machine volume
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    # Hide external hard drives on desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false

    # Hide hard drives on desktop
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

    # Hide removable media hard drives on desktop
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

    # Hide mounted servers on desktop
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

    # Hide icons on desktop
    defaults write com.apple.finder CreateDesktop -bool false

    # Avoid creating .DS_Store files on network volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Show hidden files inside the finder
    defaults write com.apple.finder "AppleShowAllFiles" -bool true

    # Show Status Bar
    defaults write com.apple.finder "ShowStatusBar" -bool true

    # Do not show warning when changing the file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"

    # Set weekly software update checks
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 7

    # Spaces span all displays
    defaults write com.apple.spaces "spans-displays" -bool false

    # Do not rearrange spaces automatically
    defaults write com.apple.dock "mru-spaces" -bool false

    # Set Dock autohide
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock largesize -float 128
    defaults write com.apple.dock "minimize-to-application" -bool true
    defaults write com.apple.dock tilesize -float 32

    # Rectangle
    defaults write com.knollsoft.Rectangle curtainChangeSize -int 2
    defaults write com.knollsoft.Rectangle almostMaximizeHeight -float 1
    defaults write com.knollsoft.Rectangle almostMaximizeWidth -float 0.85

    # Rectangle custom window size with Shift + Alt + Ctrl + Cmd + N
    defaults write com.knollsoft.Rectangle specified -dict-add keyCode -float 45 modifierFlags -float 1966379
    defaults write com.knollsoft.Rectangle specifiedHeight -float 1055
    defaults write com.knollsoft.Rectangle specifiedWidth -float 1876

```

#### Get CPU Exact Model and Total Threads
```shell
sysctl -a | grep machdep.cpu.brand_string | sed 's/^.*: //'; sysctl -a | grep machdep.cpu.thread_count | sed 's/^.*: //'

```

#### Spotlight ReIndexing
```shell
sudo su -

mdutil -E /

launchctl load -w /System/Library/LaunchDaemons/com.apple.metadata.mds.plist
```

#### Change Hostname
```shell
sudo su -
export new_hostname=
scutil --set HostName $new_hostname
scutil --set ComputerName $new_hostname
scutil --set LocalHostName $new_hostname

```

#### Generate QR Code for WiFi

```shell
brew install qrencode

qrencode -o ~/Desktop/MyWiFi_QR_Code.png "WIFI:T:WPA;S:MySSID;P:MyPassword;;"
```


