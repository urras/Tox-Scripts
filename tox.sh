#!/bin/bash
##  wget -O tox.sh waa.ai/iqt && chmod +x ./tox.sh && ./tox.sh
## ./tox.sh -sl         to skip libsodium (they don't update that often)
## ./tox.sh -sd         to skip libsodium and all the other dependencies

## If libraries are missing, remove /etc/ld.so.conf.d/locallib.conf and
##    try running again. Else, try messing around with the prefix paths.
## Suggestions, comments and the alike are welcome on http://waa.ai/4vsk
##    or send me a mail, to    notadecent  AT  tox  DOT  im

upd=2014/08/10      # Date this script was updated
com="moved to github.com/Tox/tox-scripts and updated some stuff, \
    gentoo users should investigate the overlay before applying"


# Check if script is being ran as root
test "$(whoami)" == 'root' && (echo "[tox.sh] Please don't run this \
script as root"; exit 1)

# Check for arguments
nolibsm=0
nodep=0
[ "$1" == '-sl' ]   && nolibsm=1
[ "$1" == '-sd' ]   && nodep=1
[ "$nodep" == "1" ] && nolibsm=1

# Prompt installation
echo last updated $upd
echo comment: $com
while true; do
    read -p "continue? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "answer yes or no";;
    esac
done

# Clear update directory
sudo rm -rf /tmp/tox-update/
sudo rm /usr/share/applications/venom.desktop
mkdir -p /tmp/tox-update/
cd /tmp/tox-update/

# libsodium with checkinstall
getlibsodium() {
  git clone https://github.com/jedisct1/libsodium.git
  cd libsodium
  autoreconf -if
  ./autogen.sh
  ./configure --prefix=/usr/local/
  yes "" | sudo checkinstall --install --pkgname libsodium --pkgversion 0.5.0 --nodoc
  sudo /sbin/ldconfig
  cd ..
}

# libsodium without checkinstall
getlibsodiumnc() {
  git clone https://github.com/jedisct1/libsodium.git
  cd libsodium
  git checkout tags/0.5.0
  ./autogen.sh
  ./configure --prefix=/usr/local/
  make check
  make
  sudo make install
  sudo /sbin/ldconfig
  cd ..
}

# toxcore
gettoxcore() {
  git clone https://github.com/irungentoo/ProjectTox-Core.git
  cd ProjectTox-Core
  autoreconf -if
  ./configure --prefix=/usr/local/ --with-dependency-search=/usr/local/
  make
  sudo make install
  sudo /sbin/ldconfig
  cd ..
}

# toxcore for non-pleb distros
gettoxcorenc() {
  git clone https://github.com/irungentoo/ProjectTox-Core.git
  cd ProjectTox-Core
  autoreconf -if
  ./configure --prefix=/usr/local/ --with-dependency-search=/usr/local/
  make
  sudo make install
  sudo /sbin/ldconfig
  cd ..
}

# toxic
gettoxic() {
  git clone https://github.com/Tox/toxic.git
  #  old way of installing, for compatibility purposes:
  #cd toxic
  #autoreconf -if
  #./configure --with-dependency-search=/usr/local/lib/
  #make
  #sudo make install
  cd toxic/build
  make
  sudo make install DESTDIR="/usr/"
  sudo /sbin/ldconfig
  cd ..
}

# toxic for non-pleb distros
gettoxicnc() {
  git clone https://github.com/Tox/toxic.git
  #  old way of installing, for compatibility purposes:
  #cd toxic
  #autoreconf -if
  #./configure --with-dependency-search=/usr/local/
  #make
  #sudo make install
  cd toxic/build
  make
  sudo make install DESTDIR="/usr/"
  sudo /sbin/ldconfig
  cd ..
}

