#!/bin/bash

# 每日启动脚本
# 用于启动当天的Git自动提交定时任务

echo "🚀 启动Git自动提交定时任务"
echo "========================"
echo ""

# 配置文件路径
PLIST_FILE="$HOME/Library/LaunchAgents/com.harrisking.codeTask.plist"

# 检查配置文件是否存在
if [ ! -f "$PLIST_FILE" ]; then
    echo "❌ 错误: 配置文件不存在"
    echo "请先创建配置文件: $PLIST_FILE"
    exit 1
fi

# 检查是否是工作日
DAY_OF_WEEK=$(date +%u)  # 1=周一, 5=周五
if [ "$DAY_OF_WEEK" -gt 6 ]; then
    echo "📅 今天是周日，不启动定时任务"
    exit 0
fi

# 检查主脚本是否存在
MAIN_SCRIPT="/Users/harrisking/scripts/codeTask.sh"
if [ ! -f "$MAIN_SCRIPT" ]; then
    echo "❌ 错误: 主脚本不存在: $MAIN_SCRIPT"
    exit 1
fi

echo "📅 今天是工作日 $(date '+%Y年%m月%d日 星期%u')"
echo "⏰ 执行时间: 9:30-20:30，每40分钟一次"
echo "⏸️  跳过时间段: 12:00-13:30, 18:30-19:00"
echo "📁 主脚本: $MAIN_SCRIPT"
echo ""

# 停止现有任务
echo "停止现有任务..."
launchctl unload "$PLIST_FILE" 2>/dev/null

# 加载并启动任务
echo "加载定时任务..."
launchctl load "$PLIST_FILE"

if launchctl start com.harrisking.codeTask; then
    echo "✅ 定时任务启动成功!"
    echo ""
    echo "📊 今日执行时间点:"
    echo "   09:30   10:10   10:50   11:30"
    echo "   13:40   14:20   15:00   15:40"
    echo "   16:20   17:00   17:40   18:20"
    echo "   19:40   20:20"
    echo ""
    echo "📋 管理命令:"
    echo "   查看状态: launchctl list | grep harrisking"
    echo "   查看日志: tail -f /tmp/git_auto_commit.out"
    echo "   查看错误: tail -f /tmp/git_auto_commit.err"
    echo "   停止任务: $HOME/scripts/daily_stop.sh"
    echo "   手动执行: $MAIN_SCRIPT"
    echo ""
    echo "⏰ 注意: 20:20最后一次执行后，请运行停止脚本"
else
    echo "❌ 定时任务启动失败"
    exit 1
fi