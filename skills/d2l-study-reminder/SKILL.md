---
name: d2l-study-reminder
description: 给 d2l 学习会话做节奏控制和防溜号。学习者开始时给他一个时间预算并起后台心跳 job，到点问进度，没回话就用扬声器加中文语音叫他。含 tools/remind.ps1 的用法与各任务的时间预算。
whenToUse: 学习者说"我开始了/开始做某个单元"，或者需要在一段时长之后回来检查他的进度时。
---

# d2l 学习节奏与防溜号

## 什么时候用

- 学习者开始一个带时间预期的任务，例如"开始做 A0 任务一"
- 一次提醒之后他没回话，需要升级提醒强度
- 判断他是不是溜号了

## 机制

三步循环，用后台 job 当定时器。

### 1. 起心跳

给他任务的同时起一个后台 job：

```powershell
Start-Sleep -Seconds 1800; Write-Output "心跳：该问 <单元> <任务> 的进度了"
```

`run_in_background` 设为 true。**job 跑完会通知 AI，这就是定时器**，
不需要 Windows 计划任务或任何外部调度。

起 job 之前先记下当前时刻，它同时充当本次任务的计时起点；他报告完成时再记一次，
差值写进日志的"用时对比"节。

时长按时间预算来（见下表）。

**写代码那一段不要中途打断。** 编程中断后只有 10% 的会话能在 1 分钟内恢复编码
（Parnin & Rugaber 2011），中断越长恢复越慢（Monk 等 2008）。所以分两类处理：

- 读讲义、读书、口试：按预算起心跳，到点就问
- **写代码：心跳时长按整段的长度设（至少 60 分钟），到点时问的是"这一段落停了吗"**，
  不要中途插进去问做到哪了

**段末提醒他休息。** 说法具体一点：离开屏幕、走动 5 到 15 分钟、闭眼静坐都行。
**不要说"看会儿手机"**——对照研究里手机休息约等于不休息（Kang & Kurtzberg 2019），
而且会留下注意力残留。完整的休息规则见仓库里的 `notes/learning-rhythm.md`。

### 2. 到点问进度

心跳到达时如果他还没主动报告，就发消息问他做到哪了。问具体一点，
例如"任务一跑通了吗，输出的形状那几行对上了没"，不要只问"做完了吗"。

可以先看一眼 `work/` 下有没有文件、文件多大，这样问得具体些。
**但只看不批**：他可能正在调试，中间状态不是交付物。批改等他明确说"做完了"再开始。

同时起一个五分钟的后台 job：

```powershell
Start-Sleep -Seconds 300; Write-Output "心跳：五分钟没回话，该响铃了"
```

### 3. 没回话就响铃

五分钟的 job 到点时他还没回话，用扬声器叫他：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/remind.ps1 -Times 3 -Message "回来学习"
```

- `-Times` 是响几声，溜号时用 3
- `-Message` 用系统语音念一遍中文（.NET 的 System.Speech），留空就只响铃
- 脚本本身不需要装任何东西，也没有可调音量：声音大小由系统音量决定，
  他平时音量不高时提醒容易听不见，必要时让他把系统音量调上去

他回话之后，如果任务还没结束，从第 1 步重新起心跳。

## 时间预算

| 任务类型 | 预算 | 心跳怎么设 |
|---|---|---|
| 读一节讲义 | 20-30 分钟 | 按预算 |
| 读纸质书一节 | 30-40 分钟 | 按预算 |
| 口试 | 20 分钟 | 按预算 |
| 写代码 | 至少 60 分钟一段 | 按整段长度，只在段末问 |

## 脚本

`tools/remind.ps1` 用 Windows 自带能力出声，不需要额外装包。

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/remind.ps1 -Times 1                              # 一声提示音
powershell -NoProfile -ExecutionPolicy Bypass -File tools/remind.ps1 -Times 3                              # 三声
powershell -NoProfile -ExecutionPolicy Bypass -File tools/remind.ps1 -Times 2 -Message "该看进度了"           # 两声，再念一遍
```

`-ExecutionPolicy Bypass` 不能省：这台机器的脚本执行策略禁止直接跑 `.ps1`（报
running scripts is disabled）。加这个参数只对这一次调用生效，不动系统设置。

提示音走 `[console]::Beep`，失败时退回系统提示音；两者都失败（远程会话、没有声卡）
只是静默跳过并打一行说明，不会报错退出。系统没装中文语音包时同样只跳过朗读。

`tools/remind.ps1` 是 **UTF-8 with BOM** 的。PowerShell 5.1 读没有 BOM 的 `.ps1` 时按
ANSI 解码，中文注释会被解坏成语法错误（报 `Unexpected token`）——改这个文件时别把 BOM
弄丢。`justfile` 里用的是内联命令（`-Command`），不受这条影响。

## 注意

- 提醒别太频繁。一个任务一个心跳就够，不要在半小时里问三次。
- 扬声器是兜底。他人在电脑前时，在对话里喊一声就够，不必响铃。
- 需要知道他今天的作息时直接问，不要按常规作息想当然，也别提"早上"。
