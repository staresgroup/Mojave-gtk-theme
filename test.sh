#! /usr/bin/env bash

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SRC_DIR="${REPO_DIR}/src"

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.themes"
fi

THEME_NAME=Mojave
COLOR_VARIANTS=('-light' '-dark')

if [[ "$(command -v gnome-shell)" ]]; then
  SHELL_VERSION="$(gnome-shell --version | cut -d ' ' -f 3 | cut -d . -f -1)"
  if [[ "${SHELL_VERSION:-}" -ge "40" ]]; then
    GS_VERSION="new"
  else
    GS_VERSION="old"
  fi
  else
    echo "'gnome-shell' not found, using styles for last gnome-shell version available."
    GS_VERSION="new"
fi

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-c, --color VARIANTS" "Specify theme color variant(s) [light|dark] (Default: All variants)"
  printf "  %-25s%s\n" "-g, --gdm" "Install GDM theme, this option need root user authority! please run this with sudo"
  printf "  %-25s%s\n" "-r, --revert" "revert GDM theme, this option need root user authority! please run this with sudo"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  local dest="${1}"
  local name="${2}"
  local color="${3}"

  [[ "${color}" == '-light' ]] && local ELSE_LIGHT="${color}"
  [[ "${color}" == '-dark' ]] && local ELSE_DARK="${color}"

  local THEME_DIR="${1}/${2}${3}"

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"

  echo "Installing '${THEME_DIR}'..."

  mkdir -p                                                                                   "${THEME_DIR}"
  cp -r "${REPO_DIR}/COPYING"                                                                "${THEME_DIR}"

  echo "[Desktop Entry]" >>                                                                  "${THEME_DIR}/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                                           "${THEME_DIR}/index.theme"
  echo "Name=${name}${color}" >>                                                             "${THEME_DIR}/index.theme"
  echo "Comment=An Stylish Gtk+ theme based on Elegant Design" >>                            "${THEME_DIR}/index.theme"
  echo "Encoding=UTF-8" >>                                                                   "${THEME_DIR}/index.theme"
  echo "" >>                                                                                 "${THEME_DIR}/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                              "${THEME_DIR}/index.theme"
  echo "GtkTheme=${name}${color}" >>                                                         "${THEME_DIR}/index.theme"
  echo "MetacityTheme=${name}${color}" >>                                                    "${THEME_DIR}/index.theme"
  echo "IconTheme=Adwaita" >>                                                                "${THEME_DIR}/index.theme"
  echo "CursorTheme=Adwaita" >>                                                              "${THEME_DIR}/index.theme"
  echo "ButtonLayout=close,minimize,maximize:menu" >>                                        "${THEME_DIR}/index.theme"

  mkdir -p                                                                                   "${THEME_DIR}/gnome-shell"

  if [[ "${GS_VERSION:-}" == 'new' ]]; then
    cp -r "${SRC_DIR}/main/gnome-shell/shell-40-0/gnome-shell${color}.css"                   "${THEME_DIR}/gnome-shell/gnome-shell.css"
  else
    cp -r "${SRC_DIR}/main/gnome-shell/shell-3-28/gnome-shell${color}.css"                   "${THEME_DIR}/gnome-shell/gnome-shell.css"
  fi

  cp -r "${SRC_DIR}/assets/gnome-shell/common-assets"                                        "${THEME_DIR}/gnome-shell/assets"
  cp -r "${SRC_DIR}/assets/gnome-shell/assets${color}/"*'.svg'                               "${THEME_DIR}/gnome-shell/assets"
  cp -r "${SRC_DIR}/assets/gnome-shell/assets${color}/background.png"                        "${THEME_DIR}/gnome-shell/assets"
  cp -r "${SRC_DIR}/assets/gnome-shell/activities${color}/activities.svg"                    "${THEME_DIR}/gnome-shell/assets/activities.svg"
  cp -r "${SRC_DIR}/assets/gnome-shell/activities-dark/activities${icon}.svg"                "${THEME_DIR}/gnome-shell/assets/activities-white.svg"
  cd "${THEME_DIR}/gnome-shell"
  mv -f assets/no-events.svg no-events.svg
  mv -f assets/process-working.svg process-working.svg
  mv -f assets/no-notifications.svg no-notifications.svg

  mkdir -p                                                                                   "${THEME_DIR}/gtk-2.0"
  cp -r "${SRC_DIR}/main/gtk-2.0/gtkrc${color}"                                              "${THEME_DIR}/gtk-2.0/gtkrc"
  cp -r "${SRC_DIR}/main/gtk-2.0/menubar-toolbar${color}.rc"                                 "${THEME_DIR}/gtk-2.0/menubar-toolbar.rc"
  cp -r "${SRC_DIR}/main/gtk-2.0/common/"*'.rc'                                              "${THEME_DIR}/gtk-2.0"
  cp -r "${SRC_DIR}/assets/gtk-2.0/assets${color}"                                           "${THEME_DIR}/gtk-2.0/assets"

  mkdir -p                                                                                   "${THEME_DIR}/gtk-3.0"
  cp -r "${SRC_DIR}/assets/gtk/common-assets/assets"                                         "${THEME_DIR}/gtk-3.0"
  cp -r "${SRC_DIR}/assets/gtk/windows-assets/titlebutton"                                   "${THEME_DIR}/gtk-3.0/windows-assets"
  cp -r "${SRC_DIR}/assets/gtk/thumbnails/thumbnail${color}.png"                             "${THEME_DIR}/gtk-3.0/thumbnail.png"
  cp -r "${SRC_DIR}/main/gtk-3.0/gtk-dark.css"                                               "${THEME_DIR}/gtk-3.0/gtk-dark.css"

  if [[ "${color}" == '-light' ]]; then
    cp -r "${SRC_DIR}/main/gtk-3.0/gtk-light.css"                                            "${THEME_DIR}/gtk-3.0/gtk.css"
  else
    cp -r "${SRC_DIR}/main/gtk-3.0/gtk-dark.css"                                             "${THEME_DIR}/gtk-3.0/gtk.css"
  fi

  mkdir -p                                                                                   "${THEME_DIR}/gtk-4.0"
  cp -r "${SRC_DIR}/assets/gtk/common-assets/assets"                                         "${THEME_DIR}/gtk-4.0"
  cp -r "${SRC_DIR}/assets/gtk/windows-assets/titlebutton"                                   "${THEME_DIR}/gtk-4.0/windows-assets"
  cp -r "${SRC_DIR}/assets/gtk/thumbnails/thumbnail${color}.png"                             "${THEME_DIR}/gtk-4.0/thumbnail.png"
  cp -r "${SRC_DIR}/main/gtk-4.0/gtk-dark.css"                                               "${THEME_DIR}/gtk-4.0/gtk-dark.css"

  if [[ "${color}" == '-light' ]]; then
    cp -r "${SRC_DIR}/main/gtk-4.0/gtk-light.css"                                            "${THEME_DIR}/gtk-4.0/gtk.css"
  else
    cp -r "${SRC_DIR}/main/gtk-4.0/gtk-dark.css"                                             "${THEME_DIR}/gtk-4.0/gtk.css"
  fi

  mkdir -p                                                                                   "${THEME_DIR}/metacity-1"
  cp -r "${SRC_DIR}/main/metacity-1/metacity-theme${color}.xml"                              "${THEME_DIR}/metacity-1/metacity-theme-1.xml"
  cp -r "${SRC_DIR}/main/metacity-1/metacity-theme-3.xml"                                    "${THEME_DIR}/metacity-1"
  cp -r "${SRC_DIR}/assets/metacity-1/assets/"*'.png'                                        "${THEME_DIR}/metacity-1"
  cp -r "${SRC_DIR}/assets/metacity-1/thumbnail${color}.png"                                 "${THEME_DIR}/metacity-1/thumbnail.png"
  cd "${THEME_DIR}/metacity-1" && ln -s metacity-theme-1.xml metacity-theme-2.xml

  mkdir -p                                                                                   "${THEME_DIR}/xfwm4"
  cp -r "${SRC_DIR}/assets/xfwm4/assets${color}/"*'.png'                                     "${THEME_DIR}/xfwm4"
  cp -r "${SRC_DIR}/main/xfwm4/themerc${color}"                                              "${THEME_DIR}/xfwm4/themerc"

  mkdir -p                                                                                   "${THEME_DIR}/cinnamon"
  cp -r "${SRC_DIR}/main/cinnamon/cinnamon${color}.css"                                      "${THEME_DIR}/cinnamon/cinnamon.css"
  cp -r "${SRC_DIR}/assets/cinnamon/common-assets"                                           "${THEME_DIR}/cinnamon/assets"
  cp -r "${SRC_DIR}/assets/cinnamon/assets${color}/"*.'svg'                                  "${THEME_DIR}/cinnamon/assets"
  cp -r "${SRC_DIR}/assets/cinnamon/thumbnails/thumbnail${color}.png"                        "${THEME_DIR}/cinnamon/thumbnail.png"

  mkdir -p                                                                                   "${THEME_DIR}/plank"
  cp -r "${SRC_DIR}/other/plank/${name}${color}/"*'.theme'                                   "${THEME_DIR}/plank"
}

