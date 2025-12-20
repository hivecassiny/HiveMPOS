#!/bin/bash
# ====================================================
# HiveMPOS 服务管理脚本
# 版本: 1.0.0
# 支持: CentOS/RHEL 7+, Ubuntu 18.04+, Debian 10+
# ====================================================

set -e

# ==================== 全局配置 ====================
# 脚本版本
SCRIPT_VERSION="1.0.0"

# 程序配置
PROGRAM_NAME="hivempos"
PROGRAM_VERSION="v0.1.042@251217"
PROGRAM_URL="https://github.com/hivecassiny/tesla/releases/download/$PROGRAM_VERSION/$PROGRAM_NAME.tar.gz"
PROGRAM_FILE="$PROGRAM_NAME.tar.gz"

# 安装目录
INSTALL_DIR="/opt/${PROGRAM_NAME}"
BIN_DIR="/usr/local/bin"
SERVICE_DIR="/etc/systemd/system"
CONFIG_DIR="/etc/${PROGRAM_NAME}"
LOG_DIR="/var/log/${PROGRAM_NAME}"
DATA_DIR="/var/lib/${PROGRAM_NAME}"

# 服务配置
SERVICE_NAME="${PROGRAM_NAME}.service"
SERVICE_FILE="${SERVICE_DIR}/${SERVICE_NAME}"

# 网络配置
DEFAULT_PORT="10000"
MAX_CONNECTIONS="65535"

# 语言设置
LANG_FILE="${CONFIG_DIR}/language.conf"
DEFAULT_LANG="zh_CN"
CURRENT_LANG="$DEFAULT_LANG"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# ==================== 语言文件 ====================
declare -A LANG_ZH LANG_EN

# 中文翻译
LANG_ZH=(
    ["title"]="HiveMPOS 服务管理脚本"
    ["version"]="版本"
    ["script_version"]="脚本版本"
    ["app_version"]="程序版本"
    ["current_lang"]="当前语言"
    ["menu_title"]="请选择操作:"
    ["menu_install"]="1. 安装 HiveMPOS"
    ["menu_uninstall"]="2. 卸载 HiveMPOS"
    ["menu_start"]="3. 启动服务"
    ["menu_stop"]="4. 停止服务"
    ["menu_restart"]="5. 重启服务"
    ["menu_status"]="6. 查看服务状态"
    ["menu_logs"]="7. 查看日志"
    ["menu_config"]="8. 查看配置"
    ["menu_connections"]="9. 查看连接数"
    ["menu_language"]="10. 切换语言"
    ["menu_update"]="11. 更新脚本"
    ["menu_backup"]="12. 备份数据"
    ["menu_restore"]="13. 恢复数据"
    ["menu_exit"]="0. 退出"
    ["choice"]="请输入选择 [0-13]: "
    ["invalid_choice"]="无效选择!"
    ["press_enter"]="按回车键继续..."
    ["checking_deps"]="检查系统依赖..."
    ["installing"]="正在安装 HiveMPOS..."
    ["download_progress"]="下载进度:"
    ["extracting"]="正在解压文件..."
    ["creating_dirs"]="创建目录..."
    ["configuring"]="配置系统..."
    ["setting_perms"]="设置权限..."
    ["enabling_service"]="启用服务..."
    ["start_service_q"]="是否启动服务? [y/N]: "
    ["install_success"]="安装成功!"
    ["install_failed"]="安装失败!"
    ["service_started"]="服务已启动"
    ["service_stopped"]="服务已停止"
    ["service_restarted"]="服务已重启"
    ["service_status"]="服务状态:"
    ["not_installed"]="HiveMPOS 未安装!"
    ["uninstall_confirm"]="确定要卸载 HiveMPOS? 所有数据将被删除! [y/N]: "
    ["uninstalling"]="正在卸载..."
    ["uninstall_success"]="卸载成功!"
    ["backup_created"]="备份已创建: "
    ["restore_complete"]="恢复完成!"
    ["update_available"]="发现新版本!"
    ["update_success"]="更新成功!"
    ["current_connections"]="当前连接数:"
    ["max_connections"]="最大连接数:"
    ["file_descriptors"]="文件描述符限制:"
    ["config_info"]="配置信息:"
    ["installed_at"]="安装位置:"
    ["service_file"]="服务文件:"
    ["config_path"]="配置文件:"
    ["log_path"]="日志目录:"
    ["data_path"]="数据目录:"
    ["port_info"]="服务端口:"
    ["select_lang"]="选择语言:"
    ["lang_zh"]="1. 中文"
    ["lang_en"]="2. English"
    ["lang_changed"]="语言已切换!"
    ["requires_root"]="需要root权限!"
    ["checking_update"]="检查更新..."
    ["no_update"]="已是最新版本"
    ["creating_backup"]="创建备份..."
    ["restoring"]="正在恢复..."
    ["enter_backup"]="输入备份文件路径: "
    ["backup_not_found"]="备份文件不存在!"
    ["sys_info"]="系统信息:"
    ["os_version"]="操作系统:"
    ["kernel_version"]="内核版本:"
    ["memory_usage"]="内存使用:"
    ["disk_usage"]="磁盘使用:"
    ["cpu_cores"]="CPU核心:"
    ["load_avg"]="系统负载:"
    ["uptime"]="运行时间:"
)

