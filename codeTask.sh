#!/bin/bash

# ============================================
# Git 自动提交脚本 (macOS版本)
# 由macOS定时服务控制执行时间
# 每40分44秒执行一次，仅在工作日9:00-20:30之间运行
# ============================================

# 日志函数
log_message() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1"
}

# 检查是否在工作时间内
check_work_time() {
    local day_of_week=$(date +%u)
    local hour=$(date +%H)
    local minute=$(date +%M)
    local time_val=$((10#$hour * 60 + 10#$minute))

    # 只在周一到周六执行 (1-6)
    if [ "$day_of_week" -gt 6 ]; then
        log_message "非工作日，跳过"
        exit 0
    fi

    # 只在 9:00-20:30 之间执行
    if [ "$time_val" -lt 540 ] || [ "$time_val" -gt 1230 ]; then
        log_message "非工作时间，跳过"
        exit 0
    fi

    # 跳过午休 12:00-13:30
    if [ "$time_val" -ge 720 ] && [ "$time_val" -lt 810 ]; then
        log_message "午休时间，跳过"
        exit 0
    fi
}

check_work_time

# 配置区域 - 请根据实际情况修改
GIT_REPO_PATH="/Users/harrisking/code/AI-Movies-Fe" # 修改为您的Git仓库路径
REMOTE_BRANCH="fix/llc/0508" # 远程分支名称
# REMOTE_BRANCH="feat/llc/newLiteCreate" # 远程分支名称

# 5个目标文件数组
TS_FILES=(
    "src/utils/tracking.ts"
    "src/models/logger.ts"
    "src/constants/helpers.ts"
    "src/utils/constants.ts"
    "src/utils/validation.ts"
)

# 20个中文提交信息
CHINESE_COMMITS=(
    "feat: 类型定义错误"
    "feat: 接口参数类型不正确"
    "feat: 函数返回值类型定义"
    "feat: 变量类型声明问题"
    "feat: 泛型参数类型"
    "feat: 类型推断错误"
    "feat: 类型导入问题"
    "feat: 模块导出类型"
    "feat: 类型注解错误"
    "feat: 类型兼容性问题"
    "feat: 联合类型定义"
    "feat: 交叉类型错误"
    "feat: 类型别名定义"
    "feat: 枚举类型声明"
    "feat: 类型保护函数"
    "feat: 类型映射问题"
    "feat: 条件类型错误"
    "feat: 工具类型定义"
    "feat: 类型声明文件"
    "feat: 类型检查配置"
)

# 20个中文功能描述
CHINESE_DESCRIPTIONS=(
    "修复用户登录接口类型"
    "修复订单处理函数返回类型"
    "修复数据验证工具类型定义"
    "修复API请求参数类型声明"
    "修复错误处理函数类型"
    "修复表单验证类型检查"
    "修复日期处理工具类型"
    "修复权限检查函数类型"
    "修复数据转换函数返回类型"
    "修复缓存管理工具类型"
    "修复文件上传接口类型"
    "修复分页查询参数类型"
    "修复搜索过滤器类型定义"
    "修复排序函数比较类型"
    "修复加密解密函数类型"
    "修复数据格式化工具类型"
    "修复国际化函数参数类型"
    "修复主题配置接口类型"
    "修复性能监控工具类型"
    "修复日志记录函数类型"
)

# 20个中文详细描述
CHINESE_DETAILS=(
    "修复了类型定义中的错误，提高了类型安全性"
    "修正了接口参数类型，避免了潜在的类型错误"
    "更新了函数返回类型定义，确保类型一致性"
    "修复了变量类型声明，提高了代码可维护性"
    "优化了泛型参数类型定义，增强了类型推断"
    "修正了类型推断错误，改进了开发体验"
    "修复了类型导入问题，确保了模块正确性"
    "更新了模块导出类型，提高了代码质量"
    "修正了类型注解错误，增强了代码可读性"
    "修复了类型兼容性问题，避免了运行时错误"
    "优化了联合类型定义，提高了类型灵活性"
    "修正了交叉类型错误，改进了类型组合"
    "更新了类型别名定义，简化了复杂类型"
    "修复了枚举类型声明，增强了类型约束"
    "修正了类型保护函数，提高了类型安全性"
    "优化了类型映射，改进了代码可维护性"
    "修复了条件类型错误，增强了类型推断"
    "更新了工具类型定义，提高了开发效率"
    "修正了类型声明文件，确保了类型正确性"
    "修复了类型检查配置，改进了开发体验"
)

# 进入仓库目录
cd "$GIT_REPO_PATH" || {
    log_message "错误: 无法进入仓库目录: $GIT_REPO_PATH"
    exit 1
}

# 随机选择一个目标文件
TS_FILE_PATH=${TS_FILES[$RANDOM % ${#TS_FILES[@]}]}

log_message "开始执行Git自动提交脚本"
log_message "仓库路径: $(pwd)"
log_message "目标文件: $TS_FILE_PATH"

# 检查Git仓库状态
check_git_status() {
    if [ ! -d .git ]; then
        log_message "错误: 当前目录不是Git仓库"
        return 1
    fi
    
    # 检查远程仓库连接
    git remote -v | grep -q origin
    if [ $? -ne 0 ]; then
        log_message "警告: 未配置远程仓库origin"
    fi
    
    return 0
}

# 确保Git配置正确
ensure_git_config() {
    local email=$(git config user.email)
    local name=$(git config user.name)
    
    if [ -z "$email" ]; then
        git config user.email "auto-commit@local.dev"
        log_message "已设置Git邮箱: auto-commit@local.dev"
    fi
    
    if [ -z "$name" ]; then
        git config user.name "Auto Committer"
        log_message "已设置Git用户名: Auto Committer"
    fi
}

# 首字母大写 (兼容 Bash 3.2)
capitalize() {
    local str="$1"
    local first=$(echo "${str:0:1}" | tr '[:lower:]' '[:upper:]')
    echo "${first}${str:1}"
}

# 生成中文提交信息
generate_chinese_commit_with_emoji() {
    # 根据文件名生成对应的提交信息
    case "$TS_FILE_PATH" in
        *tracking*)
            local msgs=(
                "feat: 优化事件追踪模块类型定义"
                "feat: 完善用户行为分析类型"
                "feat: 添加页面浏览事件类型"
                "feat: 补充性能监控接口"
                "feat: 优化事件采集数据结构"
            )
            echo "${msgs[$RANDOM % ${#msgs[@]}]}"
            ;;
        *logger*)
            local msgs=(
                "feat: 完善日志系统接口类型"
                "feat: 添加日志级别类型定义"
                "feat: 优化日志记录器类型"
                "feat: 补充日志格式化接口"
                "feat: 完善日志模块类型安全"
            )
            echo "${msgs[$RANDOM % ${#msgs[@]}]}"
            ;;
        *helpers*)
            local msgs=(
                "feat: 添加工具函数类型声明"
                "feat: 补充通用工具接口"
                "feat: 优化工具函数泛型定义"
                "feat: 完善工具模块类型"
                "feat: 添加日期处理类型"
            )
            echo "${msgs[$RANDOM % ${#msgs[@]}]}"
            ;;
        *constants*)
            local msgs=(
                "feat: 更新常量配置类型定义"
                "feat: 补充API端点类型"
                "feat: 完善状态码类型定义"
                "feat: 优化配置常量类型"
                "feat: 添加路由常量类型"
            )
            echo "${msgs[$RANDOM % ${#msgs[@]}]}"
            ;;
        *validation*)
            local msgs=(
                "feat: 完善表单验证类型定义"
                "feat: 优化验证规则接口"
                "feat: 补充验证结果类型"
                "feat: 完善字段校验类型"
                "feat: 优化验证器泛型定义"
            )
            echo "${msgs[$RANDOM % ${#msgs[@]}]}"
            ;;
        *)
            echo "feat: 优化模块类型定义"
            ;;
    esac
}