# Backup and install files related to GDM theme

GS_THEME_FILE="/usr/share/gnome-shell/gnome-shell-theme.gresource"
SHELL_THEME_FOLDER="/usr/share/gnome-shell/theme"
ETC_THEME_FOLDER="/etc/alternatives"
ETC_THEME_FILE="/etc/alternatives/gdm3.css"
UBUNTU_THEME_FILE="/usr/share/gnome-shell/theme/ubuntu.css"
UBUNTU_NEW_THEME_FILE="/usr/share/gnome-shell/theme/gnome-shell.css"

install_gdm() {
  local GDM_THEME_DIR="${1}/${2}${3}"

  echo
  echo "Installing ${2}${3} gdm theme..."

  if [[ -f "$GS_THEME_FILE" ]] && command -v glib-compile-resources >/dev/null ; then
    echo "Installing '$GS_THEME_FILE'..."
    cp -an "$GS_THEME_FILE" "$GS_THEME_FILE.bak"
    glib-compile-resources \
      --sourcedir="$GDM_THEME_DIR/gnome-shell" \
      --target="$GS_THEME_FILE" \
      "${SRC_DIR}/main/gnome-shell/gnome-shell-theme.gresource.xml"
  fi

  if [[ -f "$UBUNTU_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    echo "Installing '$UBUNTU_THEME_FILE'..."
    cp -an "$UBUNTU_THEME_FILE" "$UBUNTU_THEME_FILE.bak"
    # rm -rf "$GS_THEME_FILE"
    # mv "$GS_THEME_FILE.bak" "$GS_THEME_FILE"
    cp -af "$GDM_THEME_DIR/gnome-shell/gnome-shell.css" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    echo "Installing '$UBUNTU_NEW_THEME_FILE'..."
    cp -an "$UBUNTU_NEW_THEME_FILE" "$UBUNTU_NEW_THEME_FILE.bak"
    cp -af "$GDM_THEME_DIR"/gnome-shell/* "$SHELL_THEME_FOLDER"
  fi

  if [[ -f "$ETC_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    echo "Installing Ubuntu gnome-shell theme..."
    cp -an "$ETC_THEME_FILE" "$ETC_THEME_FILE.bak"
    # rm -rf "$ETC_THEME_FILE" "$GS_THEME_FILE"
    # mv "$GS_THEME_FILE.bak" "$GS_THEME_FILE"
    [[ -d "$SHELL_THEME_FOLDER/Mojave" ]] && rm -rf "$SHELL_THEME_FOLDER/Mojave"
    cp -r "$GDM_THEME_DIR/gnome-shell" "$SHELL_THEME_FOLDER/Mojave"
    cd "$ETC_THEME_FOLDER"
    ln -s "$SHELL_THEME_FOLDER/Mojave/gnome-shell.css" gdm3.css
  fi
}

revert_gdm() {
  if [[ -f "$GS_THEME_FILE.bak" ]]; then
    echo "reverting '$GS_THEME_FILE'..."
    rm -rf "$GS_THEME_FILE"
    mv "$GS_THEME_FILE.bak" "$GS_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_THEME_FILE.bak" ]]; then
    echo "reverting '$UBUNTU_THEME_FILE'..."
    rm -rf "$UBUNTU_THEME_FILE"
    mv "$UBUNTU_THEME_FILE.bak" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE.bak" ]]; then
    echo "reverting '$UBUNTU_NEW_THEME_FILE'..."
    rm -rf "$UBUNTU_NEW_THEME_FILE" "$SHELL_THEME_FOLDER"/{assets,no-events.svg,process-working.svg,no-notifications.svg}
    mv "$UBUNTU_NEW_THEME_FILE.bak" "$UBUNTU_NEW_THEME_FILE"
  fi

  if [[ -f "$ETC_THEME_FILE.bak" ]]; then
    echo "reverting Ubuntu gnome-shell theme..."
    rm -rf "$ETC_THEME_FILE"
    mv "$ETC_THEME_FILE.bak" "$ETC_THEME_FILE"
    [[ -d "$SHELL_THEME_FOLDER/Mojave" ]] && rm -rf "$SHELL_THEME_FOLDER/Mojave"
  fi
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "Destination directory does not exist. Let's make a new one..."
        mkdir -p ${dest}
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -g|--gdm)
      gdm='true'
      shift 1
      ;;
    -r|--revert)
      revert='true'
      shift 1
      ;;
    -c|--color)
      shift
      for color in "${@}"; do
        case "${color}" in
          light)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

# Parse scss to css
for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    sassc $SASSC_OPT src/main/gtk-3.0/gtk${color}.{scss,css}
    echo "==> Generating the 3.0 gtk${color}.css..."
    sassc $SASSC_OPT src/main/gtk-4.0/gtk${color}.{scss,css}
    echo "==> Generating the 4.0 gtk${color}.css..."
    sassc $SASSC_OPT src/main/cinnamon/cinnamon${color}.{scss,css}
    echo "==> Generating the cinnamon${color}.css..."
    sassc $SASSC_OPT src/main/gnome-shell/shell-3-28/gnome-shell${color}.{scss,css}
    echo "==> Generating the 3.28 gnome-shell${color}.css..."
    sassc $SASSC_OPT src/main/gnome-shell/shell-40-0/gnome-shell${color}.{scss,css}
    echo "==> Generating the 40.0 gnome-shell${color}.css..."
done

sassc $SASSC_OPT src/other/dash-to-dock/stylesheet.{scss,css}
echo "==> Generating dash-to-dock stylesheet.css..."
sassc $SASSC_OPT src/other/dash-to-dock/stylesheet-dark.{scss,css}
echo "==> Generating dash-to-dock stylesheet-dark.css..."

install_theme() {
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}"
  done
}

if [[ "${gdm:-}" != 'true' && "${revert:-}" != 'true' ]]; then
  install_theme
fi

if [[ "${gdm:-}" == 'true' && "${revert:-}" != 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  install_theme && install_gdm "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}"
fi

if [[ "${gdm:-}" != 'true' && "${revert:-}" == 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  revert_gdm
fi

echo
echo Done.