# make headers available
exportlibpath() {
  if grep -Fxq "/usr/local/" /etc/ld.so.conf.d/locallib.conf; then
    echo "[tox.sh] /etc/ld.so.conf.d/locallib.conf found, skipping"
    grep --quiet "^/usr/local/lib/$" /etc/ld.so.conf.d/locallib.conf || echo \
    "[tox.sh] Make sure you have /usr/local/lib/ in \
    /etc/ld.so.conf.d/locallib.conf, otherwise builds may fail"
  else
    echo '/usr/local/lib/' | sudo tee -a /etc/ld.so.conf.d/locallib.conf
    sudo /sbin/ldconfig
  fi
}

# Nodes list removed as of 2014/5/25
# Refer to https://wiki.tox.im/Nodes

# nurupo's Qt GUI (optional}
getqtgui() {
  git clone --recursive https://github.com/nurupo/ProjectTox-Qt-GUI.git
  cd ProjectTox-Qt-GUI
  mkdir build && cd build
  qmake -Wall ../projectfiles/QtCreator/TOX-Qt-GUI.pro
  sudo make
  sudo make install
  sudo /sbin/ldconfig
  cd ..
}

# Venom GUI (optional)
getvenom() {
  #
  # GResolverRecordType was added since glib version 2.34
  # In case if glib is < 2.34, we have to use branch glib_2_32 when cloning Venom (git)
  #
  if [ "$(pkg-config --modversion glib-2.0 |cut -f2 -d.)" -lt "34" ]; then
    git clone -b glib_2_32 https://github.com/naxuroqa/Venom.git
  else
    git clone https://github.com/naxuroqa/Venom.git
  fi
  cd Venom
  mkdir build
  cd build
  if [ "$(pkg-config --modversion glib-2.0 |cut -f2 -d.)" -lt "34" ]; then
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig cmake .. -DCMAKE_INSTALL_PREFIX=/usr/ -DDJBDNS_DIRECTORY="../../djbdns-1.05"
  else
    PKG_CONFIG_PATH=/usr/local/lib/pkgconfig cmake .. -DCMAKE_INSTALL_PREFIX=/usr/
  fi

  make
  sudo make install
  sudo /sbin/ldconfig
  sudo wget -O /usr/share/applications/venom.desktop https://raw.github.com/naxuroqa/Venom/master/misc/venom.desktop.in
  cd ..
}