# 创建或修改跟踪文件
ensure_tracking_file() {
    if [ ! -f "$TS_FILE_PATH" ]; then
        log_message "创建跟踪文件: $TS_FILE_PATH"
        mkdir -p "$(dirname "$TS_FILE_PATH")"
        
        # 根据文件名生成不同的文件头
        case "$TS_FILE_PATH" in
            *tracking*)
                cat > "$TS_FILE_PATH" << 'EOF'
/**
 * 用户行为追踪模块
 * 记录用户页面访问、点击行为等数据
 */

export interface BaseEvent {
  eventId: string;
  timestamp: number;
  userId?: string;
}

// --- generated ---
EOF
                ;;
            *logger*)
                cat > "$TS_FILE_PATH" << 'EOF'
/**
 * 日志记录模块
 * 提供统一格式的日志输出接口
 */

export type LogLevel = 'debug' | 'info' | 'warn' | 'error';

export interface LogConfig {
  level: LogLevel;
  enableConsole: boolean;
}

// --- generated ---
EOF
                ;;
            *helpers*)
                cat > "$TS_FILE_PATH" << 'EOF'
/**
 * 通用工具函数模块
 * 提供日常开发中常用的工具函数
 */

export interface CommonOptions {
  timeout?: number;
  retries?: number;
}

