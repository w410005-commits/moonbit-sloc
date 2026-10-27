///|
/// 白盒测试：需要直接构造 `Lang` 结构（只读类型仅允许在定义包内构造），
/// 用于验证扫描器的可配置行为。
test "count_lines: 块注释嵌套（可配置）" {
  let lang = Lang::{
    name: "Nested",
    exts: [],
    slash_line: false,
    hash_line: false,
    dash_line: false,
    slash_block: true,
    nested_block: true,
    string_delims: [],
  }
  let s = count_lines("/* /* 嵌套 */ 还在注释 */ code", lang)
  assert_eq(s.code, 1)
  assert_eq(s.comment, 0)
}
