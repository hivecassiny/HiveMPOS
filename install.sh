#!/bin/bash
# Tesla HiveMPOS 安装管理脚本
# 版本: 1.0.0

# ==================== 全局变量配置 ====================
# 脚本版本
SCRIPT_VERSION="1.0.2"

# 软件信息
SOFTWARE_NAME="hivempos"
SOFTWARE_VERSION="v0.1.042@251217"
DOWNLOAD_URL="https://github.com/hivecassiny/tesla/releases/download/$SOFTWARE_VERSION/$SOFTWARE_NAME.tar.gz"
ARCHIVE_NAME="$SOFTWARE_NAME.tar.gz"
EXTRACTED_NAME="hivempos"

# 安装路径
INSTALL_DIR="/opt/$SOFTWARE_NAME"
SERVICE_NAME="$SOFTWARE_NAME"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
CONFIG_FILE="/etc/$SOFTWARE_NAME.conf"
LOG_DIR="/var/log/$SOFTWARE_NAME"

# 默认语言 (1=中文, 2=English)
DEFAULT_LANG=1
CURRENT_LANG=$DEFAULT_LANG

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==================== 语言配置 ====================
declare -A LANG_STRINGS

# 中文字符串
LANG_STRINGS[1,title]="=== Tesla HiveMPOS 管理脚本 ==="
LANG_STRINGS[1,script_version]="脚本版本"
LANG_STRINGS[1,software_version]="软件版本"
LANG_STRINGS[1,menu_title]="请选择操作"
LANG_STRINGS[1,menu_install]="1. 安装"
LANG_STRINGS[1,menu_uninstall]="2. 卸载"
LANG_STRINGS[1,menu_restart]="3. 重启服务"
LANG_STRINGS[1,menu_stop]="4. 停止服务"
LANG_STRINGS[1,menu_start]="5. 启动服务"
LANG_STRINGS[1,menu_socket]="6. 查看Socket最大连接数"
LANG_STRINGS[1,menu_status]="7. 查看服务状态"
LANG_STRINGS[1,menu_logs]="8. 查看日志"
LANG_STRINGS[1,menu_config]="9. 查看配置"
LANG_STRINGS[1,menu_exit]="0. 退出"
LANG_STRINGS[1,choose_option]="请输入选项 [0-9]: "
LANG_STRINGS[1,invalid_option]="无效选项，请重新输入"
LANG_STRINGS[1,goodbye]="再见！"
LANG_STRINGS[1,require_root]="此脚本需要root权限运行！"
LANG_STRINGS[1,checking_deps]="检查依赖工具..."
LANG_STRINGS[1,dep_installed]="已安装"
LANG_STRINGS[1,dep_not_installed]="未安装，正在安装..."
LANG_STRINGS[1,dep_install_failed]="安装失败，请手动安装"
LANG_STRINGS[1,downloading]="正在下载软件..."
LANG_STRINGS[1,download_failed]="下载失败"
LANG_STRINGS[1,extracting]="正在解压文件..."
LANG_STRINGS[1,extract_failed]="解压失败"
LANG_STRINGS[1,creating_dirs]="创建目录..."
LANG_STRINGS[1,copying_files]="复制文件..."
LANG_STRINGS[1,set_socket]="设置Socket最大连接数"
LANG_STRINGS[1,enter_socket]="请输入Socket最大连接数 (默认: 65535): "
LANG_STRINGS[1,creating_service]="创建服务..."
LANG_STRINGS[1,reload_daemon]="重新加载systemd..."
LANG_STRINGS[1,enable_service]="启用服务..."
LANG_STRINGS[1,install_success]="安装成功！"
LANG_STRINGS[1,reboot_prompt]="需要重启系统使Socket设置生效"
LANG_STRINGS[1,reboot_now]="是否立即重启？ (y/n): "
LANG_STRINGS[1,reboot_later]="稍后请手动重启系统"
LANG_STRINGS[1,uninstalling]="正在卸载..."
LANG_STRINGS[1,stop_service]="停止服务..."
LANG_STRINGS[1,disable_service]="禁用服务..."
LANG_STRINGS[1,remove_files]="删除文件..."
LANG_STRINGS[1,uninstall_success]="卸载成功"
LANG_STRINGS[1,restarting]="重启服务..."
LANG_STRINGS[1,stopping]="停止服务..."
LANG_STRINGS[1,starting]="启动服务..."
LANG_STRINGS[1,service_status]="服务状态:"
LANG_STRINGS[1,socket_current]="当前Socket最大连接数:"
LANG_STRINGS[1,view_logs]="查看日志 (Ctrl+C退出):"
LANG_STRINGS[1,view_config]="配置文件内容:"
LANG_STRINGS[1,config_not_found]="配置文件不存在"
LANG_STRINGS[1,press_enter]="按Enter键继续..."
LANG_STRINGS[1,operation_failed]="操作失败"
LANG_STRINGS[1,operation_success]="操作成功"

