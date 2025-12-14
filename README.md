# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

---

# Neovim 配置排障记录（winbeau）

## 现象 1：编辑 Python 时右下角不断弹出 `pyright`（最多 10 行）

- 表现：在插入/编辑时，右下角会随着输入不断出现 `pyright` 相关提示，且高度最多 10 行。
- 根因：来自 `folke/noice.nvim` 的 `view = "mini"`（默认 `views.mini.size.max_height = 10`），用于显示 LSP progress（包括 Pyright 的进度/消息）。
- 修复：覆盖 Noice 的 `mini` 视图高度为 1 行。
  - 配置已落地：`lua/plugins/noice.lua` 将 `opts.views.mini.size.max_height = 1`。

## 现象 2：启动时 `nvim-treesitter` 安装/编译多语言 parser 大量失败（ts/yaml/bash…），只成功少量（如 3/30）

- 表现：启动或 `:TSUpdate` 时大量语言显示 `Downloading...` 后在 `Compiling parser` 阶段失败；最后提示 `Installed 3/30 languages`。
- 关键报错：`/lib/x86_64-linux-gnu/libc.so.6: version 'GLIBC_2.39' not found ...`
- 根因：`nvim-treesitter` 调用到的 `tree-sitter` CLI 是预编译二进制（来自 NVM 的全局 `tree-sitter-cli` 或 Mason 安装的 `tree-sitter-cli`），该二进制要求 `GLIBC_2.39`；本机系统为 `GLIBC 2.35`，导致 `tree-sitter build` 无法运行，从而所有 parser 编译失败。
- 修复（已验证可用的做法）：
  1. 安装兼容本机 GLIBC 的旧版 CLI：
     - `npm install -g tree-sitter-cli@0.22.6`
  2. 让 Neovim/LazyVim 使用这个可用的 `tree-sitter`：
     - `ln -sf $(which tree-sitter) /home/winbeau/.local/share/nvim/mason/bin/tree-sitter`
  3. 然后重新执行 `:TSUpdate` / 重启，让 parsers 重新安装。

## 备注

- 仓库里 `lua/plugins/example.lua` 顶部有 `if true then return {} end`，该文件示例配置默认不会生效；实际生效的修复放在 `lua/plugins/noice.lua`。

## 快捷键自定义

- 保存全部：`Ctrl+s`
  - Normal/Visual：执行 `:wa`
  - Insert：保存后返回插入位置
- 退出全部：`Ctrl+x`
  - 所有模式：执行 `:qa`

> 终端若拦截 `Ctrl+s`（XON/XOFF 导致卡住/无响应），可在终端执行 `stty -ixon` 关闭流控。

## 仓库远端（`origin` / `upstream`）与同步机制

### 约定

- 本地 Git 仓库可以配置多个远端（remote）。
- `origin`：通常指“你要 push 的远端”（你的仓库）。
- `upstream`：通常指“你要拉取更新的上游来源”（比如最初 clone 的 `LazyVim/starter`）。

### 推荐设置（当前目录 `~/.config/nvim`）

这个目录最初是从 `LazyVim/starter` clone 的，因此默认 `origin` 很可能指向 `LazyVim/starter`。
为了把配置维护在你自己的仓库里，同时还能跟进上游更新，建议把：

- `LazyVim/starter` 保留为 `upstream`
- 你的仓库设为 `origin`

示例命令（把 URL 换成你的）：

```sh
git remote rename origin upstream
git remote add origin git@github.com:<you>/<repo>.git
```

### 日常工作流

- 本地改动并提交：`git add -A && git commit -m "..."`（提交到本地 `main`）
- 推送到你的仓库：`git push`（推到 `origin/main`）
- 跟进上游更新：
  - `git fetch upstream`
  - 合并上游：`git merge upstream/main`（简单直观，会产生 merge commit）
  - 或线性历史：`git rebase upstream/main`（历史更整洁，冲突时解决后继续 rebase）
  - 完成后再 `git push` 推回 `origin`
