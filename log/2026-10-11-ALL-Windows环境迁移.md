---
date: 2026-10-11
unit: ALL
kind: 准备
status: 完成
duration: 60
outcome: 未考核
---

# 环境迁移到本机 Windows

## 目标

把整个学习环境从"Linux 开发机 + 远程同步"搬到学习者本机的 Windows 上，让 A0 及后续
所有单元能在本机跑通、验收、看图。

## 讲了什么

这次没有讲知识点，全是环境与仓库改造。

### 1. 装环境

本机原本没有可用的 Python（`python.exe` 只是微软商店的占位程序，跑起来报 Access denied）。
处理过程：

| 步骤 | 结果 |
|---|---|
| winget 装 Python 3.12.10（用户级，不需要管理员） | 成功 |
| 建仓库内 `.venv` | 成功 |
| 装 CUDA 版 torch | **2.14.0+cu126**，与讲义里实测的版本一致 |
| 装 torchvision / matplotlib / numpy / pandas / tqdm / requests | 成功 |

torch 的 wheel 有 2.6 GB，pip 直连官方源时中途 `Read timed out` 断过一次。改成先用
curl 断点续传把 wheel 下到本地（实测 10.7 MB/s），再由 pip 装本地文件，一次成功。
镜像测速结果：阿里云 0.29 MB/s、清华 pytorch-wheels 404、SJTU 返回空，都不如官方源。

显卡实测：RTX 4060（算力 sm_89，8G 显存），`torch.cuda.is_available()` 为 True，
张量搬到显卡上算完再搬回来，结果正确；matplotlib 无头渲染出一条 sin 曲线。

### 2. 仓库改造

原来的仓库全部假设 Linux：`justfile` 用 `bash` + `python3`，讲义写 `nix develop`、
`uv run`、`mkdir -p`，还有 `tools/sync.sh`（推到开发机）和 `flake.nix`。

改动清单：

- `justfile` 换成 Windows PowerShell 5.1 + `.venv` 里的解释器，命令名不变
  （`just env` / `just run <文件>` / `just check <单元>`）
- 新增 `requirements.txt` 记录依赖，`just setup` 一条命令重建 `.venv`
- `notes/a0-setup.md` 的第 1、2 节与速查表按本机重写，命令全部改成 PowerShell 可跑的形态
- `AGENTS.md` 的运行环境与讲解边界按 Windows 改写；`PLAN.md` 的算力约束改成 8G 显存
- `README.md` 的环境一节重写
- 删掉 `flake.nix`、`flake.lock`、`tools/sync.sh`
- `tools/remind.sh`（paplay + piper）换成 `tools/remind.ps1`（`[console]::Beep` +
  System.Speech），配套 skill 同步改写
- 讲义、题解、画图脚本里 15 处 `python3` / `开发机` 字样换成 Windows 版

### 3. 两个 Windows 专有的坑

**PowerShell 5.1 读没有 BOM 的 `.ps1` 时按 ANSI（GBK）解码**，中文注释会被解坏成
`Unexpected token '}'` 这类语法错误。`tools/remind.ps1` 因此存成 UTF-8 with BOM，
并在 skill 里写明改文件时别把 BOM 弄丢。`justfile` 里是内联命令，不受影响。

**脚本执行策略禁止直接跑 `.ps1`**（running scripts is disabled）。调用时加
`-ExecutionPolicy Bypass`，只对这一次生效，不动系统设置。

### 4. 补上 A0 缺的验收材料

A0 以前没有验收断言，也没有参考答案。新写：

- `tools/check_a0.py`：11 项断言。跑两个脚本，查打印出来的版本号、CUDA 可用性、
  形状 `(3, 4)`、元素个数、x 的 0 到 11、乘 2 之后的 12 到 22，再打开 `sin.png`
  检查它是不是真的画了铺满横轴的曲线。脚本卡住时提示"多半是 `plt.show()` 开了窗口在等人关"。
- `solutions/a0/`：两个任务的参考答案。

自测过：参考答案 11/11 通过；把实现目录指到空目录时给出"找不到文件"的清楚提示。

## 学习者的产出

`work/a0/hello_tensor.py`（任务一进行中，356 字节）。他没有声明完成，**未批改**。

## 考核结果

未考核。

## 暴露的问题

| 问题 | 类型 | 进错题本 |
|---|---|---|
| 无（本次是环境工作，没有教学交互） | — | — |

## 下一步

1. 本机跑 `just env`、`just run work/a0/hello_tensor.py`、`just run work/a0/sin.py`
2. 写完两个脚本后 `just check a0` 自查
3. 关书答 A0 讲义末尾的 4 道自测题

## 用时对比

| 任务 | 预算 | 实际 | 比值 | 备注 |
|---|---|---|---|---|
| 装环境 + 仓库迁移 | 未给 | 约 60 分钟 | — | 估。含一次 2.6 GB 下载失败重来 |

这次没有给预算，因为任务是学习者临时提出的环境需求，不是排好的学习单元。