# 英文字符串
LANG_STRINGS[2,title]="=== Tesla HiveMPOS Management Script ==="
LANG_STRINGS[2,script_version]="Script Version"
LANG_STRINGS[2,software_version]="Software Version"
LANG_STRINGS[2,menu_title]="Please select an operation"
LANG_STRINGS[2,menu_install]="1. Install"
LANG_STRINGS[2,menu_uninstall]="2. Uninstall"
LANG_STRINGS[2,menu_restart]="3. Restart Service"
LANG_STRINGS[2,menu_stop]="4. Stop Service"
LANG_STRINGS[2,menu_start]="5. Start Service"
LANG_STRINGS[2,menu_socket]="6. View Socket Max Connections"
LANG_STRINGS[2,menu_status]="7. View Service Status"
LANG_STRINGS[2,menu_logs]="8. View Logs"
LANG_STRINGS[2,menu_config]="9. View Configuration"
LANG_STRINGS[2,menu_exit]="0. Exit"
LANG_STRINGS[2,choose_option]="Enter option [0-9]: "
LANG_STRINGS[2,invalid_option]="Invalid option, please try again"
LANG_STRINGS[2,goodbye]="Goodbye!"
LANG_STRINGS[2,require_root]="This script requires root privileges!"
LANG_STRINGS[2,checking_deps]="Checking dependencies..."
LANG_STRINGS[2,dep_installed]="Installed"
LANG_STRINGS[2,dep_not_installed]="Not installed, installing..."
LANG_STRINGS[2,dep_install_failed]="Installation failed, please install manually"
LANG_STRINGS[2,downloading]="Downloading software..."
LANG_STRINGS[2,download_failed]="Download failed"
LANG_STRINGS[2,extracting]="Extracting files..."
LANG_STRINGS[2,extract_failed]="Extraction failed"
LANG_STRINGS[2,creating_dirs]="Creating directories..."
LANG_STRINGS[2,copying_files]="Copying files..."
LANG_STRINGS[2,set_socket]="Setting Socket max connections"
LANG_STRINGS[2,enter_socket]="Enter Socket max connections (default: 65535): "
LANG_STRINGS[2,creating_service]="Creating service..."
LANG_STRINGS[2,reload_daemon]="Reloading systemd..."
LANG_STRINGS[2,enable_service]="Enabling service..."
LANG_STRINGS[2,install_success]="Installation successful!"
LANG_STRINGS[2,reboot_prompt]="System reboot required for Socket settings to take effect"
LANG_STRINGS[2,reboot_now]="Reboot now? (y/n): "
LANG_STRINGS[2,reboot_later]="Please reboot manually later"
LANG_STRINGS[2,uninstalling]="Uninstalling..."
LANG_STRINGS[2,stop_service]="Stopping service..."
LANG_STRINGS[2,disable_service]="Disabling service..."
LANG_STRINGS[2,remove_files]="Removing files..."
LANG_STRINGS[2,uninstall_success]="Uninstall successful"
LANG_STRINGS[2,restarting]="Restarting service..."
LANG_STRINGS[2,stopping]="Stopping service..."
LANG_STRINGS[2,starting]="Starting service..."
LANG_STRINGS[2,service_status]="Service Status:"
LANG_STRINGS[2,socket_current]="Current Socket max connections:"
LANG_STRINGS[2,view_logs]="Viewing logs (Ctrl+C to exit):"
LANG_STRINGS[2,view_config]="Configuration file content:"
LANG_STRINGS[2,config_not_found]="Configuration file not found"
LANG_STRINGS[2,press_enter]="Press Enter to continue..."
LANG_STRINGS[2,operation_failed]="Operation failed"
LANG_STRINGS[2,operation_success]="Operation successful"

