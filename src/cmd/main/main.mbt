///|
/// 可运行示例：统计两段不同语言源码的行构成并输出汇总表。
/// 在项目根目录运行：moon run src/cmd/main
fn main {
  // MoonBit 源码示例：含行内注释、独立注释与空行
  let mbt_src = "let name = \"moonbit-sloc\" // 行内注释\n// 独立注释行\n\npub fn greet() -> String {\n  \"hello\"\n}"
  // Python 源码示例：以 "#" 为行注释
  let py_src = "import json\n\n# 读取配置\ndef load(path):\n    return json.load(open(path))"

  let mbt_stats = @lib.count_lines(mbt_src, @lib.moonbit())
  let py_stats = @lib.count_lines(py_src, @lib.hash_like())

  // 按扩展名自动识别语言
  let detected = @lib.detect_ext("src/lib/scan.mbt")

  // 按扩展名自动识别语言并统计
  let sql_stats = @lib.count_lines_auto(
    "SELECT a -- 注释\nFROM t", "query.sql",
  )

  println("== 行统计示例 ==")
  println("MoonBit: code/comment/blank/total")
  println(mbt_stats.code)
  println(mbt_stats.comment)
  println(mbt_stats.blank)
  println(mbt_stats.total)
  println("Python: code/comment/blank/total")
  println(py_stats.code)
  println(py_stats.comment)
  println(py_stats.blank)
  println(py_stats.total)

  println("== Markdown 汇总表 ==")
  let rows : Array[(String, @lib.Stats)] = [
    ("sample.mbt", mbt_stats),
    ("sample.py", py_stats),
  ]
  println(@lib.to_markdown_table(rows))

  println("== 占比条（代码=实心，注释=浅块）==")
  println(@lib.to_bar(mbt_stats, 20))

  println("== 语言识别 ==")
  match detected {
    Some(l) => {
      println("scan.mbt ->")
      println(l.name)
    }
    None => println("unknown")
  }

  println("== JSON 输出 ==")
  match sql_stats {
    Some(v) => println(@lib.stats_to_json(v))
    None => println("unknown")
  }
}
