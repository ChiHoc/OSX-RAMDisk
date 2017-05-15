install:
	cp Contents/MacOS/startupRAMDiskandCacheMover.sh /usr/local/bin/
	cp ./OSXRamDisk.plist ~/Library/LaunchAgents/
	[ -f ~/Library/LaunchAgents/OSXRamDisk.plist ] && launchctl load -w ~/Library/LaunchAgents/OSXRamDisk.plist

uninstall:
	launchctl unload -w ~/Library/LaunchAgents/OSXRamDisk.plist
	rm -f /usr/local/bin/startupRAMDiskandCacheMover.sh
	rm -f ~/Library/LaunchAgents/OSXRamDisk.plist
	rm -rf ~/Library/Developer/Xcode/DerivedData
	rm -rf ~/Library/Caches/AndroidStudio2.3
	rm -rf ~/Library/Caches/IntelliJIdea2017.1
	rm -rf ~/Library/Caches/com.apple.iTunes
	rm -rf ~/Library/Caches/com.apple.Safari
	rm -rf ~/Library/Caches/Google
	umount -f /Volumes/ramdisk
