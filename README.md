# 创建配置文件目录

```bash
mkdir -p ~/Library/LaunchAgents
```

# 创建配置文件

```bash
`vim ~/Library/LaunchAgents/com.harrisking.codeTask.plist
```

# 查看所有任务

launchctl list

# 查看特定任务

launchctl list | grep harrisking

# 立即启动任务（测试用）

launchctl start com.harrisking.codeTask

# 立即停止任务

launchctl stop com.harrisking.codeTask

# 重新加载配置

launchctl unload ~/Library/LaunchAgents/com.harrisking.codeTask.plist
launchctl load ~/Library/LaunchAgents/com.harrisking.codeTask.plist

# 查看系统日志中的任务记录

log show --predicate 'subsystem == "com.apple.xpc.launchd"' --last 1h