// --- generated ---
EOF
                ;;
            *constants*)
                cat > "$TS_FILE_PATH" << 'EOF'
/**
 * 常量配置模块
 * 集中管理系统中的各类常量配置
 */

export const API_BASE_URL = '/api/v1';

export const REQUEST_TIMEOUT = 30000;

// --- generated ---
EOF
                ;;
            *validation*)
                cat > "$TS_FILE_PATH" << 'EOF'
/**
 * 表单验证模块
 * 提供各类数据格式的验证函数
 */

export interface ValidationRule {
  required?: boolean;
  pattern?: RegExp;
  message?: string;
}

// --- generated ---
EOF
                ;;
            *)
                cat > "$TS_FILE_PATH" << 'EOF'
/**
 * 工具模块
 * 类型定义和工具函数
 */

export interface BaseResponse {
  code: number;
  message: string;
}

// --- generated ---
EOF
                ;;
        esac
    fi
}

# 生成无害的TS代码修改
generate_harmless_change() {
    # 确保目标文件存在
    ensure_tracking_file
    
    # 获取当前时间戳
    local timestamp=$(date +%s)
    local date_str=$(date '+%Y-%m-%d %H:%M:%S')
    
    # 清空文件，保留头部（到 marker 行为止）
    sed -n '1,/^\/\/ --- generated ---$/p' "$TS_FILE_PATH" > "${TS_FILE_PATH}.tmp"
    
    # 根据文件名生成相应的业务代码
    case "$TS_FILE_PATH" in
        *tracking*)
            generate_tracking_code
            ;;
        *logger*)
            generate_logger_code
            ;;
        *helpers*)
            generate_helpers_code
            ;;
        *constants*)
            generate_constants_code
            ;;
        *validation*)
            generate_validation_code
            ;;
        *)
            generate_generic_code
            ;;
    esac
    
    # 替换原文件
    mv "${TS_FILE_PATH}.tmp" "$TS_FILE_PATH"
}

