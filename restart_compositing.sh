#!/bin/bash
#
# OpenGL compositing usually crashes KWin when I login, and compositing is then disabled.
# I have to select 'System Settings' > 'Display and Monitor' > 'Compositor' and perform
# the following steps to get compositing to work in the session:
#
# 1. click 'Re-enable OpenGL detection'
# 2. deselect 'Enable compositor on startup'
# 3. click 'Apply'
# 4. select  'Enable compositor on startup'
# 5. click 'Apply
#
# This script enables me to avoid having to perform the above manual procedure.
# This script is configured to run automatically at Plasma Startup - see:
# 'System Settings' > 'Startup and Shutdown' > 'Autostart'
#
edit_kwinrc () {
                # Extract the [Compositing] section from kwinrc
                awk '/\[Compositing\]/,/^$/' $HOME/.config/kwinrc > /tmp/kwinrc-extract
                # Remove the header in the extracted section
                sed -i '/\[Compositing\]/d' /tmp/kwinrc-extract
                # Remove the empty line at the end of the extracted section
                sed -i '/^$/d' /tmp/kwinrc-extract
                # Change the state configured for next login
                if [ $1 == "disablecompositing" ]; then
                    sed -i 's/Enabled=true/Enabled=false/g' /tmp/kwinrc-extract
                elif [ $1 == "enablecompositing" ]; then
                    sed -i 's/Enabled=false/Enabled=true/g' /tmp/kwinrc-extract
                elif [ $1 == "openglunsafe" ]; then
                    sed -i 's/OpenGLIsUnsafe=false/OpenGLIsUnsafe=true/g' /tmp/kwinrc-extract
                elif [ $1 == "openglsafe" ]; then
                    sed -i 's/OpenGLIsUnsafe=true/OpenGLIsUnsafe=false/g' /tmp/kwinrc-extract
                fi
                # Replace the [Compositing] section in kwinrc
                awk 'BEGIN {p=1} /^\[Compositing\]/ {print;system("cat /tmp/kwinrc-extract");p=0} /^$/ {p=1} p' $HOME/.config/kwinrc > /tmp/kwinrc
                cp /tmp/kwinrc $HOME/.config/kwinrc
}
#
# Avoid backing up an incorrectly-edited file
if [ ! -f $HOME/.config/kwinrc.bak ]; then
    cp $HOME/.config/kwinrc $HOME/.config/kwinrc.bak
fi
#
sleep 120s # This delay works for my specific laptop but might need to be adjusted on other machines.
if $( grep -q "OpenGLIsUnsafe=true" $HOME/.config/kwinrc ); then
    edit_kwinrc openglsafe
    edit_kwinrc enablecompositing # Just in case it was disabled as well.
    kwin_x11 --replace & > /dev/null 2>&1
fi
exit 0

