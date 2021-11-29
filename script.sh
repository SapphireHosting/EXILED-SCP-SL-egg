#!/bin/bash
# steamcmd Base Installation Script
#
# Server Files: /mnt/server

# Egg version checking, do not touch!
currentVersion="2.1.4"
latestVersion=$(curl --silent "https://api.github.com/repos/Parkeymon/EXILED-SCP-SL-egg/releases/latest" | jq -r .tag_name)

if [ "${currentVersion}" == "${latestVersion}" ]; then
  echo "$(tput setaf 2)Installer is up to date"
else

  echo "
  $(tput setaf 1)THE INSTALLER IS NOT UP TO DATE!

    Current Version: $(tput setaf 1)${currentVersion}
    Latest: $(tput setaf 2)${latestVersion}

  $(tput setaf 3)Please update to the latest version found here: https://github.com/AtomSnow/EXILED-SCP-SL-egg/releases/latest

  "
  sleep 5
fi

# Download SteamCMD and Install
cd /tmp || {
  echo "$(tput setaf 1) FAILED TO MOUNT TO /TMP"
  exit
}
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
cd /mnt/server/steamcmd || {
  echo "$(tput setaf 1) FAILED TO MOUNT TO /mnt/server/steamcmd"
  exit
}

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

if [ "${BETA_TAG}" == "none" ]; then
  ./steamcmd.sh +login anonymous +force_install_dir /mnt/server +app_update "${SRCDS_APPID}" validate +quit
fi

if [ "${BETA_TAG}" == "publicbeta" ]; then
  ./steamcmd.sh +login anonymous +force_install_dir /mnt/server +app_update "${SRCDS_APPID}" -beta "${BETA_TAG}" validate +quit
fi

# Install SL with SteamCMD
cd /mnt/server || {
  echo "$(tput setaf 1) FAILED TO MOUNT TO /mnt/server"
  exit
}

echo "$(tput setaf 4)Configuring start.sh$(tput setaf 0)"
rm start.sh
touch "start.sh"
chmod +x ./start.sh

mkdir .sapphire-ignore

else
  echo "#!/bin/bash
    ./LocalAdmin \${SERVER_PORT}" >>start.sh
  echo "$(tput setaf 4)Finished configuring start.sh for LocalAdmin.$(tput setaf 0)"

if [ "${INSTALL_EXILED}" == "true" ]; then
  echo "$(tput setaf 4)Downloading $(tput setaf 1)EXILED$(tput setaf 0).."
  mkdir .config/
  echo "$(tput setaf 4)Downloading latest $(tput setaf 1)EXILED$(tput setaf 4) Installer"
  rm Exiled.Installer-Linux
  wget -q https://github.com/galaxy119/EXILED/releases/latest/download/Exiled.Installer-Linux
  chmod +x ./Exiled.Installer-Linux

  if [ "${EXILED_PRE}" == "true" ]; then
    echo "$(tput setaf 4)Installing $(tput setaf 1)EXILED (pre-release)..."
    ./Exiled.Installer-Linux --pre-releases

  elif [ "${EXILED_PRE}" == "false" ]; then
    echo "$(tput setaf 4)Installing $(tput setaf 1)EXILED$(tput setaf 0)..."
    ./Exiled.Installer-Linux

  else
    echo "$(tput setaf 4)Installing $(tput setaf 1)EXILED$(tput setaf 0) version: ${EXILED_PRE} .."
    ./Exiled.Installer-Linux --target-version "${EXILED_PRE}"

  fi
else
  echo "Skipping Exiled installation."
