#!/bin/bash

# 脚本描述：演示标准的main函数调用其他函数的Shell脚本结构

# 导入配置文件（如果有）
# source config.sh

# ========== 全局变量定义 ==========
APP_NAME="示例脚本"
VERSION="1.0.0"
LOG_FILE="/var/log/${APP_NAME// /_}.log"  # 替换空格为下划线

# ========== 工具函数 ==========
log_info() {
    local msg="[INFO] $(date '+%Y-%m-%d %H:%M:%S') $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

log_error() {
    local msg="[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1"
    echo "$msg" >&2  # 输出到标准错误
    echo "$msg" >> "$LOG_FILE"
}

# ========== 业务函数 ==========
parse_arguments() {
    log_info "开始解析命令行参数"
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "$APP_NAME $VERSION"
                exit 0
                ;;
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            *)
                log_error "未知参数: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # 检查必要参数
    if [[ -z "$CONFIG_FILE" ]]; then
        log_error "缺少必要的配置文件参数 (-c)"
        show_help
        exit 1
    fi
    
    log_info "参数解析完成: CONFIG_FILE=$CONFIG_FILE"
}

validate_config() {
    log_info "开始验证配置文件: $CONFIG_FILE"
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "配置文件不存在: $CONFIG_FILE"
        exit 1
    fi
    
    # 检查配置文件格式（示例）
    if ! grep -q "^\[settings\]$" "$CONFIG_FILE"; then
        log_error "配置文件格式错误: 缺少[settings]部分"
        exit 1
    fi
    
    log_info "配置文件验证通过"
}

process_data() {
    log_info "开始处理数据"
    
    # 模拟数据处理
    local input_file="data/input.txt"
    local output_file="data/output.txt"
    
    if [[ ! -f "$input_file" ]]; then
        log_error "输入文件不存在: $input_file"
        return 1
    fi
    
    # 执行数据处理（示例：统计行数）
    local line_count=$(wc -l < "$input_file")
    echo "总行数: $line_count" > "$output_file"
    
    log_info "数据处理完成，结果保存在: $output_file"
    return 0
}

cleanup() {
    log_info "开始清理资源"
    
    # 清理临时文件
    rm -f /tmp/temp_*.txt
    
    log_info "资源清理完成"
}

show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  -h, --help            显示此帮助信息"
    echo "  -v, --version         显示版本信息"
    echo "  -c, --config FILE     指定配置文件"
}

# ========== 主函数 ==========
main() {
    # 设置错误处理
    set -euo pipefail  # 启用严格模式
    trap 'log_error "脚本在第 $LINENO 行出错"; cleanup; exit 1' ERR
    
    log_info "===== $APP_NAME $VERSION 开始执行 ====="
    
    # 调用其他函数
    parse_arguments "$@"  # 传递所有命令行参数
    validate_config
    process_data
    
    log_info "===== $APP_NAME 执行完成 ====="
    return 0
}

# ========== 脚本入口点 ==========
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 当脚本直接执行时调用main函数
    # 而非作为库被其他脚本source时
    main "$@"  # 传递所有命令行参数给main函数
fi




then
    finish_true $FUNCNAME
    return
fi


finish_false $FUNCNAME
}
# rule-rhel8.6-integrate
rule_rhel86_integrate() {
    if [[ -n $CI_COMMIT_TAG ]] && [[ $IMAGE_LIST == "rhel8.6" ]] && [[ $CI_COMMIT_TAG =~ ^([0-9]+\.[0-9]+\.[0-9]+)-.+ ]]
    then
        finish_true $FUNCNAME
        return
    fi

    if [[ -n $CI_COMMIT_TAG ]] && [[ $IMAGE_LIST == "rhel8.6" ]] && [[ $CI_COMMIT_TAG =~ ^([0-9]+\.[0-9]+\.[0-9]+q)-.+ ]]
    then
        finish_true $FUNCNAME
        return
    fi

    if [[ $CI_PIPELINE_SOURCE == "schedule" ]] && [[ $IMAGE_LIST == "rhel8.6" ]]
    then
        finish_true $FUNCNAME
        return
    fi

    finish_false $FUNCNAME
}
# rule-rhel8.3-integrate
rule_rhel83_integrate() {
    if [[ -n $CI_COMMIT_TAG ]] && [[ $IMAGE_LIST == "rhel8.3" ]] && [[ $CI_COMMIT_TAG =~ ^([0-9]+\.[0-9]+\.[0-9]+)-.+ ]]
    then
        finish_true $FUNCNAME
        return
    fi