# ==================== 工具函数 ====================
print_message() {
    local key="$1"
    echo -e "${BLUE}${LANG_STRINGS[$CURRENT_LANG,$key]}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

press_enter() {
    read -rp "$(print_message press_enter)"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "$(print_message require_root)"
        exit 1
    fi
}

check_dependencies() {
    print_message checking_deps
    
    local deps=("curl" "wget" "tar" "systemctl")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        for dep in "${missing_deps[@]}"; do
            print_warning "$dep $(print_message dep_not_installed)"
            
            # 根据不同的Linux发行版安装依赖
            if command -v apt &> /dev/null; then
                apt update && apt install -y "$dep"
            elif command -v yum &> /dev/null; then
                yum install -y "$dep"
            elif command -v dnf &> /dev/null; then
                dnf install -y "$dep"
            elif command -v zypper &> /dev/null; then
                zypper install -y "$dep"
            elif command -v pacman &> /dev/null; then
                pacman -Sy --noconfirm "$dep"
            else
                print_error "$dep $(print_message dep_install_failed)"
                return 1
            fi
            
            if [[ $? -eq 0 ]]; then
                print_success "$dep $(print_message dep_installed)"
            else
                print_error "$dep $(print_message dep_install_failed)"
                return 1
            fi
        done
    fi
    
    return 0
}

# ==================== 主功能函数 ====================
set_socket_connections() {
    print_message set_socket
    
    local socket_max=65535
    read -rp "$(print_message enter_socket)" input
    
    if [[ -n "$input" ]] && [[ "$input" =~ ^[0-9]+$ ]]; then
        socket_max=$input
    fi
    
    # 设置当前会话的socket限制
    ulimit -n "$socket_max" 2>/dev/null
    
    # 设置系统级的限制
    cat > /etc/security/limits.d/99-hivempos.conf << EOF
* soft nofile $socket_max
* hard nofile $socket_max
root soft nofile $socket_max
root hard nofile $socket_max
EOF
    
    # 设置systemd服务限制
    mkdir -p /etc/systemd/system.conf.d/
    cat > /etc/systemd/system.conf.d/99-hivempos.conf << EOF
[Manager]
DefaultLimitNOFILE=$socket_max
EOF
    
    print_success "$(print_message operation_success)"
    return 0
}

get_socket_connections() {
    local current_limit=$(ulimit -n 2>/dev/null || echo "Unknown")
    print_message socket_current
    echo "Soft limit: $(ulimit -Sn)"
    echo "Hard limit: $(ulimit -Hn)"
}

install_service() {
    print_info "$(print_message installing)"
    
    # 检查依赖
    if ! check_dependencies; then
        print_error "$(print_message operation_failed)"
        return 1
    fi
    
    # 下载软件
    print_message downloading
    if command -v wget &> /dev/null; then
        wget -O "/tmp/$ARCHIVE_NAME" "$DOWNLOAD_URL"
    elif command -v curl &> /dev/null; then
        curl -L -o "/tmp/$ARCHIVE_NAME" "$DOWNLOAD_URL"
    else
        print_error "$(print_message download_failed)"
        return 1
    fi
    
    if [[ $? -ne 0 ]] || [[ ! -f "/tmp/$ARCHIVE_NAME" ]]; then
        print_error "$(print_message download_failed)"
        return 1
    fi
    
    print_success "$(print_message operation_success)"
    
    # 解压文件
    print_message extracting
    tar -xzf "/tmp/$ARCHIVE_NAME" -C /tmp/
    if [[ $? -ne 0 ]] || [[ ! -d "/tmp/$EXTRACTED_NAME" ]]; then
        print_error "$(print_message extract_failed)"
        return 1
    fi
    
    print_success "$(print_message operation_success)"
    
    # 创建目录
    print_message creating_dirs
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$LOG_DIR"
    
    # 复制文件
    print_message copying_files
    cp -r "/tmp/$EXTRACTED_NAME/"* "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/"* 2>/dev/null
    
    # 设置socket连接数
    set_socket_connections
    
    # 创建服务文件
    print_message creating_service
    cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Tesla HiveMPOS Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/$SOFTWARE_NAME
Restart=on-failure
RestartSec=10
StandardOutput=append:$LOG_DIR/service.log
StandardError=append:$LOG_DIR/error.log
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    
    # 创建配置文件示例
    if [[ ! -f "$CONFIG_FILE" ]]; then
        cat > "$CONFIG_FILE" << EOF
# Tesla HiveMPOS Configuration
# Generated on $(date)

# Service settings
SERVICE_PORT=8080
LOG_LEVEL=info
MAX_CONNECTIONS=1000

# Add your custom configuration below
EOF
    fi
    
    # 重新加载systemd并启用服务
    print_message reload_daemon
    systemctl daemon-reload
    
    print_message enable_service
    systemctl enable "$SERVICE_NAME"
    
    # 启动服务
    systemctl start "$SERVICE_NAME"
    
    # 清理临时文件
    rm -f "/tmp/$ARCHIVE_NAME"
    rm -rf "/tmp/$EXTRACTED_NAME"
    
    print_success "$(print_message install_success)"
    
    # 询问是否重启
    print_warning "$(print_message reboot_prompt)"
    read -rp "$(print_message reboot_now)" reboot_choice
    
    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        reboot
    else
        print_info "$(print_message reboot_later)"
    fi
    
    return 0
}

uninstall_service() {
    print_info "$(print_message uninstalling)"
    
    # 停止服务
    print_message stop_service
    systemctl stop "$SERVICE_NAME" 2>/dev/null
    
    # 禁用服务
    print_message disable_service
    systemctl disable "$SERVICE_NAME" 2>/dev/null
    
    # 删除服务文件
    rm -f "$SERVICE_FILE"
    
    # 重新加载systemd
    systemctl daemon-reload
    
    # 删除安装文件
    print_message remove_files
    rm -rf "$INSTALL_DIR"
    rm -rf "$LOG_DIR"
    rm -f "$CONFIG_FILE"
    rm -f /etc/security/limits.d/99-hivempos.conf
    rm -f /etc/systemd/system.conf.d/99-hivempos.conf
    
    print_success "$(print_message uninstall_success)"
    return 0
}

restart_service() {
    print_info "$(print_message restarting)"
    systemctl restart "$SERVICE_NAME"
    
    if [[ $? -eq 0 ]]; then
        print_success "$(print_message operation_success)"
    else
        print_error "$(print_message operation_failed)"
    fi
}

stop_service() {
    print_info "$(print_message stopping)"
    systemctl stop "$SERVICE_NAME"
    
    if [[ $? -eq 0 ]]; then
        print_success "$(print_message operation_success)"
    else
        print_error "$(print_message operation_failed)"
    fi
}

start_service() {
    print_info "$(print_message starting)"
    systemctl start "$SERVICE_NAME"
    
    if [[ $? -eq 0 ]]; then
        print_success "$(print_message operation_success)"
    else
        print_error "$(print_message operation_failed)"
    fi
}

view_service_status() {
    print_message service_status
    systemctl status "$SERVICE_NAME"
}

view_logs() {
    local log_file="$LOG_DIR/service.log"
    
    if [[ ! -f "$log_file" ]]; then
        print_error "Log file not found: $log_file"
        return 1
    fi
    
    print_message view_logs
    tail -f "$log_file"
}

view_config() {
    print_message view_config
    
    if [[ -f "$CONFIG_FILE" ]]; then
        cat "$CONFIG_FILE"
    else
        print_message config_not_found
    fi
}

# ==================== 菜单函数 ====================
show_language_menu() {
    clear
    echo "=========================================="
    echo "    Tesla HiveMPOS Management Script"
    echo "=========================================="
    echo ""
    echo "请选择语言 / Please select language:"
    echo "1. 中文 (Chinese)"
    echo "2. English"
    echo ""
    read -rp "选择 / Choice [1-2]: " lang_choice
    
    case $lang_choice in
        1) CURRENT_LANG=1 ;;
        2) CURRENT_LANG=2 ;;
        *) CURRENT_LANG=$DEFAULT_LANG ;;
    esac
}