# 生成追踪相关代码
generate_tracking_code() {
    local types=("PageView" "Click" "Scroll" "Navigation" "ApiCall" "ErrorCapture" "Performance")
    local type=${types[$RANDOM % ${#types[@]}]}
    
    echo -e "\nexport interface ${type}Event {\n  eventId: string;\n  timestamp: number;\n  userId?: string;\n  sessionId: string;\n  data: Record<string, unknown>;\n}" >> "${TS_FILE_PATH}.tmp"
    
    echo -e "\nexport type ${type}Data = {\n  name: string;\n  duration?: number;\n  metadata?: Record<string, unknown>;\n};" >> "${TS_FILE_PATH}.tmp"
    
    echo -e "\nexport const create${type}Tracker = (config: { enable: boolean }) => ({\n  track: (data: ${type}Data) => console.log('${type}:', data)\n});" >> "${TS_FILE_PATH}.tmp"
    
    echo -e "\n// TODO: 优化事件采集性能" >> "${TS_FILE_PATH}.tmp"
    
    echo -e "\nexport const parse${type}Event = (raw: unknown): ${type}Event | null => {\n  if (!raw || typeof raw !== 'object') return null;\n  return raw as ${type}Event;\n};" >> "${TS_FILE_PATH}.tmp"
}

# 生成日志相关代码
generate_logger_code() {
    local levels=("debug" "info" "warn" "error")
    local level=${levels[$RANDOM % ${#levels[@]}]}
    local modules=("Auth" "Api" "Storage" "Network" "UI" "Route")
    local module=${modules[$RANDOM % ${#modules[@]}]}

    echo -e "\nexport interface LogEntry {\n  level: LogLevel;\n  message: string;\n  timestamp: number;\n  module: string;\n  details?: Record<string, unknown>;\n}" >> "${TS_FILE_PATH}.tmp"

    echo -e "\nexport const ${module}Logger = {\n  ${level}: (msg: string, details?: Record<string, unknown>) => {\n    console.${level}(msg, details);\n  }\n};" >> "${TS_FILE_PATH}.tmp"

    echo -e "\nexport const formatLogEntry = (entry: LogEntry): string => {\n  return \`[\${entry.level}] \${entry.module}: \${entry.message}\`;\n};" >> "${TS_FILE_PATH}.tmp"
}

# 生成工具函数代码
generate_helpers_code() {
    local funcs=("formatDate" "debounce" "throttle" "deepClone" "uuid" "base64" "queryString")
    local func=${funcs[$RANDOM % ${#funcs[@]}]}
    local Func=$(capitalize "$func")

    echo -e "\nexport const ${func} = <T>(param: T): T => {\n  return param;\n};" >> "${TS_FILE_PATH}.tmp"

    echo -e "\nexport type ${Func}Options = {\n  timeout?: number;\n  retries?: number;\n  onError?: (err: Error) => void;\n};" >> "${TS_FILE_PATH}.tmp"

    echo -e "\n// TODO: 补充 ${func} 完整实现" >> "${TS_FILE_PATH}.tmp"

    echo -e "\nexport const create${Func}Handler = (options: ${Func}Options) => ({\n  execute: async <T>(input: T) => {\n    return input;\n  }\n});" >> "${TS_FILE_PATH}.tmp"
}

# 生成常量相关代码
generate_constants_code() {
    local categories=("Api" "Route" "Http" "App" "Auth")
    local category=${categories[$RANDOM % ${#categories[@]}]}
    local CATEGORY=$(echo "$category" | tr '[:lower:]' '[:upper:]')

    echo -e "\nexport const ${CATEGORY}_ENDPOINTS = {\n  BASE: '/api/v1',\n  USERS: '/users',\n  AUTH: '/auth',\n  DATA: '/data'\n} as const;" >> "${TS_FILE_PATH}.tmp"

    echo -e "\nexport const ${CATEGORY}_LIMITS = {\n  MAX_RETRY: 3,\n  TIMEOUT: 5000,\n  MAX_SIZE: 10 * 1024 * 1024\n};" >> "${TS_FILE_PATH}.tmp"

    echo -e "\nexport type ${category}Status = 'idle' | 'loading' | 'success' | 'error';" >> "${TS_FILE_PATH}.tmp"

    echo -e "\nexport const ${CATEGORY}_MESSAGES = {\n  SUCCESS: '操作成功',\n  FAILURE: '操作失败',\n  TIMEOUT: '请求超时'\n};" >> "${TS_FILE_PATH}.tmp"
}

# 生成验证相关代码
generate_validation_code() {
    local validators=("email" "phone" "password" "url" "idCard" "bankCard")
    local validator=${validators[$RANDOM % ${#validators[@]}]}
    local Validator=$(capitalize "$validator")

    echo -e "\nexport interface ${Validator}Rule {\n  required?: boolean;\n  minLength?: number;\n  maxLength?: number;\n  pattern?: RegExp;\n  message?: string;\n}" >> "${TS_FILE_PATH}.tmp"

    echo -e "\nexport type ValidationResult = {\n  valid: boolean;\n  errors: string[];\n};" >> "${TS_FILE_PATH}.tmp"

    echo -e "\nexport const validate${Validator} = (value: string, rules: ${Validator}Rule[]): ValidationResult => {\n  const errors: string[] = [];\n  rules.forEach(rule => {\n    if (rule.required && !value) errors.push(rule.message || 'required');\n  });\n  return { valid: errors.length === 0, errors };\n};" >> "${TS_FILE_PATH}.tmp"

    echo -e "\nexport const ${validator}Rules: ${Validator}Rule[] = [\n  { required: true, message: '该字段必填' }\n];" >> "${TS_FILE_PATH}.tmp"
}

# 生成通用代码
generate_generic_code() {
    echo -e "\nexport type GenericResponse<T> = {\n  code: number;\n  data: T;\n  message: string;\n};" >> "${TS_FILE_PATH}.tmp"
    
    echo -e "\nexport interface BaseEntity {\n  id: string;\n  createdAt: number;\n  updatedAt: number;\n}" >> "${TS_FILE_PATH}.tmp"
    
    echo -e "\n// TODO: 补充通用工具方法" >> "${TS_FILE_PATH}.tmp"
    
    echo -e "\nexport const createDefaultResponse = <T>(data: T): GenericResponse<T> => ({\n  code: 200,\n  data,\n  message: 'success'\n});" >> "${TS_FILE_PATH}.tmp"
}

# 主执行逻辑
main() {
    # 检查Git仓库
    if ! check_git_status; then
        exit 1
    fi

    # 确保Git配置
    ensure_git_config

    # 检测并恢复未解决的合并冲突
    if [ -n "$(git ls-files --unmerged)" ]; then
        log_message "检测到未解决的合并冲突，自动恢复..."
        git merge --abort 2>/dev/null || git rebase --abort 2>/dev/null
        git checkout -- . 2>/dev/null
        log_message "冲突已清理"
    fi

    # 拉取最新更改
    log_message "拉取远程更改..."
    if ! git pull origin "$REMOTE_BRANCH" --quiet; then
        log_message "拉取失败，尝试合并策略"
        if ! git pull --no-rebase origin "$REMOTE_BRANCH" --quiet; then
            log_message "合并策略也失败，放弃本次合并并跳过"
            git merge --abort 2>/dev/null
            git checkout -- . 2>/dev/null
            exit 0
        fi
    fi
    
    # 生成无害修改
    generate_harmless_change
    
    # 检查是否有实际更改
    if git diff --quiet "$TS_FILE_PATH" 2>/dev/null; then
        # 如果没有更改，添加一个时间戳注释
        echo -e "\n// 更新检查: $(date '+%Y-%m-%d %H:%M:%S')" >> "$TS_FILE_PATH"
        if git diff --quiet "$TS_FILE_PATH"; then
            log_message "没有检测到文件更改，跳过提交"
            exit 0
        fi
    fi
    
    # 添加更改
    git add "$TS_FILE_PATH"
    
    # 生成中文提交信息
    COMMIT_MSG=$(generate_chinese_commit_with_emoji)
    
    # 提交更改
    if git commit -m "$COMMIT_MSG" --quiet; then
        log_message "✅ 提交成功: $COMMIT_MSG"
    else
        log_message "❌ 提交失败"
        exit 1
    fi
    
    # 推送到远程
    log_message "推送更改到远程..."
    if git push origin "$REMOTE_BRANCH" --quiet; then
        local commit_hash=$(git rev-parse --short HEAD)
        log_message "✅ 推送成功! 提交哈希: $commit_hash"
    else
        log_message "❌ 推送失败，尝试强制推送"
        if git push origin "$REMOTE_BRANCH" --quiet --force-with-lease; then
            log_message "✅ 强制推送成功"
        else
            log_message "❌ 推送完全失败"
            exit 1
        fi
    fi
    
    log_message "执行完成"
}

# 捕获脚本退出
trap 'log_message "中断"; exit 1' INT TERM

# 执行主函数
main
