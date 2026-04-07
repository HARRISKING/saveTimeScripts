#!/bin/bash

# 状态查看脚本
# 查看定时任务状态和执行情况

echo "📊 Git自动提交任务状态"
echo "======================"
echo ""

# 检查任务是否运行
TASK_STATUS=$(launchctl list | grep com.harrisking.codeTask)

if [ -n "$TASK_STATUS" ]; then
    echo "✅ 定时任务状态: 运行中"
    echo "   任务信息: $TASK_STATUS"
else
    echo "❌ 定时任务状态: 未运行"
fi
echo ""

# 检查配置文件
PLIST_FILE="$HOME/Library/LaunchAgents/com.harrisking.codeTask.plist"
if [ -f "$PLIST_FILE" ]; then
    echo "📁 配置文件: 存在"
    echo "   位置: $PLIST_FILE"
else
    echo "📁 配置文件: 不存在"
fi
echo ""

# 检查主脚本
MAIN_SCRIPT="/Users/harrisking/scripts/codeTask.sh"
if [ -f "$MAIN_SCRIPT" ]; then
    echo "📜 主脚本: 存在"
    echo "   位置: $MAIN_SCRIPT"
    echo "   权限: $(ls -la "$MAIN_SCRIPT" | awk '{print $1}')"
else
    echo "📜 主脚本: 不存在"
fi
echo ""

# 查看日志
if [ -f "/tmp/git_auto_commit.out" ]; then
    echo "📄 输出日志:"
    echo "   最后5行:"
    tail -5 "/tmp/git_auto_commit.out"
else
    echo "📄 输出日志: 暂无"
fi
echo ""

if [ -f "/tmp/git_auto_commit.err" ]; then
    ERR_SIZE=$(stat -f%z "/tmp/git_auto_commit.err")
    if [ "$ERR_SIZE" -gt 0 ]; then
        echo "⚠️  错误日志: 有错误"
        echo "   最后5行:"
        tail -5 "/tmp/git_auto_commit.err"
    else
        echo "✅ 错误日志: 无错误"
    fi
else
    echo "📄 错误日志: 暂无"
fi
echo ""

# 今日执行时间
DAY_OF_WEEK=$(date +%u)
if [ "$DAY_OF_WEEK" -le 5 ]; then
    echo "⏰ 今日执行时间点:"
    echo "   09:30   10:10   10:50   11:30"
    echo "   13:40   14:20   15:00   15:40"
    echo "   16:20   17:00   17:40   18:20"
    echo "   19:40   20:20"
    echo ""
    echo "⏸️  跳过时间段: 12:00-13:30, 18:30-19:00"
else
    echo "📅 今天是周末，不执行定时任务"
fi
echo ""
echo "🔧 管理命令:"
echo "   启动任务: $HOME/scripts/daily_start.sh"
echo "   停止任务: $HOME/scripts/daily_stop.sh"
echo "   手动执行: $MAIN_SCRIPT"