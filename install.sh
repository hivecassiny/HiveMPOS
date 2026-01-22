#!/bin/bash
# HiveMPOS 安装管理脚本
# 版本: 1.0.15

# Restart=on-failure ## 重启判断非0才重启

# ==================== 全局变量配置 ====================
# 脚本版本
SCRIPT_VERSION="1.0.24"

# 软件信息
SOFTWARE_NAME="hivempos"
ARCHIVE_NAME="$SOFTWARE_NAME.tar.gz"
EXTRACTED_NAME="hivempos_linux_amd64"

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
LANG_STRINGS[1,title]="=== HiveMPOS 管理脚本 ==="
LANG_STRINGS[1,access_address]="访问地址"
LANG_STRINGS[1,public_ip]="公网IP"
LANG_STRINGS[1,local_ip]="内网IP"
LANG_STRINGS[1,access_url]="请使用浏览器访问"
LANG_STRINGS[1,unable_get_public_ip]="无法获取公网IP，请检查网络"
LANG_STRINGS[1,script_version]="脚本版本"
LANG_STRINGS[1,software_version]="软件版本"
LANG_STRINGS[1,default_port]="首次运行没有账号密码浏览器直接访问"
LANG_STRINGS[1,default_port_self]="本机访问"
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
LANG_STRINGS[1,choose_option]="请输入选项 [0-10]: "
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
LANG_STRINGS[1,fetching_version]="正在从GitHub获取最新版本号..."
LANG_STRINGS[1,curl_failed]="curl请求失败 (退出码:"
LANG_STRINGS[1,wget_failed]="wget请求失败 (退出码:"
LANG_STRINGS[1,tools_required]="需要curl或wget工具来获取版本信息"
LANG_STRINGS[1,parse_failed]="无法从GitHub页面解析版本号"
LANG_STRINGS[1,invalid_format]="获取到无效的版本号格式:"
LANG_STRINGS[1,version_success]="成功获取最新版本:"
LANG_STRINGS[1,version_failed]="无法获取最新版本号，脚本无法继续执行"
LANG_STRINGS[1,check_network]="请检查："
LANG_STRINGS[1,check1]="1. 网络连接是否正常"
LANG_STRINGS[1,check2]="2. GitHub仓库是否有已发布的版本"
LANG_STRINGS[1,check3]="3. 仓库地址是否正确: https://github.com/hivecassiny/HiveMPOS"
LANG_STRINGS[1,script_terminated]="脚本终止"
LANG_STRINGS[1,sof_installed]="已经安装不能重新安装"
LANG_STRINGS[1,menu_update]="10. 更新软件"
LANG_STRINGS[1,updating]="正在更新软件..."
LANG_STRINGS[1,update_success]="更新成功！"
LANG_STRINGS[1,update_failed]="更新失败"
LANG_STRINGS[1,not_installed]="软件未安装，请先安装"
LANG_STRINGS[1,checking_update]="检查更新..."
LANG_STRINGS[1,latest_version]="已经是最新版本"
LANG_STRINGS[1,new_version_available]="发现新版本"
LANG_STRINGS[1,current_version]="当前版本"
LANG_STRINGS[1,update_confirm]="是否要更新到最新版本？ (y/n): "

