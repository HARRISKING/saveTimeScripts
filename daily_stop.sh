#!/bin/bash

# 每日停止脚本
# 用于停止当天的Git自动提交定时任务

echo "🛑 停止Git自动提交定时任务"
echo "========================"
echo ""

# 配置文件路径
PLIST_FILE="$HOME/Library/LaunchAgents/com.harrisking.codeTask.plist"

# 停止任务
echo "正在停止任务..."
launchctl stop com.harrisking.codeTask
launchctl unload "$PLIST_FILE"

echo "✅ 定时任务已停止"
echo ""
echo "📅 最后停止时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "📁 日志文件: /tmp/git_auto_commit.{out,err}"
echo ""
echo "📈 今日提交统计:"
echo "   运行以下命令查看:"
echo "   cd /path/to/your/repo"
echo "   git log --oneline --since='今天 09:00'"