# English translations
LANG_EN=(
    ["title"]="HiveMPOS Service Management Script"
    ["version"]="Version"
    ["script_version"]="Script Version"
    ["app_version"]="Application Version"
    ["current_lang"]="Current Language"
    ["menu_title"]="Please select an operation:"
    ["menu_install"]="1. Install HiveMPOS"
    ["menu_uninstall"]="2. Uninstall HiveMPOS"
    ["menu_start"]="3. Start Service"
    ["menu_stop"]="4. Stop Service"
    ["menu_restart"]="5. Restart Service"
    ["menu_status"]="6. Check Service Status"
    ["menu_logs"]="7. View Logs"
    ["menu_config"]="8. View Configuration"
    ["menu_connections"]="9. View Connections"
    ["menu_language"]="10. Change Language"
    ["menu_update"]="11. Update Script"
    ["menu_backup"]="12. Backup Data"
    ["menu_restore"]="13. Restore Data"
    ["menu_exit"]="0. Exit"
    ["choice"]="Enter your choice [0-13]: "
    ["invalid_choice"]="Invalid choice!"
    ["press_enter"]="Press Enter to continue..."
    ["checking_deps"]="Checking system dependencies..."
    ["installing"]="Installing HiveMPOS..."
    ["download_progress"]="Download progress:"
    ["extracting"]="Extracting files..."
    ["creating_dirs"]="Creating directories..."
    ["configuring"]="Configuring system..."
    ["setting_perms"]="Setting permissions..."
    ["enabling_service"]="Enabling service..."
    ["start_service_q"]="Start service now? [y/N]: "
    ["install_success"]="Installation successful!"
    ["install_failed"]="Installation failed!"
    ["service_started"]="Service started"
    ["service_stopped"]="Service stopped"
    ["service_restarted"]="Service restarted"
    ["service_status"]="Service status:"
    ["not_installed"]="HiveMPOS is not installed!"
    ["uninstall_confirm"]="Are you sure to uninstall HiveMPOS? All data will be deleted! [y/N]: "
    ["uninstalling"]="Uninstalling..."
    ["uninstall_success"]="Uninstallation successful!"
    ["backup_created"]="Backup created: "
    ["restore_complete"]="Restore completed!"
    ["update_available"]="New version available!"
    ["update_success"]="Update successful!"
    ["current_connections"]="Current connections:"
    ["max_connections"]="Max connections:"
    ["file_descriptors"]="File descriptors limit:"
    ["config_info"]="Configuration Information:"
    ["installed_at"]="Installed at:"
    ["service_file"]="Service file:"
    ["config_path"]="Config path:"
    ["log_path"]="Log directory:"
    ["data_path"]="Data directory:"
    ["port_info"]="Service port:"
    ["select_lang"]="Select language:"
    ["lang_zh"]="1. 中文 (Chinese)"
    ["lang_en"]="2. English"
    ["lang_changed"]="Language changed!"
    ["requires_root"]="Root privileges required!"
    ["checking_update"]="Checking for updates..."
    ["no_update"]="Already up to date"
    ["creating_backup"]="Creating backup..."
    ["restoring"]="Restoring..."
    ["enter_backup"]="Enter backup file path: "
    ["backup_not_found"]="Backup file not found!"
    ["sys_info"]="System Information:"
    ["os_version"]="OS Version:"
    ["kernel_version"]="Kernel Version:"
    ["memory_usage"]="Memory Usage:"
    ["disk_usage"]="Disk Usage:"
    ["cpu_cores"]="CPU Cores:"
    ["load_avg"]="Load Average:"
    ["uptime"]="Uptime:"
)

