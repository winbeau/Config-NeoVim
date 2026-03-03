# Neovim 配置运维说明（winbeau）

## 当前配置总览

- 基础框架：LazyVim（`lua/config/lazy.lua`）
- Import 顺序：
  1. `lazyvim.plugins`
  2. `lazyvim.plugins.extras.lang.java`
  3. `plugins`
- 生效自定义插件文件：
  - `lua/plugins/cpp.lua`
  - `lua/plugins/noice.lua`
  - `lua/plugins/java.lua`
- 全局缩进：4 空格（`tabstop/shiftwidth/softtabstop=4`，`expandtab=true`）

## 关键行为

### Noice / 命令行

- `:` 命令框当前使用 Noice cmdline（不是原生底栏）
- 已配置：
  - `opts.cmdline.enabled = true`
  - `opts.presets.command_palette = true`
  - `opts.presets.bottom_search = true`
  - `opts.views.mini.size.max_height = 1`
- 如果 Noice setup 失败，会回退到原生 cmdline 并给 warning

### Tree-sitter

- 当前测试门禁要求：`tree-sitter-cli >= 0.25.0`（硬失败）
- 推荐修复命令：

```sh
cargo install --locked tree-sitter-cli --force
```

- 已配置优先策略：优先使用可用且较新的 host `tree-sitter`，避免命中 Mason 不兼容二进制

### Java / jdtls

- Java 语言支持来自 `lazyvim.plugins.extras.lang.java`
- 本地覆盖在 `lua/plugins/java.lua`：
  - 缺少 Java 21 时禁用 `nvim-jdtls`，避免反复 `exit code 1`
  - 检测到 Java 21 时注入 `--java-executable <java21>`
  - 基础纠错快捷键：
    - `<leader>ca` code action
    - `<leader>co` organize imports
    - `<leader>cr` rename
    - `<leader>cf` format
- 关键前置：当前 jdtls 版本要求 Java 21
- 安装建议（Ubuntu）：

```sh
sudo apt update
sudo apt install -y openjdk-21-jdk
```

## 快捷键

- `Ctrl+s`：保存全部
  - Normal/Visual：`:wa`
  - Insert：保存后回到插入位置
- `Ctrl+x`：退出全部（`:qa`）
- `Ctrl+f`：手动格式化（覆盖默认翻页）

> 终端若拦截 `Ctrl+s`，执行：`stty -ixon`

## 测试体系

### Python（uv + pytest）

```sh
uv sync --dev
uv run pytest
```

- 测试目录：`tests/pytest/`
- 重点门禁：
  - `nvim>=0.11`
  - `python>=3.11`
  - `pytest>=8`
  - `tree-sitter>=0.25`（硬失败）

### Lua（plenary）

```sh
XDG_STATE_HOME=/tmp XDG_CACHE_HOME=/tmp \
nvim --headless \
  -c "lua vim.opt.rtp:prepend(vim.fn.stdpath('data')..'/lazy/plenary.nvim'); require('plenary.test_harness').test_directory('tests/lua/spec', { minimal_init = 'tests/lua/minimal_init.lua' })" \
  -c "qa"
```

- 测试目录：`tests/lua/spec/`

### 一键脚本

```sh
./scripts/test.sh
```

- 顺序：`uv run pytest` -> plenary
- 任一失败会返回非 0

## 常见问题与定位

### 1) `Client jdtls quit with exit code 1`

- 根因通常是 Java 版本不满足（需要 21）
- 定位：
  - `:LspInfo`
  - `:messages`
  - 查看 `~/.local/state/nvim/lsp.log`
- 修复：安装 Java 21 并重启 Neovim

### 2) `:` 命令框不可见

- 先确认 Noice 配置是否被改坏（`lua/plugins/noice.lua`）
- 执行：`:Lazy reload noice.nvim`
- 仍异常时查看：`~/.local/state/nvim/noice.log`

### 3) Tree-sitter 安装/编译失败

- 先看 `tree-sitter --version`
- 低于 0.25 时先升级 CLI，再 `:TSUpdate`

## 维护约定

- 修改 `lua/plugins/*.lua` 或 `lua/config/*.lua` 时，必须同步更新对应测试断言
- 提交前至少跑：
  1. `uv run pytest`
  2. Lua plenary 测试
- 文档以本文件为准；配置变化后同步更新本文件
