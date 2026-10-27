///行统计结果与核心扫描器。
///
///统计口径与 cloc 一致：
//- 既有代码又有注释的行计为代码行；
//- 块注释内部只含注释内容的行计为注释行，其中的空行计为空行；
//- 仅含空白字符的行计为空行。

///|
///行统计结果。
pub struct Stats {
  /// 总行数（代码 + 注释 + 空行）
  total : Int32
  /// 代码行
  code : Int32
  /// 注释行
  comment : Int32
  /// 空行（含仅含空白字符的行）
  blank : Int32
}

///|
///扫描器状态。
priv enum ScanState {
  Normal
  InString(Char)
  InLineComment
  InBlockComment(Int32)
}

///|
///统计一段源码的行构成（代码行 / 注释行 / 空行）。
///
///分类规则来自 `lang`：字符串字面量中的注释记号不计为注释；
///块注释结束符同行其后若出现代码，该行计为代码行。
pub fn count_lines(src : String, lang : Lang) -> Stats {
  let mut code = 0
  let mut comment = 0
  let mut blank = 0
  let mut state : ScanState = Normal
  let mut prev = '\u{0}'
  let mut seen_code = false
  let mut seen_text = false
  let mut esc = false
  let mut just_opened = false
  let mut has_any = false
  // 注释起始符挂起：Normal 状态下遇到可能的注释起始字符（"/" 或 "-"）时，
  // 先不判定为代码，待下一个字符确认它是注释开头，还是普通运算符（除法/减法）。
  // 取值为 '\u{0}'（无挂起）、'/' 或 '-'。
  let mut pending : Char = '\u{0}'
  let mut first = true
  for ch in src {
    // 跳过文件开头的 UTF-8 BOM（U+FEFF），它不属于任何行，
    // 否则记事本等工具保存的带 BOM 文件会把首行统计错。
    if first && ch == '\u{FEFF}' {
      first = false
      continue
    }
    first = false
    has_any = true
    if ch == '\n' {
      if pending != '\u{0}' {
        pending = '\u{0}'
        seen_code = true
      }
      if esc {
        esc = false
      }
      if seen_code {
        code = code + 1
      } else if seen_text {
        comment = comment + 1
      } else {
        blank = blank + 1
      }
      seen_code = false
      seen_text = false
      // 行注释只作用于当前行，行尾必须退出；
      // 字符串与块注释按语义允许跨行，状态保持。
      match state {
        InLineComment => state = Normal
        _ => ()
      }
      continue
    }
    match state {
      Normal =>
        if ch == ' ' || ch == '\t' || ch == '\r' {
          // 空白字符
        } else if lang.slash_line && prev == '/' && ch == '/' {
          // 确认为行注释开头：挂起的斜杠不算代码
          pending = '\u{0}'
          state = InLineComment
          seen_text = true
        } else if lang.dash_line && prev == '-' && ch == '-' {
          // 确认为行注释开头：挂起的横杠不算代码
          pending = '\u{0}'
          state = InLineComment
          seen_text = true
        } else if lang.slash_block && prev == '/' && ch == '*' {
          // 确认为块注释开头：挂起的斜杠不算代码
          pending = '\u{0}'
          state = InBlockComment(1)
          just_opened = true
          seen_text = true
        } else if lang.hash_line && ch == '#' {
          state = InLineComment
          seen_text = true
        } else if in_array_char(lang.string_delims, ch) {
          if pending != '\u{0}' {
            pending = '\u{0}'
            seen_code = true
          }
          state = InString(ch)
          seen_code = true
        } else if ch == '/' && (lang.slash_line || lang.slash_block) {
          // 可能是注释开头的第一个斜杠，先挂起
          pending = '/'
        } else if ch == '-' && lang.dash_line {
          // 可能是注释开头的第一个横杠，先挂起
          pending = '-'
        } else {
          if pending != '\u{0}' {
            pending = '\u{0}'
            seen_code = true
          }
          seen_code = true
        }
      InString(q) => {
        seen_code = true
        if esc {
          esc = false
        } else if ch == '\\' {
          esc = true
        } else if ch == q {
          state = Normal
        }
      }
      InLineComment =>
        if ch == ' ' || ch == '\t' || ch == '\r' {
          // 空白字符
        } else {
          seen_text = true
        }
      InBlockComment(depth) => {
        if ch == ' ' || ch == '\t' || ch == '\r' {
          // 空白字符
        } else {
          seen_text = true
        }
        if just_opened {
          // 块注释开始后的第一个字符不参与结束符匹配，
          // 避免 "/*/" 中紧随开头的斜杠被误判为结束。
          just_opened = false
        } else if prev == '*' && ch == '/' {
          if depth <= 1 || !lang.nested_block {
            state = Normal
          } else {
            state = InBlockComment(depth - 1)
          }
        } else if lang.nested_block && prev == '/' && ch == '*' {
          state = InBlockComment(depth + 1)
          just_opened = true
        }
      }
    }
    prev = ch
  }
  if has_any {
    if pending != '\u{0}' {
      pending = '\u{0}'
      seen_code = true
    }
    if seen_code {
      code = code + 1
    } else if seen_text {
      comment = comment + 1
    } else {
      blank = blank + 1
    }
  }
  Stats::{ total: code + comment + blank, code, comment, blank, }
}

///|
///按路径扩展名自动识别语言并统计行构成，
///适合批量处理文件的场景；未注册的扩展名返回 `None`。
pub fn count_lines_auto(src : String, path : String) -> Stats? {
  match detect_ext(path) {
    None => None
    Some(lang) => Some(count_lines(src, lang))
  }
}

///|
///判断字符是否在数组中。
fn in_array_char(arr : Array[Char], c : Char) -> Bool {
  for x in arr {
    if x == c {
      return true
    }
  }
  false
}