# ==================== 工具函数 ====================
t() {
    echo -n "${LANG_[$1]}"
}

print_color() {
    local color=$1
    local text=$2
    echo -e "${color}${text}${NC}"
}

print_header() {
    clear
    echo -e "${GREEN}========================================${NC}"
    echo -e "${CYAN}$(t title)${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "$(t script_version): ${YELLOW}${SCRIPT_VERSION}${NC}"
    echo -e "$(t app_version): ${YELLOW}${PROGRAM_VERSION}${NC}"
    echo -e "$(t current_lang): ${YELLOW}${CURRENT_LANG}${NC}"
    echo -e "${GREEN}========================================${NC}"
}

print_menu() {
    echo -e "\n${CYAN}$(t menu_title)${NC}"
    echo -e "${GREEN}$(t menu_install)${NC}"
    echo -e "${GREEN}$(t menu_uninstall)${NC}"
    echo -e "${BLUE}$(t menu_start)${NC}"
    echo -e "${BLUE}$(t menu_stop)${NC}"
    echo -e "${BLUE}$(t menu_restart)${NC}"
    echo -e "${YELLOW}$(t menu_status)${NC}"
    echo -e "${YELLOW}$(t menu_logs)${NC}"
    echo -e "${YELLOW}$(t menu_config)${NC}"
    echo -e "${YELLOW}$(t menu_connections)${NC}"
    echo -e "${MAGENTA}$(t menu_language)${NC}"
    echo -e "${MAGENTA}$(t menu_update)${NC}"
    echo -e "${MAGENTA}$(t menu_backup)${NC}"
    echo -e "${MAGENTA}$(t menu_restore)${NC}"
    echo -e "${RED}$(t menu_exit)${NC}"
    echo -e "${GREEN}========================================${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_color "$RED" "$(t requires_root)"
        exit 1
    fi
}

check_dependencies() {
    print_color "$YELLOW" "$(t checking_deps)"
    
    local deps=("curl" "wget" "tar" "systemctl")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        print_color "$YELLOW" "安装依赖: ${missing[*]}"
        
        if [[ -f /etc/redhat-release ]]; then
            yum install -y "${missing[@]}"
        elif [[ -f /etc/debian_version ]]; then
            apt-get update
            apt-get install -y "${missing[@]}"
        else
            print_color "$RED" "不支持的Linux发行版"
            exit 1
        fi
    fi
}

load_language() {
    if [[ -f "$LANG_FILE" ]]; then
        CURRENT_LANG=$(cat "$LANG_FILE")
    fi
    
    if [[ "$CURRENT_LANG" == "zh_CN" ]]; then
        LANG_=("${LANG_ZH[@]}")
    else
        LANG_=("${LANG_EN[@]}")
        CURRENT_LANG="en_US"
    fi
}

save_language() {
    mkdir -p "$CONFIG_DIR"
    echo "$CURRENT_LANG" > "$LANG_FILE"
}

change_language() {
    print_header
    echo -e "\n${CYAN}$(t select_lang)${NC}"
    echo "1. 中文 (Chinese)"
    echo "2. English"
    echo -n "$(t choice)"
    read -r lang_choice
    
    case $lang_choice in
        1)
            CURRENT_LANG="zh_CN"
            ;;
        2)
            CURRENT_LANG="en_US"
            ;;
        *)
            echo "$(t invalid_choice)"
            return
            ;;
    esac
    
    save_language
    print_color "$GREEN" "$(t lang_changed)"
    sleep 1
}

