#!/usr/bin/env bash
##################
add_debian_opt_repo() {
    notes_of_debian_opt_repo
    printf "%s\n" "检测到您未添加debian_opt软件源，是否添加？"
    do_you_want_to_continue
    add_debian_opt_gpg_key
}
##############
notes_of_debian_opt_repo() {
    printf "%s\n" "debian_opt_repo列表的所有软件均来自于开源项目"
    printf "%s\n" "感谢https://github.com/coslyk/debianopt-repo 仓库的维护者coslyk，以及各个项目的原开发者。"
}
#############
switch_debian_opt_repo_sources() {
    non_debian_function
    if grep '^deb.*ustc' ${OPT_REPO_LIST}; then
        OPT_REPO_NAME='USTC'
    else
        OPT_REPO_NAME='bintray'
    fi
    if (whiptail --title "您想要对这个小可爱做什么呢" --yes-button "USTC" --no-button "bintray" --yesno "检测到您当前的软件源为${OPT_REPO_NAME}\n您想要切换为哪个软件源?♪(^∇^*) " 0 0); then
        printf "%s\n%s\n" "deb ${OPT_URL_01} buster main" "#deb ${OPT_URL_02} buster main" >${OPT_REPO_LIST}
    else
        printf "%s\n%s\n" "#deb ${OPT_URL_01} buster main" "deb ${OPT_URL_02} buster main" >${OPT_REPO_LIST}
    fi
    apt update
}
#######################
explore_debian_opt_repo() {
    case "${LINUX_DISTRO}" in
    debian)
        install_gpg
        [[ -e "${OPT_REPO_LIST}" ]] || add_debian_opt_repo
        ;;
    esac
    debian_opt_menu
}
#################
debian_opt_menu() {
    RETURN_TO_WHERE='debian_opt_menu'
    RETURN_TO_MENU='debian_opt_menu'
    DEPENDENCY_02=""
    cd ${APPS_LNK_DIR}
    #16 50 7
    INSTALL_APP=$(whiptail --title "DEBIAN OPT REPO" --menu \
        "您想要安装哪个软件？\n Which software do you want to install? " 0 0 0 \
        "1" "🎶 music:vocal,flacon" \
        "2" "📝 notes笔记:markdown编辑器" \
        "3" "📺 videos视频:多媒体音视频格式转换" \
        "4" "🖼️ pictures图像:bing壁纸" \
        "5" "📖 reader:悦享生活,品味阅读" \
        "6" "🎮 games游戏:Minecraft启动器" \
        "7" "👾 development程序开发:GUI设计" \
        "8" "switch source repo:切换软件源仓库" \
        "9" "remove(移除本仓库)" \
        "0" "🌚 Return to previous menu 返回上级菜单" \
        3>&1 1>&2 2>&3)
    ##############
    case "${INSTALL_APP}" in
    0 | "") software_center ;;
    1) debian_opt_music_app ;;
    2) debian_opt_note_app ;;
    3) debian_opt_video_app ;;
    4) debian_opt_picture_app ;;
    5) debian_opt_reader_app ;;
    6) debian_opt_game_app ;;
    7) debian_opt_development_app ;;
    8) switch_debian_opt_repo_sources ;;
    9) remove_debian_opt_repo ;;
    esac
    ##########################
    press_enter_to_return
    debian_opt_menu
}
################
debian_opt_install_or_remove_01() {
    RETURN_TO_WHERE='debian_opt_install_or_remove_01'
    NOTICE_OF_REPAIR='false'
    OPT_APP_VERSION_TXT="${TMOE_LINUX_DIR}/${DEPENDENCY_01}_version.txt"
    INSTALL_APP=$(whiptail --title "${DEPENDENCY_01} manager" --menu \
        "您要对${DEPENDENCY_01}小可爱做什么?\nWhat do you want to do with the software?" 0 0 0 \
        "1" "install 安装" \
        "2" "upgrade 更新" \
        "3" "remove 卸载" \
        "0" "🌚 Back 返回" \
        3>&1 1>&2 2>&3)
    ##############
    case "${INSTALL_APP}" in
    0 | "") ${RETURN_TO_MENU} ;;
    1) install_opt_app_01 ;;
    2) upgrade_opt_app_01 ;;
    3) remove_opt_app_01 ;;
    esac
    ##########################
    press_enter_to_return
    ${RETURN_TO_MENU}
}
################
check_debian_opt_app_version() {
    DEBIAN_OPT_REPO_POOL_URL="${OPT_URL_02}/pool/main/"
    APP_NAME_PREFIX="$(printf '%s\n' "${DEPENDENCY_01}" | cut -c 1)"
    DEBIAN_OPT_APP_PATH_URL="${DEBIAN_OPT_REPO_POOL_URL}${APP_NAME_PREFIX}/${DEPENDENCY_01}"
    THE_LATEST_DEB_FILE=$(curl -Lv "${DEBIAN_OPT_APP_PATH_URL}" | grep '\.deb' | grep -v '.asc' | grep "${ARCH_TYPE}" | tail -n 1 | cut -d '"' -f 4 | cut -d ':' -f 2)
}
###############
download_debian_opt_app() {
    printf "%s\n" "${THE_LATEST_DEB_FILE}" >${OPT_APP_VERSION_TXT}
    DEBIAN_OPT_APP_URL="${DEBIAN_OPT_APP_PATH_URL}/${THE_LATEST_DEB_FILE}"
    DOWNLOAD_PATH='/tmp/.DEB_OPT_TEMP_FOLDER'
    ELECTRON_FILE_URL="${DEBIAN_OPT_APP_URL}"
    if [ -e "${DOWNLOAD_PATH}" ]; then
        rm -rv ${DOWNLOAD_PATH}
    fi
    aria2c_download_file_no_confirm
    extract_deb_file_01
    extract_deb_file_02
}
##############
remove_opt_app_01() {
    case "${LINUX_DISTRO}" in
    debian)
        printf "%s\n" "${RED}${TMOE_REMOVAL_COMMAND}${RESET} ${BLUE}${DEPENDENCY_01}${RESET}"
        do_you_want_to_continue
        ${TMOE_REMOVAL_COMMAND} ${DEPENDENCY_01}
        ;;
    *)
        DEBIAN_OPT_APP_DIR="/opt/${DEPENDENCY_01}"
        printf "%s\n" "${RED}rm -rv${RESET} ${BLUE}${DEBIAN_OPT_APP_DIR} ${OPT_APP_VERSION_TXT} ${APPS_LNK_DIR}/${DEPENDENCY_01}.desktop${RESET}"
        do_you_want_to_continue
        rm -rv ${DEBIAN_OPT_APP_DIR} ${OPT_APP_VERSION_TXT} ${APPS_LNK_DIR}/${DEPENDENCY_01}.desktop
        ;;
    esac
}
################
install_opt_app_01() {
    case "${LINUX_DISTRO}" in
    debian)
        #check_electron
        beta_features_quick_install
        ;;
    *)
        beta_features_quick_install
        non_debian_function
        ;;
    esac
}
################
display_debian_opt_app_version() {
    printf "%s\n" "正在检测版本信息..."
    if [ -e "${OPT_APP_VERSION_TXT}" ]; then
        LOCAL_OPT_APP_VERSION=$(sed -n p ${OPT_APP_VERSION_TXT} | head -n 1)
    else
        LOCAL_OPT_APP_VERSION="您尚未安装${DEPENDENCY_01}"
    fi
    cat <<-ENDofTable
		╔═══╦═══════════════════╦════════════════
		║   ║                   ║                    
		║   ║    ✨最新版本     ║   本地版本 🎪
		║   ║  Latest version   ║  Local version     
		║---║-------------------║--------------------
		║ 1 ║                     ${LOCAL_OPT_APP_VERSION} 
		║   ║${THE_LATEST_DEB_FILE} 

	ENDofTable
    printf "%s\n" "Do you want to upgrade it?"
    do_you_want_to_continue
}
#################
upgrade_opt_app_01() {
    if [ -e "/usr/share/icons/${DEPENDENCY_01}.png" ]; then
        if [ $(command -v catimg) ]; then
            catimg /usr/share/icons/${DEPENDENCY_01}.png
        else
            random_neko
        fi
    else
        random_neko
    fi

    case "${LINUX_DISTRO}" in
    debian)
        apt update
        apt install -y ${DEPENDENCY_01}
        ;;
    *) non_debian_function ;;
    esac
}
###############
debian_opt_game_app() {
    DEPENDENCY_02=''
    RETURN_TO_WHERE='debian_opt_game_app'
    RETURN_TO_MENU='debian_opt_game_app'
    DEBIAN_INSTALLATION_MENU='00'
    INSTALL_APP=$(whiptail --title "GAMES" --menu \
        "您想要安装哪个软件?\nWhich software do you want to install? " 0 0 0 \
        "1" "hmcl:跨平台且广受欢迎的Minecraft(我的世界)启动器" \
        "2" "minetest(免费开源沙盒建造游戏)" \
        "3" "gamehub:管理Steam,GOG,Humble Bundle等平台的游戏" \
        "0" "🌚 Return to previous menu 返回上级菜单" \
        3>&1 1>&2 2>&3)
    ##############
    case "${INSTALL_APP}" in
    0 | "") debian_opt_menu ;;
    1)
        DEPENDENCY_01='hmcl'
        ORIGINAL_URL='https://github.com/huanghongxun/HMCL'
        printf "%s\n" "${YELLOW}${ORIGINAL_URL}${RESET}"
        case ${ARCH_TYPE} in
        amd64 | i386) ;;
        *)
            this_app_may_non_support_running_on_proot
            printf "%s\n" "hmcl依赖于openjfx,如需安装，则请自行解决依赖问题。"
            non_debian_function
            add_debian_old_source
            #printf "%s\n" "${GREEN}apt install -y${RESET} ${BLUE}hmcl${RESET}"
            #apt install -y hmcl
            beta_features_quick_install
            del_debian_old_source
            #arch_does_not_support
            press_enter_to_return
            ${RETURN_TO_WHERE}
            ;;
        esac
        ;;
    2)
        DEPENDENCY_01='minetest'
        case ${LINUX_DISTRO} in
        debian) DEPENDENCY_02='^minetest-mod minetest-server' ;;
        *) DEPENDENCY_02='minetest-server' ;;
        esac
        beta_features_quick_install
        ;;
    3)
        printf "%s\n" "${YELLOW}${ORIGINAL_URL}${RESET}"
        DEPENDENCY_01='gamehub'
        ORIGINAL_URL='https://tkashkin.tk/projects/gamehub'
        ;;
    esac
    ##########################
    case ${DEBIAN_INSTALLATION_MENU} in
    00)
        non_debian_function
        beta_features_quick_install
        ;;
    01) debian_opt_install_or_remove_01 ;;
    esac
    ########################
    press_enter_to_return
    ${RETURN_TO_WHERE}
}
############
debian_opt_development_app() {
    DEPENDENCY_02=''
    RETURN_TO_WHERE='debian_opt_development_app'
    RETURN_TO_MENU='debian_opt_development_app'
    DEBIAN_INSTALLATION_MENU='01'
    INSTALL_APP=$(whiptail --title "DEVELOPMENT" --menu \
        "您想要安装哪个软件?\nWhich software do you want to install? " 0 0 0 \
        "1" "wxformbuilder:用于wxWidgets GUI设计的RAD工具" \
        "0" "🌚 Return to previous menu 返回上级菜单" \
        3>&1 1>&2 2>&3)
    ##############
    case "${INSTALL_APP}" in
    0 | "") debian_opt_menu ;;
    1)
        DEPENDENCY_01='wxformbuilder'
        ORIGINAL_URL='https://github.com/wxFormBuilder/wxFormBuilder'
        ;;
    esac
    ##########################
    printf "%s\n" "${YELLOW}${ORIGINAL_URL}${RESET}"
    case ${DEBIAN_INSTALLATION_MENU} in
    01) debian_opt_install_or_remove_01 ;;
    esac
    ########################
    press_enter_to_return
    ${RETURN_TO_WHERE}
}
###############
debian_opt_video_app() {
    DEPENDENCY_02=''
    RETURN_TO_WHERE='debian_opt_video_app'
    RETURN_TO_MENU='debian_opt_video_app'
    DEBIAN_INSTALLATION_MENU='00'
    INSTALL_APP=$(whiptail --title "VIDEO APP" --menu \
        "您想要安装哪个软件?\nWhich software do you want to install? " 0 0 0 \
        "1" "ciano:多媒体音视频格式转换器" \
        "0" "🌚 Return to previous menu 返回上级菜单" \
        3>&1 1>&2 2>&3)
    ##############
    case "${INSTALL_APP}" in
    0 | "") debian_opt_menu ;;
    1)
        DEPENDENCY_01='ciano'
        ORIGINAL_URL='https://robertsanseries.github.io/ciano'
        ;;
    esac
    ##########################
    printf "%s\n" "${YELLOW}${ORIGINAL_URL}${RESET}"
    case ${DEBIAN_INSTALLATION_MENU} in
    00)
        non_debian_function
        beta_features_quick_install
        ;;
    01) debian_opt_install_or_remove_01 ;;
    esac
    ########################
    press_enter_to_return
    ${RETURN_TO_WHERE}
}
#############
debian_opt_reader_app() {
    DEPENDENCY_02=''
    RETURN_TO_WHERE='debian_opt_reader_app'
    RETURN_TO_MENU='debian_opt_reader_app'
    DEBIAN_INSTALLATION_MENU='00'
    INSTALL_APP=$(whiptail --title "READER APP" --menu \
        "您想要安装哪个软件?\nWhich software do you want to install? " 0 0 0 \
        "1" "bookworm:简约的电子书阅读器" \
        "2" "foliate:简单且现代化的电子书阅读器" \
        "0" "🌚 Return to previous menu 返回上级菜单" \
        3>&1 1>&2 2>&3)
    ##############
    case "${INSTALL_APP}" in
    0 | "") debian_opt_menu ;;
    1)
        DEPENDENCY_01='bookworm'
        ORIGINAL_URL='https://github.com/babluboy/bookworm'
        ;;
    2)
        DEPENDENCY_01='foliate'
        ORIGINAL_URL='https://johnfactotum.github.io/foliate/'
        ;;
    esac
    ##########################
    printf "%s\n" "${YELLOW}${ORIGINAL_URL}${RESET}"
    case ${DEBIAN_INSTALLATION_MENU} in
    00)
        non_debian_function
        beta_features_quick_install
        ;;
    esac
    ########################
    press_enter_to_return
    ${RETURN_TO_WHERE}
}
############
debian_opt_picture_app() {
    DEPENDENCY_02=''
    RETURN_TO_WHERE='debian_opt_picture_app'
    RETURN_TO_MENU='debian_opt_picture_app'
    DEBIAN_INSTALLATION_MENU='00'
    INSTALL_APP=$(whiptail --title "PIC APP" --menu \
        "您想要安装哪个软件?\nWhich software do you want to install? " 0 0 0 \
        "1" "bingle:下载微软必应每日精选壁纸" \
        "2" "fondo:壁纸app" \
        "0" "🌚 Return to previous menu 返回上级菜单" \
        3>&1 1>&2 2>&3)
    ##############
    case "${INSTALL_APP}" in
    0 | "") debian_opt_menu ;;
    1)
        DEPENDENCY_01='bingle'
        ORIGINAL_URL='https://coslyk.github.io/bingle'
        ;;
    2)
        DEPENDENCY_01='fondo'
        ORIGINAL_URL='https://github.com/calo001/fondo'
        ;;
    esac
    ##########################
    printf "%s\n" "${YELLOW}${ORIGINAL_URL}${RESET}"
    case ${DEBIAN_INSTALLATION_MENU} in
    00)
        non_debian_function
        beta_features_quick_install
        ;;
    01) debian_opt_install_or_remove_01 ;;
    esac
    ########################
    press_enter_to_return
    ${RETURN_TO_WHERE}
}
#####################
debian_opt_note_app() {
    DEPENDENCY_02=''
    RETURN_TO_WHERE='debian_opt_note_app'
    RETURN_TO_MENU='debian_opt_note_app'
    DEBIAN_INSTALLATION_MENU='00'
    INSTALL_APP=$(whiptail --title "NOTE APP" --menu \
        "您想要安装哪个软件?\nWhich software do you want to install? " 0 0 0 \
        "1" "vnote:一款更了解程序员和Markdown的笔记软件" \
        "2" "go-for-it:简洁的备忘软件，借助定时提醒帮助您专注于工作" \
        "3" "wiznote:为知笔记是一款基于云存储的笔记app" \
        "4" "xournalpp:支持PDF手写注释的笔记软件" \
        "5" "notes-up:Markdown编辑和管理器" \
        "6" "qownnotes:开源Markdown笔记和待办事项软件,支持与owncloud云服务集成" \
        "7" "quilter:轻量级markdown编辑器" \
        "8" "textadept:极简、快速和可扩展的跨平台文本编辑器" \
        "0" "🌚 Return to previous menu 返回上级菜单" \
        3>&1 1>&2 2>&3)
    ##############
    case "${INSTALL_APP}" in
    0 | "") debian_opt_menu ;;
    1)
        DEPENDENCY_01='vnote'
        ORIGINAL_URL='https://tamlok.gitee.io/vnote'
        ;;
    2)
        DEPENDENCY_01='go-for-it'
        ORIGINAL_URL='https://github.com/mank319/Go-For-It'
        ;;
    3)
        DEPENDENCY_01='wiznote'
        ORIGINAL_URL='https://www.wiz.cn/wiznote-linux.html'
        ;;
    4)
        DEPENDENCY_01='xournalpp'
        ORIGINAL_URL='https://xournalpp.github.io/'
        ;;
    5)
        DEPENDENCY_01='notes-up'
        ORIGINAL_URL='https://github.com/Philip-Scott/Notes-up'
        ;;
    6)
        DEPENDENCY_01='qownnotes'
        ORIGINAL_URL='https://www.qownnotes.org/'
        ;;
    7)
        DEPENDENCY_01='quilter'
        ORIGINAL_URL='https://github.com/lainsce/quilter'
        ;;
    8)
        DEPENDENCY_01='textadept'
        ORIGINAL_URL='https://foicica.com/textadept/'
        ;;
    esac
    ##########################
    printf "%s\n" "${YELLOW}${ORIGINAL_URL}${RESET}"
    case ${DEBIAN_INSTALLATION_MENU} in
    00)
        non_debian_function
        beta_features_quick_install
        ;;
    01) debian_opt_install_or_remove_01 ;;
    esac
    ########################
    press_enter_to_return
    ${RETURN_TO_WHERE}
}
################
debian_opt_music_app() {
    #16 50 7
    DEPENDENCY_02=''
    RETURN_TO_WHERE='debian_opt_music_app'
    RETURN_TO_MENU='debian_opt_music_app'
    DEBIAN_INSTALLATION_MENU='01'
    INSTALL_APP=$(whiptail --title "MUSIC APP" --menu \
        "您想要安装哪个软件?\n Which software do you want to install? " 0 0 0 \
        "1" "netease-cloud-music-gtk(云音乐)" \
        "2" "vocal(强大美观的播客app)" \
        "3" "flacon(支持从专辑中提取音频文件)" \
        "0" "🌚 Return to previous menu 返回上级菜单" \
        3>&1 1>&2 2>&3)
    ##############
    case "${INSTALL_APP}" in
    0 | "") debian_opt_menu ;;
    1) install_netease_cloud_music_gtk ;;
    2)
        non_debian_function
        install_opt_vocal
        ;;
    3)
        non_debian_function
        install_opt_flacon
        ;;
    esac
    ##########################
    #"7" "feeluown(x64,支持网易云、虾米)" \
    case ${DEBIAN_INSTALLATION_MENU} in
    00) ;;
    01) debian_opt_install_or_remove_01 ;;
    esac
    #此处00菜单不要跳转到beta_features_quick_install
    ########################
    press_enter_to_return
    debian_opt_music_app
}
################
remove_debian_opt_repo() {
    non_debian_function
    rm -vf ${OPT_REPO_LIST} /etc/apt/trusted.gpg.d/bintray-public.key.asc
    apt update
}
##########
install_opt_vocal() {
    DEBIAN_INSTALLATION_MENU='00'
    DEPENDENCY_01='vocal'
    beta_features_quick_install
}
###############
install_opt_flacon() {
    DEBIAN_INSTALLATION_MENU='00'
    DEPENDENCY_01='flacon'
    beta_features_quick_install
}
##################
install_opt_deb_file() {
    cd ".${OPT_APP_NAME}"
    apt-cache show ./${OPT_DEB_NAME}
    apt install -y ./${OPT_DEB_NAME}
    cd /tmp
    rm -rv "${DOWNLOAD_PATH}/.${OPT_APP_NAME}"
    beta_features_install_completed
}
##########
git_clone_opt_deb_01() {
    cd ${DOWNLOAD_PATH}
    git clone --depth=1 -b "${OPT_BRANCH_NAME}" "${OPT_APP_GIT_REPO}" ".${OPT_APP_NAME}"
}
###########
install_debian_netease_cloud_music() {
    DEBIAN_INSTALLATION_MENU='00'
    OPT_APP_NAME='netease-cloud-music-gtk'
    OPT_APP_GIT_REPO="https://gitee.com/ak2/${OPT_APP_NAME}.git"
    OPT_DEB_NAME="${OPT_APP_NAME}_arm64.deb"
    DOWNLOAD_PATH='/tmp'
    git_clone_opt_deb_01
    install_opt_deb_file
}
##############
please_choose_netease_cloud_music_version() {
    if (whiptail --title "sid or buster" --yes-button "sid" --no-button "buster" --yesno "请选择版本！旧版系统(例如ubuntu18.04)请选择buster,\n新版系统(如kali rolling)请选择sid。\n不符合当前系统的版本将导致播放格式错误哦！♪(^∇^*) " 0 0); then
        OPT_BRANCH_NAME='sid_arm64'
    else
        OPT_BRANCH_NAME='arm64'
    fi
}
############
install_debian_buster_or_sid_netease_cloud_music() {
    if grep -q 'sid' /etc/os-release; then
        OPT_BRANCH_NAME='sid_arm64'
    elif grep -q 'buster' /etc/os-release; then
        OPT_BRANCH_NAME='arm64'
    else
        case "${DEBIAN_DISTRO}" in
        ubuntu)
            if ! egrep -q 'Bionic Beaver|Eoan Ermine|Xenial' "/etc/os-release"; then
                OPT_BRANCH_NAME='ubuntu_arm64'
            else
                OPT_BRANCH_NAME='arm64'
            fi
            ;;
        kali) OPT_BRANCH_NAME='sid_arm64' ;;
        *) please_choose_netease_cloud_music_version ;;
        esac
    fi
}
################
install_netease_cloud_music_gtk() {
    DEPENDENCY_01='netease-cloud-music-gtk'
    printf "%s\n" "github url：${YELLOW}https://github.com/gmg137/netease-cloud-music-gtk${RESET}"
    printf "%s\n" "本版本仅兼容debian sid,ubuntu 20.04/20.10及kali rooling,若无法运行,则请自行编译。"
    printf "%s\n" "${DEBIAN_DISTRO}"
    non_debian_function
    if [ $(command -v ${DEPENDENCY_01}) ]; then
        beta_features_install_completed
        printf "%s\n" "是否需要重装？"
        do_you_want_to_continue
    fi
    case ${ARCH_TYPE} in
    arm64)
        install_debian_buster_or_sid_netease_cloud_music
        install_debian_netease_cloud_music
        ;;
    armhf) arch_does_not_support ;;
    *) beta_features_quick_install ;;
    esac
    if [ ! $(command -v netease-cloud-music-gtk) ]; then
        arch_does_not_support
    fi
}
###############
install_pic_go() {
    DEPENDENCY_01='picgo'
    printf "%s\n" "github url：${YELLOW}https://github.com/Molunerfinn/PicGo${RESET}"
}
############################################
explore_debian_opt_repo
