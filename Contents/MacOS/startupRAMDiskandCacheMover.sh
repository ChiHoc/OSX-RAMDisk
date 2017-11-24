#!/usr/bin/env bash -x

#
# Copyright Zafar Khaydarov
#
# This is about to create a RAM disk in OS X and move the apps caches into it
# to increase performance of those apps. Performance gain is very significant,
# particularly for browsers and especially for IDEs like IntelliJ Idea.
#
# Drawbacks and risks are that if RAM disk becomes full - performance will degrade
# significantly - huge amount of paging will happen.
#
# USE AT YOUR OWN RISK. PLEASE NOTE IT WILL NOT CHECK FOR CORRUPTED FILES
# IF YOUR RAM IS BROKEN - DO NOT USE IT.
#

# The RAM amount you want to allocate for RAM disk. One of
# 1024 2048 3072 4096 5120 6144 7168 8192
# By default will use 1/4 of your RAM

ramfs_size_mb=$(sysctl hw.memsize | awk '{print $2;}')
ramfs_size_mb=$((${ramfs_size_mb} / 1024 / 1024 / 4))

ramfs_size_sectors=$((${ramfs_size_mb}*1024*1024/512))
ramdisk_device=`hdid -nomount ram://${ramfs_size_sectors}`

USERRAMDISK="/Volumes/ramdisk"

#
# Closes passed as arg app by name
#
close_app()
{
    osascript -e "quit app \"${1}\""
}

# Open an application
open_app()
{
    osascript -e "tell app \"${1}\" to activate"
}

#
# Creates RAM Disk.
#
mk_ram_disk()
{
    diskutil eraseVolume HFS+ 'ramdisk' ${ramdisk_device}

    echo "created RAM disk."
}

# ------------------------------------------------------
# Applications, which needs the cache to be moved to RAM
# Add yours at the end.
# -------------------------------------------------------


#
# Move Cache
#
move_cache()
{
    rm -rf /tmp/$2
    mkdir -p /tmp/$2
    mv $1/* /tmp/$2 
    mkdir -p ${USERRAMDISK}/$2
    mv /tmp/$2/* ${USERRAMDISK}/$2
    rm -rf $1
    ln -s ${USERRAMDISK}/$2 $1
    rm -rf /tmp/$2
}


#
# Google Chrome Cache
#
move_chrome_cache()
{
    if [ -d "/Applications/Google Chrome.app" ]; then
        close_app "Google Chrome"
        move_cache ~/Library/Caches/Google Google
        # and let's create a flag for next run that we moved the cache.
        echo "Moved Chrome cache.";
    fi
}

#
# Safari Cache
#
move_safari_cache()
{
    close_app "Safari"
    move_cache ~/Library/Caches/com.apple.Safari Safari
    echo "Moved Safari cache."
}

#
# iTunes Cache
#
move_itunes_cache()
{
    close_app "iTunes"
    move_cache ~/Library/Caches/com.apple.iTunes iTunes
    echo "Moved iTunes cache."
}

#
# Intellij Idea
#
move_idea_cache()
{
    if [ -d "/Applications/IntelliJ IDEA.app" ]; then
        close_app "IntelliJ Idea"
        cacheDir=`/usr/libexec/PlistBuddy -c 'print JVMOptions:Properties:idea.paths.selector' '/Applications/IntelliJ IDEA.app/Contents/Info.plist'`
        move_cache ~/Library/Caches/${cacheDir} ${cacheDir}
        echo "Moved IntelliJ cache."
    fi
}

#
# Intellij PhpStorm
#
move_phpstorm_cache()
{
    if [ -d "/Applications/PhpStorm.app" ]; then
        close_app "PhpStorm"
        cacheDir=`/usr/libexec/PlistBuddy -c 'print JVMOptions:Properties:idea.paths.selector' '/Applications/PhpStorm.app/Contents/Info.plist'`
        move_cache ~/Library/Caches/${cacheDir} ${cacheDir}
        echo "Moved PhpStorm cache."
    fi
}

#
# Android Studio
#
move_android_studio_cache()
{
    if [ -d "/Applications/Android Studio.app" ]; then
        echo "moving Android Studio cache";
        close_app "Android Studio"
        cacheDir=`/usr/libexec/PlistBuddy -c 'print JVMOptions:Properties:idea.paths.selector' '/Applications/Android Studio.app/Contents/Info.plist'`
        move_cache ~/Library/Caches/${cacheDir} ${cacheDir}
        echo "Moved Android cache."
    fi
}

#
# Xcode - ios
#
move_xcode_cache()
{
    if [ -d "/Applications/Xcode.app" ]; then
        close_app "Xcode"
        move_cache ~/Library/Developer/Xcode/DerivedData Xcode/DerivedData
        echo "Moved Xcode cache."
    fi
}

# -----------------------------------------------------------------------------------
# The entry point
# -----------------------------------------------------------------------------------
main() {
    # and create our RAM disk
    mk_ram_disk
    move_chrome_cache
    move_safari_cache
    move_idea_cache
    move_phpstorm_cache
    move_itunes_cache
    move_android_studio_cache
    move_xcode_cache
    echo "All good - I have done my job. Your apps should fly."
}

main "$@"
# -----------------------------------------------------------------------------------