# ==================== 安装函数 ====================
install_hivempos() {
    print_header
    print_color "$YELLOW" "$(t installing)"
    
    # 检查是否已安装
    if [[ -f "$SERVICE_FILE" ]]; then
        print_color "$YELLOW" "HiveMPOS 已安装，如需重新安装请先卸载"
        return
    fi
    
    # 创建目录
    print_color "$BLUE" "$(t creating_dirs)"
    mkdir -p "$INSTALL_DIR" "$CONFIG_DIR" "$LOG_DIR" "$DATA_DIR" "$BIN_DIR"
    
    # 下载程序
    print_color "$BLUE" "$(t download_progress)"
    if command -v wget &> /dev/null; then
        wget --show-progress -O "/tmp/${PROGRAM_FILE}" "$PROGRAM_URL"
    else
        curl -L -o "/tmp/${PROGRAM_FILE}" "$PROGRAM_URL"
    fi
    
    # 解压文件
    print_color "$BLUE" "$(t extracting)"
    tar -xzf "/tmp/${PROGRAM_FILE}" -C "$INSTALL_DIR"
    
    # 设置权限
    print_color "$BLUE" "$(t setting_perms)"
    chmod +x "$INSTALL_DIR/$PROGRAM_NAME"
    chown -R root:root "$INSTALL_DIR"
    chown -R root:root "$CONFIG_DIR"
    chown -R root:root "$LOG_DIR"
    chown -R root:root "$DATA_DIR"
    
    # 创建软链接
    ln -sf "$INSTALL_DIR/$PROGRAM_NAME" "$BIN_DIR/$PROGRAM_NAME"
    
    # 创建服务文件
    print_color "$BLUE" "$(t configuring)"
    cat > "$SERVICE_FILE" << EOF
[Unit]
Description=HiveMPOS Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$BIN_DIR/$PROGRAM_NAME
Restart=always
RestartSec=5
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=$PROGRAM_NAME
Environment=LANG=$CURRENT_LANG

# 安全设置
NoNewPrivileges=true
LimitNOFILE=65535
LimitNPROC=65535
ProtectSystem=full
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    
    # 重新加载systemd
    systemctl daemon-reload
    
    # 启用服务
    print_color "$BLUE" "$(t enabling_service)"
    systemctl enable "$SERVICE_NAME"
    
    # 优化系统参数
    optimize_system
    
    # 是否启动服务
    echo -n "$(t start_service_q)"
    read -r start_now
    if [[ "$start_now" =~ ^[Yy]$ ]]; then
        systemctl start "$SERVICE_NAME"
        print_color "$GREEN" "$(t service_started)"
    fi
    
    print_color "$GREEN" "$(t install_success)"
    print_config_info
}

optimize_system() {
    # 优化系统连接数
    cat > /etc/sysctl.d/99-hivempos.conf << EOF
# HiveMPOS 优化参数
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 65535
net.core.netdev_max_backlog = 65535
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
fs.file-max = 65535
EOF
    
    sysctl -p /etc/sysctl.d/99-hivempos.conf
    
    # 设置limits
    cat > /etc/security/limits.d/99-hivempos.conf << EOF
# HiveMPOS 资源限制
* soft nofile 65535
* hard nofile 65535
* soft nproc 65535
* hard nproc 65535
root soft nofile 65535
root hard nofile 65535
EOF
}

# ==================== 服务管理函数 ====================
start_service() {
    if [[ ! -f "$SERVICE_FILE" ]]; then
        print_color "$RED" "$(t not_installed)"
        return
    fi
    
    systemctl start "$SERVICE_NAME"
    print_color "$GREEN" "$(t service_started)"
}

stop_service() {
    if [[ ! -f "$SERVICE_FILE" ]]; then
        print_color "$RED" "$(t not_installed)"
        return
    fi
    
    systemctl stop "$SERVICE_NAME"
    print_color "$YELLOW" "$(t service_stopped)"
}