# 英文字符串
LANG_STRINGS[2,title]="=== HiveMPOS Management Script ==="
LANG_STRINGS[2,access_address]="Access Address"
LANG_STRINGS[2,public_ip]="Public IP"
LANG_STRINGS[2,local_ip]="Local IP"
LANG_STRINGS[2,access_url]="Please access using browser"
LANG_STRINGS[2,unable_get_public_ip]="Unable to get public IP, check network"
LANG_STRINGS[2,script_version]="Script Version"
LANG_STRINGS[2,software_version]="Software Version"
LANG_STRINGS[2,default_port]="First run without account password browser direct access"
LANG_STRINGS[2,default_port_self]="local host access"
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
LANG_STRINGS[2,choose_option]="Enter option [0-10]: "
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
LANG_STRINGS[2,fetching_version]="Fetching latest version from GitHub..."
LANG_STRINGS[2,curl_failed]="curl request failed (exit code:"
LANG_STRINGS[2,wget_failed]="wget request failed (exit code:"
LANG_STRINGS[2,tools_required]="curl or wget is required to fetch version information"
LANG_STRINGS[2,parse_failed]="Unable to parse version number from GitHub page"
LANG_STRINGS[2,invalid_format]="Invalid version number format retrieved:"
LANG_STRINGS[2,version_success]="Successfully retrieved latest version:"
LANG_STRINGS[2,version_failed]="Unable to retrieve latest version, script cannot continue"
LANG_STRINGS[2,check_network]="Please check:"
LANG_STRINGS[2,check1]="1. Network connectivity"
LANG_STRINGS[2,check2]="2. Whether the GitHub repository has published releases"
LANG_STRINGS[2,check3]="3. Repository URL is correct: https://github.com/hivecassiny/HiveMPOS"
LANG_STRINGS[2,script_terminated]="Script terminated"
LANG_STRINGS[2,sof_installed]="sof was installed..."
LANG_STRINGS[2,menu_update]="10. Update Software"
LANG_STRINGS[2,updating]="Updating software..."
LANG_STRINGS[2,update_success]="Update successful!"
LANG_STRINGS[2,update_failed]="Update failed"
LANG_STRINGS[2,not_installed]="Software not installed, please install first"
LANG_STRINGS[2,checking_update]="Checking for updates..."
LANG_STRINGS[2,latest_version]="Already latest version"
LANG_STRINGS[2,new_version_available]="New version available"
LANG_STRINGS[2,current_version]="Current version"
LANG_STRINGS[2,update_confirm]="Update to latest version? (y/n): "


