///|
/// 黑盒测试：从使用者视角验证公开 API。
test "count_lines: MoonBit 基本分类" {
  let src = "let a = 1 // 行内注释\n// 独立注释行\n\nlet b = 2"
  let s = @lib.count_lines(src, @lib.moonbit())
  assert_eq(s.code, 2)
  assert_eq(s.comment, 1)
  assert_eq(s.blank, 1)
  assert_eq(s.total, 4)
}

///|
test "count_lines: 字符串中的注释记号不误判" {
  let s = @lib.count_lines(
    "let url = \"http://example.com\" // 真注释",
    @lib.moonbit(),
  )
  assert_eq(s.code, 1)
  assert_eq(s.comment, 0)
}

///|
test "count_lines: 字符串内的 // 与转义引号" {
  let src = "let a = \"it\\'s // fine\"\nlet b = 1"
  let s = @lib.count_lines(src, @lib.moonbit())
  assert_eq(s.code, 2)
  assert_eq(s.comment, 0)
}

///|
test "count_lines: 块注释跨行与结束符后代码" {
  let src = "/* 第一行\n第二行\n*/ let x = 1\nlet y = 2"
  let s = @lib.count_lines(src, @lib.moonbit())
  assert_eq(s.code, 2)
  assert_eq(s.comment, 2)
  assert_eq(s.total, 4)
}

///|
test "count_lines: 未闭合块注释按注释统计" {
  let s = @lib.count_lines("/*/", @lib.moonbit())
  assert_eq(s.code, 0)
  assert_eq(s.comment, 1)
}

///|
test "count_lines: 块注释开始后紧随的斜杠不误判结束" {
  let src = "/**/\nlet x = 1"
  let s = @lib.count_lines(src, @lib.moonbit())
  assert_eq(s.code, 1)
  assert_eq(s.comment, 1)
}

///|
test "count_lines: Python 哈希注释与 CRLF" {
  let s = @lib.count_lines("x = 1\r\n\r\n# 注释", @lib.hash_like())
  assert_eq(s.code, 1)
  assert_eq(s.comment, 1)
  assert_eq(s.blank, 1)
}

///|
test "count_lines: 反引号模板串跨行" {
  let src = "let s = `multi\n// not comment\n` // real comment"
  let s2 = @lib.count_lines(src, @lib.moonbit())
  assert_eq(s2.code, 3)
  assert_eq(s2.comment, 0)
}

///|
test "count_lines: 块注释内的空行计为空行" {
  let src = "/*\n\n*/\nlet x = 1"
  let s = @lib.count_lines(src, @lib.moonbit())
  assert_eq(s.code, 1)
  assert_eq(s.comment, 2)
  assert_eq(s.blank, 1)
}

///|
test "count_lines: 空输入" {
  let s = @lib.count_lines("", @lib.moonbit())
  assert_eq(s.total, 0)
  assert_eq(s.code, 0)
  assert_eq(s.comment, 0)
  assert_eq(s.blank, 0)
}

///|
test "count_lines: 末行无换行符" {
  let s = @lib.count_lines("let a = 1", @lib.moonbit())
  assert_eq(s.code, 1)
  assert_eq(s.total, 1)
}

///|
test "ext_of: 取扩展名" {
  match @lib.ext_of("src/main.mbt") {
    Some(e) => assert_eq(e, "mbt")
    None => assert_true(false)
  }
  match @lib.ext_of("noext") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
  match @lib.ext_of("file.") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "detect_ext: 按扩展名识别语言" {
  match @lib.detect_ext("src/main.mbt") {
    Some(l) => assert_eq(l.name, "MoonBit")
    None => assert_true(false)
  }
  match @lib.detect_ext("app.py") {
    Some(l) => assert_eq(l.name, "Python/Shell/Ruby/YAML/TOML")
    None => assert_true(false)
  }
  match @lib.detect_ext("data.json") {
    Some(l) => assert_eq(l.name, "JSON")
    None => assert_true(false)
  }
  match @lib.detect_ext("readme.txt") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "to_markdown_table: 含合计行" {
  let rows = [
    ("a.mbt", @lib.count_lines("let x = 1", @lib.moonbit())),
    ("b.py", @lib.count_lines("# hi\ny = 2", @lib.hash_like())),
  ]
  let out = @lib.to_markdown_table(rows)
  assert_true(out.contains("a.mbt"))
  assert_true(out.contains("合计"))
  assert_true(out.contains("| 1 | 0 | 0 | 1 |"))
}

///|
test "to_bar: 占比条" {
  let s = @lib.count_lines("let x = 1", @lib.moonbit())
  let bar = @lib.to_bar(s, 10)
  assert_eq(bar.length(), 10)
  let empty = @lib.to_bar(@lib.count_lines("", @lib.moonbit()), 10)
  assert_eq(empty, "")
}