show_menu() {
    clear
    echo "=========================================="
    echo "    $(print_message title)"
    echo "=========================================="
    echo "$(print_message script_version): $SCRIPT_VERSION"
    echo "$(print_message software_version): $SOFTWARE_VERSION"
    echo "=========================================="
    echo ""
    echo "$(print_message menu_title):"
    echo "$(print_message menu_install)"
    echo "$(print_message menu_uninstall)"
    echo "$(print_message menu_restart)"
    echo "$(print_message menu_stop)"
    echo "$(print_message menu_start)"
    echo "$(print_message menu_socket)"
    echo "$(print_message menu_status)"
    echo "$(print_message menu_logs)"
    echo "$(print_message menu_config)"
    echo "$(print_message menu_exit)"
    echo ""
}

# ==================== 主程序 ====================
main() {
    # 检查root权限
    check_root
    
    # 显示语言选择菜单
    show_language_menu
    
    # 主循环
    while true; do
        show_menu
        
        read -rp "$(print_message choose_option)" option
        
        case $option in
            0)
                print_message goodbye
                exit 0
                ;;
            1)
                install_service
                press_enter
                ;;
            2)
                uninstall_service
                press_enter
                ;;
            3)
                restart_service
                press_enter
                ;;
            4)
                stop_service
                press_enter
                ;;
            5)
                start_service
                press_enter
                ;;
            6)
                get_socket_connections
                press_enter
                ;;
            7)
                view_service_status
                press_enter
                ;;
            8)
                view_logs
                ;;
            9)
                view_config
                press_enter
                ;;
            *)
                print_error "$(print_message invalid_option)"
                press_enter
                ;;
        esac
    done
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
