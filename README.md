[![CI](https://github.com/w410005-commits/moonbit-sloc/actions/workflows/ci.yml/badge.svg)](https://github.com/w410005-commits/moonbit-sloc/actions/workflows/ci.yml)

# moonbit-sloc

多语言代码行数统计库：把源码行精确分类为**代码行 / 注释行 / 空行**，纯 MoonBit 实现、零第三方依赖。

## 为什么做这个

MoonBit 黑客松与开源大赛的评审以「有效代码行数」作为项目规模的参考指标，但生态里还没有一个开箱即用的行数统计工具（mooncakes.io 检索确认）。`moonbit-sloc` 补上这块拼图：既能当库嵌入分析工具，也为后续 CLI 统计命令打下核心。

## 特性

- **字符串感知**：字符串字面量里的 `//`、`#` 不会被误判为注释（如 `"http://example.com"`），正确处理转义引号与反引号模板串
- **块注释跨行**：`/* ... */` 跨行统计准确，支持可配置的嵌套块注释（Rust 风格）
- **统计口径对齐 cloc**：行内既有代码又有注释时计为代码行；块注释内空行计为空行
- **展示辅助**：内置 Markdown 汇总表与 ASCII 占比条渲染
- **零依赖**：只依赖 `moonbitlang/core`，native / wasm / js 多后端可用
- **JSON 输出**：`stats_to_json` 直接供 CI 与工具链消费
- **测试完备**：21 项单元测试（黑盒 + 白盒）覆盖边界场景，GitHub Actions CI 全量验证

## 快速开始

```bash
moon add w410005-commits/moonbit-sloc
```

```moonbit
//统计一段源码的行构成
let stats = @sloc.count_lines(src, @sloc.moonbit())
println(stats.code)     // 代码行
println(stats.comment)  // 注释行
println(stats.blank)    // 空行
println(stats.total)    // 总行数

//序列化为 JSON，供 CI / 工具链消费
let json = @sloc.stats_to_json(stats)

//按扩展名自动识别语言并统计（未识别返回 None）
let auto = @sloc.count_lines_auto(src, "app.py")

//按扩展名自动识别语言
let lang = @sloc.detect_ext("src/main.mbt") // Some(MoonBit)

//渲染 Markdown 汇总表
let table = @sloc.to_markdown_table([
  ("src/lib/scan.mbt", stats),
  ("src/lib/lang.mbt", other),
])
```

## 可运行示例

```bash
moon run src/cmd/main
```

```
== 行统计示例 ==
MoonBit: code/comment/blank/total
4
1
1
6
...
== Markdown 汇总表 ==
| 文件/模块 | 代码 | 注释 | 空行 | 合计 |
|---|---:|---:|---:|---:|
| sample.mbt | 4 | 1 | 1 | 6 |
| sample.py | 3 | 1 | 1 | 5 |
| **合计** | 7 | 2 | 2 | 11 |

== 占比条（代码=实心，注释=浅块）==
█████████████░░░    
```

## 支持的语言

| 规则 | 语言 |
|---|---|
| `//` 行注释 + `/* */` 块注释 | MoonBit、C/C++、Java、Go、Rust、JS/TS、Kotlin、Swift、CSS 等 |
| `#` 行注释 | Python、Shell、Ruby、YAML、TOML 等 |
| `--` 行注释 + `/* */` 块注释 | SQL |
| 无注释 | JSON |

自定义语言规则用 `make_lang` 构造（`Lang` 为只读结构，外部包通过它定义预置表之外的规则）：

```moonbit
let dsl = @sloc.make_lang("MyDSL", ["dsl"], false, false, true, true, false, ['"'])
let stats = @sloc.count_lines(src, dsl)
```

## 统计口径

- 行内既有代码又有注释（如 `let a = 1 // note`）→ **代码行**
- 纯注释行、未闭合块注释的剩余内容 → **注释行**
- 仅含空白字符的行、块注释内部的空行 → **空行**

## Roadmap

- [ ] CLI：遍历目录、按语言汇总、JSON / Markdown 输出
- [ ] HTML / XML（`<!-- -->`，4 字符定界符）
- [ ] Python 三引号字符串
- [ ] 发布到 mooncakes.io

## 开发

```bash
moon check        # 静态检查
moon test         # 运行 16 项测试（_test.mbt 黑盒 / _wbtest.mbt 白盒）
moon fmt          # 格式化
moon run src/cmd/main   # 运行示例
```

## License

MIT