get_public_ip() {
    local public_ip=""
    
    # 尝试多个公网IP查询服务
    local ip_services=(
        "https://api.ipify.org"
        "https://ifconfig.me/ip"
        "https://ident.me"
        "https://ipecho.net/plain"
        "https://icanhazip.com"
    )
    
    for service in "${ip_services[@]}"; do
        if command -v curl &> /dev/null; then
            public_ip=$(curl -s --connect-timeout 5 "$service")
        elif command -v wget &> /dev/null; then
            public_ip=$(wget -qO- --timeout=5 "$service")
        fi
        
        # 检查是否是有效的IP地址
        if [[ -n "$public_ip" ]] && [[ "$public_ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            echo "$public_ip"
            return 0
        fi
    done
    
    echo ""
    return 1
}


get_local_ip() {
    local local_ip=""
    
    # 尝试获取内网IP
    if command -v ip &> /dev/null; then
        local_ip=$(ip route get 1 | awk '{print $NF;exit}' 2>/dev/null)
    elif command -v hostname &> /dev/null; then
        local_ip=$(hostname -I | awk '{print $1}' 2>/dev/null)
    fi
    if [[ -z "$local_ip" ]]; then
        echo "127.0.0.1"
    else
        echo "$local_ip"
    fi
}


show_access_url() {
    echo ""
    echo "=========================================="
    echo "    $(print_message access_address)"
    echo "=========================================="
    
    # 获取公网IP
    local public_ip=$(get_public_ip)
    
    if [[ -n "$public_ip" ]]; then
        echo -e "$(print_message public_ip): ${GREEN}$public_ip${NC}"
        echo -e "$(print_message access_url): ${YELLOW}http://$public_ip:10000${NC}"
    else
        print_warning "$(print_message unable_get_public_ip)"
    fi
    
    # 获取内网IP
    # local local_ip=$(get_local_ip)
    # if [[ -n "$local_ip" ]]; then
    #     echo -e "$(print_message local_ip): ${BLUE}$local_ip${NC}"
    #     echo -e "$(print_message access_url): ${YELLOW}http://$local_ip:10000${NC}"
    # fi
    
    echo "=========================================="
    echo ""
}

# ==================== get_latest_version_from_page函数（优化版） ====================
get_latest_version_from_page() {
    echo "$(print_message fetching_version)" >&2
    
    local repo_url="https://github.com/hivecassiny/HiveMPOS/releases"
    local latest_tag=""
    
    local version_pattern='releases/tag/(v[0-9]+\.[0-9]+\.[0-9]+[^"]*)'
    
    if command -v curl &> /dev/null; then
        latest_tag=$(curl -s -L "$repo_url" | grep -oE "$version_pattern" | head -1 | cut -d'/' -f3)
        local curl_status=$?
        
        if [[ $curl_status -ne 0 ]]; then
            echo "$(print_message curl_failed) $curl_status)" >&2
            return 1
        fi
    elif command -v wget &> /dev/null; then
        latest_tag=$(wget -qO- "$repo_url" | grep -oE "$version_pattern" | head -1 | cut -d'/' -f3)
        local wget_status=$?
        
        if [[ $wget_status -ne 0 ]]; then
            echo "$(print_message wget_failed) $wget_status)" >&2
            return 1
        fi
    else
        echo "$(print_message tools_required)" >&2
        return 1
    fi
    
    if [[ -z "$latest_tag" ]]; then
        echo "$(print_message parse_failed)" >&2
        return 1
    fi
    
    if [[ ! "$latest_tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        echo "$(print_message invalid_format) $latest_tag" >&2
        return 1
    fi
    
    echo "$latest_tag"
    return 0
}

# ==================== init_software_version函数（优化版） ====================
init_software_version() {
    # 首先尝试自动获取最新版本
    local latest_version
    latest_version=$(get_latest_version_from_page)
    
    if [[ $? -eq 0 ]] && [[ -n "$latest_version" ]]; then
        SOFTWARE_VERSION="$latest_version"
        print_success "$(print_message version_success) $SOFTWARE_VERSION"
    else
        # 如果获取失败，直接退出
        print_error "$(print_message version_failed)"
        print_info "$(print_message check_network)"
        echo "  1. $(print_message check1)"
        echo "  2. $(print_message check2)"
        echo "  3. $(print_message check3)"
        echo ""
        print_error "$(print_message script_terminated)"
        exit 1
    fi
    
    # 设置下载URL
    DOWNLOAD_URL="https://github.com/hivecassiny/HiveMPOS/releases/download/$SOFTWARE_VERSION/${SOFTWARE_NAME}_linux_amd64.tar.gz"
}

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

# ==================== 更新函数 ====================
update_service() {
    print_info "$(print_message checking_update)"

    # 检查软件是否已安装
    if [[ ! -f "$INSTALL_DIR/$SOFTWARE_NAME" ]]; then
        print_error "$(print_message not_installed)"
        return 1
    fi
    # 确认更新
    read -rp "$(print_message update_confirm)" confirm_update
    
    if [[ ! "$confirm_update" =~ ^[Yy]$ ]]; then
        print_info "更新已取消"
        return 0
    fi

    # 开始更新
    print_info "$(print_message updating)"

    # 停止服务
    systemctl stop "$SERVICE_NAME" 2>/dev/null

    # 删除原来的执行文件
    rm "$INSTALL_DIR/"${SOFTWARE_NAME}

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

    # 复制文件
    print_message copying_files
    cp -r "/tmp/$EXTRACTED_NAME/"${SOFTWARE_NAME} "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/"* 2>/dev/null

    # 清理临时文件
    rm -f "/tmp/$ARCHIVE_NAME"
    rm -rf "/tmp/$EXTRACTED_NAME"

    # 启动服务
    systemctl start "$SERVICE_NAME"

    if [[ $? -eq 0 ]]; then
        print_success "$(print_message update_success)"
        
        # 查看服务状态
        sleep 2
        systemctl status "$SERVICE_NAME" --no-pager
        show_access_url
    else
        print_error "$(print_message update_failed)"
        return 1
    fi

    return 0

}

install_service() {
    print_info "$(print_message installing)"
    
    # 检查依赖
    if ! check_dependencies; then
        print_error "$(print_message operation_failed)"
        return 1
    fi

    # 检查软件是否已安装
    if [[ -f "$INSTALL_DIR/$SOFTWARE_NAME" ]]; then
        print_error "$(print_message sof_installed)"
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
Description=HiveMPOS Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/$SOFTWARE_NAME
Restart=always
RestartSec=3
StartLimitIntervalSec=0
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
# HiveMPOS Configuration
# Generated on $(date)

# Default Service settings
SERVICE_PORT=10000
LOG_LEVEL=info
MAX_CONNECTIONS=65535

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

    show_access_url
    
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
    echo "    HiveMPOS Management Script"
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
    local current_ip=$(get_public_ip)
    echo -e "$(print_message default_port_self): ${YELLOW}http://127.0.0.1:10000${NC}"
    echo -e "$(print_message default_port): ${YELLOW}http://${current_ip}:10000${NC}"
    echo "=========================================="
    echo ""
    echo "$(print_message menu_title):"
    echo "$(print_message menu_install)"
    echo "$(print_message menu_uninstall)"
    echo "$(print_message menu_update)" 
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

    # 🔴 新增：初始化版本号（必须在显示菜单之前）
    if ! init_software_version; then
        exit 1  # 版本获取失败，直接退出
    fi
    
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
            10)
                update_service      # 新增的更新功能
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