restart_service() {
    if [[ ! -f "$SERVICE_FILE" ]]; then
        print_color "$RED" "$(t not_installed)"
        return
    fi
    
    systemctl restart "$SERVICE_NAME"
    print_color "$GREEN" "$(t service_restarted)"
}

check_status() {
    if [[ ! -f "$SERVICE_FILE" ]]; then
        print_color "$RED" "$(t not_installed)"
        return
    fi
    
    print_color "$CYAN" "$(t service_status)"
    systemctl status "$SERVICE_NAME" --no-pager -l
}

view_logs() {
    if [[ ! -f "$SERVICE_FILE" ]]; then
        print_color "$RED" "$(t not_installed)"
        return
    fi
    
    journalctl -u "$SERVICE_NAME" -f --no-pager -n 50
}

# ==================== 信息函数 ====================
print_config_info() {
    print_color "$CYAN" "$(t config_info)"
    echo -e "$(t installed_at): ${YELLOW}${INSTALL_DIR}${NC}"
    echo -e "$(t service_file): ${YELLOW}${SERVICE_FILE}${NC}"
    echo -e "$(t config_path): ${YELLOW}${CONFIG_DIR}${NC}"
    echo -e "$(t log_path): ${YELLOW}${LOG_DIR}${NC}"
    echo -e "$(t data_path): ${YELLOW}${DATA_DIR}${NC}"
    echo -e "$(t port_info): ${YELLOW}${DEFAULT_PORT}${NC}"
}

view_connections() {
    print_color "$CYAN" "$(t current_connections)"
    
    # 系统连接数
    echo -e "\n${GREEN}TCP 连接统计:${NC}"
    ss -s | head -2
    
    echo -e "\n${GREEN}Established 连接:${NC}"
    ss -tun | grep ESTAB | wc -l
    
    # 文件描述符
    echo -e "\n${GREEN}$(t file_descriptors)${NC}"
    ulimit -n
    
    # 最大连接数
    echo -e "\n${GREEN}$(t max_connections)${NC}"
    sysctl net.core.somaxconn | awk '{print $3}'
    
    # 按状态统计
    echo -e "\n${GREEN}按状态统计:${NC}"
    ss -tan | awk '{print $1}' | sort | uniq -c | sort -rn
}

view_system_info() {
    print_color "$CYAN" "$(t sys_info)"
    
    # OS信息
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        echo -e "$(t os_version): ${YELLOW}$PRETTY_NAME${NC}"
    fi
    
    # 内核版本
    echo -e "$(t kernel_version): ${YELLOW}$(uname -r)${NC}"
    
    # CPU信息
    echo -e "$(t cpu_cores): ${YELLOW}$(nproc)${NC}"
    
    # 内存使用
    echo -e "$(t memory_usage):"
    free -h
    
    # 磁盘使用
    echo -e "\n$(t disk_usage):"
    df -h /
    
    # 系统负载
    echo -e "\n$(t load_avg): ${YELLOW}$(uptime | awk -F'load average:' '{print $2}')${NC}"
    
    # 运行时间
    echo -e "$(t uptime): ${YELLOW}$(uptime -p)${NC}"
}

# ==================== 备份恢复函数 ====================
backup_data() {
    if [[ ! -f "$SERVICE_FILE" ]]; then
        print_color "$RED" "$(t not_installed)"
        return
    fi
    
    local backup_dir="/var/backups/$PROGRAM_NAME"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${backup_dir}/backup_${timestamp}.tar.gz"
    
    mkdir -p "$backup_dir"
    
    print_color "$YELLOW" "$(t creating_backup)"
    
    # 停止服务
    systemctl stop "$SERVICE_NAME"
    
    # 创建备份
    tar -czf "$backup_file" \
        "$CONFIG_DIR" \
        "$DATA_DIR" \
        "$LOG_DIR" \
        "$INSTALL_DIR" \
        "$SERVICE_FILE" \
        2>/dev/null || true
    
    # 启动服务
    systemctl start "$SERVICE_NAME"
    
    print_color "$GREEN" "$(t backup_created)${backup_file}"
    
    # 显示备份信息
    echo -e "\n${CYAN}备份信息:${NC}"
    ls -lh "$backup_file"
    echo -e "备份时间: $(date)"
}