get_distro_type() {

  # Fedora / RHEL / CentOS / RedHat derivative
  if [ -r /etc/yum.conf ]; then
    echo "[tox.sh] RHEL / derivative detected"
    [ "$nodep" != "1" ] && {
      sudo yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
      sudo yum groupinstall "Development Tools"
      sudo yum install git-core libtool curl autoconf automake ffmpeg libconfig-devel ncurses-devel opusfile-devel opusfile libvpx libvpx-devel
    }
    exportlibpath && exlibpth=1
    [ "$nolibsm" != "1" ] && getlibsodiumnc && gotlibsm=1
    gettoxcorenc     && gottcore=1
    gettoxicnc       && gottoxic=1

  # SUSE
  elif [ -r /etc/SuSE-release ]; then
    echo "[tox.sh] SuSE Linux / derivative detected"
    [ "$nodep" != "1" ] && {
      sudo zypper install ncurses-utils curl autoconf git ffmpeg libconfig-devel libconfig9 check libtool libavcodec55 libvpx libavdevice55 libavformat55 libswscale2 libopenal1 libSDL2-2_0-0 libopus0
      sudo zypper install --type pattern devel_basis
    }
    [ "$nolibsm" != "1" ] && getlibsodium && gotlibsm=1
    gettoxcore      && gottcore=1
    gettoxic        && gottoxic=1

  # Debian / Ubuntu / Mint / Debian derivative
  elif [ -r /etc/apt ]; then
    echo "[tox.sh] Debian Linux / derivative detected"
    sudo rm -rf /tmp/tox-update
    mkdir -p /tmp/tox-update
    cd /tmp/tox-update
    [ "$nodep" != "1" ] && {
      wget http://www.hyperrealm.com/libconfig/libconfig-1.4.9.tar.gz
      tar -xvzf libconfig-1.4.9.tar.gz
      cd libconfig-1.4.9
      ./configure
      make -j3
      sudo make install
      rm ../libconfig.tar.gz
    }
    [ "$nodep" != "1" ] && {
      sudo apt-get install git curl build-essential libtool autotools-dev automake ncurses-dev checkinstall libavformat-dev libavdevice-dev libswscale-dev libsdl-dev libopenal-dev libopus-dev libvpx-dev check yasm valac cmake libgtk-3-dev libjson-glib-dev libsqlite3-dev
      cd ..
    }
    #sudo rm -rf ./libconfig-1.4.9.tar.gz
    #git clone https://github.com/FFmpeg/FFmpeg.git
    #cd FFmpeg
    #git checkout n2.0.2
    #./configure --disable-programs
    #sudo make && sudo make install
    #cd ..


    if [ "$(pkg-config --modversion glib-2.0 |cut -f2 -d.)" -lt "34" ]; then
        mkdir -p /tmp/tox-update
        cd /tmp/tox-update
        wget http://cr.yp.to/djbdns/djbdns-1.05.tar.gz
        tar xvzf djbdns-1.05.tar.gz
        cd djbdns-1.05/
        echo "gcc -O2 -include /usr/include/errno.h" > conf-cc
        make
        make setup check
	sudo /sbin/ldconfig
        cd /tmp/tox-update
    fi

    [ "$nolibsm" != "1" ] && getlibsodium && gotlibsm=1
    exportlibpath && exlibpth=1
    gettoxcore      && gottcore=1
    gettoxic        && gottoxic=1
    getvenom        && gotvenom=1
    
  # Gentoo / Gentoo derivative
  elif [ -r /etc/gentoo-release ]; then
    echo "[tox.sh] Gentoo Linux / derivative detected"
    echo "[tox.sh] If things don't go as intended, you should be able to \
    figure it out on your own."
    sudo su
    layman -f -o \
    https://raw.github.com/fr0stycl34r/gentoo-overlay-tox/master/repository.xml \
    -a tox-overlay
    # Don't blame me or fr0stycl34r if something from an other repo borks
    layman -a qt; layman -S; emerge --sync


  # Arch / Arch derivative
  elif [ -r /etc/pacman.d/ ]; then
    echo "[tox.sh] Arch Linux / derivative detected"
    [ "$nodep" != "1" ] && sudo pacman -S ncurses libconfig qt5-base git curl openal opus libvpx sdl libvorbis ffmpeg
    [ "$nodep" != "1" ] && sudo pacman -S base-devel vala cmake gtk3 libgee # last 4 optional
    [ "$nolibsm" != "1" ] && getlibsodiumnc && gotlibsm=1
    exportlibpath    && exlibpth=1
    gettoxcorenc     && gottcore=1
    gettoxicnc       && gottoxic=1
    #getqtgui         && gotqtgui=1
    getvenom         && gotvenom=1
    
  # Other
  else
    echo "[tox.sh] Unknown distro, install manually"
  fi
}

# Detect GNU/Linux distribution/install dependencies for Tox/Toxic
# (no arguments passed)
get_distro_type

echo '
'
test "$exlibpth" == 1 && echo "[tox.sh] Linked to headers in /usr/local/lib/"
test "$gotlibsm" == 1 && echo "[tox.sh] Installed libsodium"
test "$gottcore" == 1 && echo "[tox.sh] Installed toxcore"
test "$gottoxic" == 1 && echo "[tox.sh] Installed toxic"
test "$gotqtgui" == 1 && echo "[tox.sh] Installed nurupo's Qt GUI"
test "$gotvenom" == 1 && echo "[tox.sh] Installed venom"

echo "[tox.sh] Done"; exit 0
