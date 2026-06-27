# DM Database (达梦) SQL Snippets

Espanso snippets for working with **DM Database** (达梦数据库, DMSQL), covering:

- Session/事务管理 (active sessions, blocking/wait, IP 连接分布)
- 系统参数与版本查询 (`V$DM_INI`, version info)
- DBA 操作 (creating users and granting privileges, data file usage)
- 备份 (full database backup)
- 内存诊断 (per-session/SQL memory usage, buffer pressure, total memory, memory-related params)
- 故障诊断 (deduplicated stack traces, cached/package execution plan dumps, page/segment lookup, archive log mining)

## Triggers

| Trigger | Description |
| --- | --- |
| `:dmsea` | 查看当前的活动会话 |
| `dmseip` | 按客户端 IP 段统计会话状态分布 |
| `:dmsetw` | 查看当前事物阻塞 |
| `:dmparam` | 查询系统参数值 |
| `:dmver` | 查询数据库版本 |
| `:dmcuser` | 创建用户以及赋予权限 |
| `:dmdbafiles` | 查看数据文件总大小及实际使用大小 |
| `:dmbackup` | 对数据库进行全量备份 |
| `:dmmemsql` | 单个会话内存使用总量 |
| `:dmmemtotal` | 达梦内存总量 |
| `:dmmempara` | 达梦内存相关参数 |
| `:dmmemasql` | 当前数据库中内存消耗最大的几个 SQL |
| `:dmbuff` | 判断 BUFFER 空闲还是紧张 |
| `:dmbupl` | 按缓冲池统计命中率、大小、空闲、脏页、零页 |
| `:dmpsp` | 去重堆栈 |
| `:dmtrace` | 获取缓存计划/包计划 |
| `:dmerrpage` | 根据文件号、页号定位表 |
| `:dmerrseg` | 根据文件号、页号定位表（段信息，慎用，容易导致宕机或系统变慢） |
| `:dmarchdig` | 归档日志挖掘（DBMS_LOGMNR） |