restore_data() {
    echo -n "$(t enter_backup)"
    read -r backup_file
    
    if [[ ! -f "$backup_file" ]]; then
        print_color "$RED" "$(t backup_not_found)"
        return
    fi
    
    print_color "$YELLOW" "$(t restoring)"
    
    # 停止服务
    systemctl stop "$SERVICE_NAME"
    
    # 恢复数据
    tar -xzf "$backup_file" -C /
    
    # 启动服务
    systemctl start "$SERVICE_NAME"
    systemctl daemon-reload
    
    print_color "$GREEN" "$(t restore_complete)"
}

# ==================== 卸载函数 ====================
uninstall_hivempos() {
    if [[ ! -f "$SERVICE_FILE" ]]; then
        print_color "$RED" "$(t not_installed)"
        return
    fi
    
    echo -n "$(t uninstall_confirm)"
    read -r confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        return
    fi
    
    print_color "$YELLOW" "$(t uninstalling)"
    
    # 停止服务
    systemctl stop "$SERVICE_NAME" 2>/dev/null || true
    systemctl disable "$SERVICE_NAME" 2>/dev/null || true
    
    # 删除文件
    rm -f "$SERVICE_FILE"
    rm -f "$BIN_DIR/$PROGRAM_NAME"
    
    # 删除目录
    rm -rf "$INSTALL_DIR"
    rm -rf "$CONFIG_DIR"
    rm -rf "$LOG_DIR"
    rm -rf "$DATA_DIR"
    
    # 删除配置文件
    rm -f /etc/sysctl.d/99-hivempos.conf
    rm -f /etc/security/limits.d/99-hivempos.conf
    
    # 重新加载systemd
    systemctl daemon-reload
    
    print_color "$GREEN" "$(t uninstall_success)"
}

# ==================== 更新函数 ====================
update_script() {
    print_color "$YELLOW" "$(t checking_update)"
    
    # 这里可以添加检查更新的逻辑
    # 暂时显示无更新
    print_color "$GREEN" "$(t no_update)"
    
    # 示例更新逻辑:
    # NEW_VERSION=$(curl -s https://api.github.com/repos/your/repo/releases/latest | grep tag_name | cut -d'"' -f4)
    # if [[ "$NEW_VERSION" != "$SCRIPT_VERSION" ]]; then
    #     print_color "$GREEN" "$(t update_available) $NEW_VERSION"
    #     # 下载并更新脚本
    # else
    #     print_color "$GREEN" "$(t no_update)"
    # fi
}

# ==================== 主函数 ====================
main() {
    # 检查root权限
    check_root
    
    # 加载语言
    load_language
    
    # 检查依赖
    check_dependencies
    
    while true; do
        print_header
        print_menu
        
        echo -n "$(t choice)"
        read -r choice
        
        case $choice in
            1)
                install_hivempos
                ;;
            2)
                uninstall_hivempos
                ;;
            3)
                start_service
                ;;
            4)
                stop_service
                ;;
            5)
                restart_service
                ;;
            6)
                check_status
                ;;
            7)
                view_logs
                ;;
            8)
                print_config_info
                ;;
            9)
                view_connections
                ;;
            10)
                change_language
                continue  # 重新加载语言
                ;;
            11)
                update_script
                ;;
            12)
                backup_data
                ;;
            13)
                restore_data
                ;;
            0)
                echo "再见! Goodbye!"
                exit 0
                ;;
            *)
                print_color "$RED" "$(t invalid_choice)"
                ;;
        esac
        
        echo -e "\n$(t press_enter)"
        read -r
    done
}

# 脚本入口
trap 'echo -e "\n${RED}脚本被中断${NC}"; exit 1' INT TERM

# 检查是否带语言参数
if [[ "$1" == "--lang" ]] || [[ "$1" == "-l" ]]; then
    case "$2" in
        zh|zh_CN|cn)
            CURRENT_LANG="zh_CN"
            ;;
        en|en_US|us)
            CURRENT_LANG="en_US"
            ;;
    esac
    save_language
fi

main "$@"
