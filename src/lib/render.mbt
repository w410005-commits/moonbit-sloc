///统计结果的展示辅助：Markdown 汇总表与 ASCII 占比条。

///|
///把多文件统计结果渲染为 Markdown 表格（含合计行）。
pub fn to_markdown_table(rows : Array[(String, Stats)]) -> String {
  let sb = StringBuilder()
  sb.write_string("| 文件/模块 | 代码 | 注释 | 空行 | 合计 |\n")
  sb.write_string("|---|---:|---:|---:|---:|\n")
  let mut tc = 0
  let mut tm = 0
  let mut tb = 0
  for row in rows {
    let (name, s) = row
    tc = tc + s.code
    tm = tm + s.comment
    tb = tb + s.blank
    sb.write_string("| ")
    sb.write_string(name)
    sb.write_string(" | ")
    sb.write_string(s.code.to_string())
    sb.write_string(" | ")
    sb.write_string(s.comment.to_string())
    sb.write_string(" | ")
    sb.write_string(s.blank.to_string())
    sb.write_string(" | ")
    sb.write_string(s.total.to_string())
    sb.write_string(" |\n")
  }
  sb.write_string("| **合计** | ")
  sb.write_string(tc.to_string())
  sb.write_string(" | ")
  sb.write_string(tm.to_string())
  sb.write_string(" | ")
  sb.write_string(tb.to_string())
  sb.write_string(" | ")
  sb.write_string((tc + tm + tb).to_string())
  sb.write_string(" |\n")
  sb.to_string()
}

///|
///按占比生成单行 ASCII 条形图，`width` 为条宽。
///
///代码行用实心块、注释行用浅色块、空行用空白表示。
pub fn to_bar(s : Stats, width : Int32) -> String {
  if s.total <= 0 {
    return ""
  }
  let n_code = s.code * width / s.total
  let n_comment = s.comment * width / s.total
  let sb = StringBuilder()
  let mut i = 0
  while i < n_code {
    sb.write_char('\u{2588}')
    i = i + 1
  }
  i = 0
  while i < n_comment {
    sb.write_char('\u{2591}')
    i = i + 1
  }
  i = 0
  while i + n_code + n_comment < width {
    sb.write_char(' ')
    i = i + 1
  }
  sb.to_string()
}

///|
///把统计结果序列化为 JSON 对象字符串，便于接入 CI 与其他工具链。
pub fn stats_to_json(s : Stats) -> String {
  let sb = StringBuilder()
  sb.write_string("{ \"code\": ")
  sb.write_string(s.code.to_string())
  sb.write_string(", \"comment\": ")
  sb.write_string(s.comment.to_string())
  sb.write_string(", \"blank\": ")
  sb.write_string(s.blank.to_string())
  sb.write_string(", \"total\": ")
  sb.write_string(s.total.to_string())
  sb.write_string(" }")
  sb.to_string()
}
