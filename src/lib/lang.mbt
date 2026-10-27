///语言规则定义。
///
///每种语言通过一组开关描述其注释与字符串字面量规则，
///扫描器据此把源码行分类为代码行、注释行和空行。

///|
///语言规则。
pub struct Lang {
  /// 语言名称，例如 "MoonBit"
  name : String
  /// 常见扩展名（不含点号），用于按文件名识别语言
  exts : Array[String]
  /// 是否支持 "//" 行注释（MoonBit、C 家族、CSS 等）
  slash_line : Bool
  /// 是否支持 "#" 行注释（Python、Shell、Ruby、YAML、TOML 等）
  hash_line : Bool
  /// 是否支持 "--" 行注释（SQL、Lua、Haskell 等）
  dash_line : Bool
  /// 是否支持 "/* ... */" 块注释（MoonBit、C 家族、CSS 等）
  slash_block : Bool
  /// 块注释是否支持嵌套（Rust 风格）
  nested_block : Bool
  /// 字符串字面量界定符（单字符）；扫描器在字符串内不识别注释记号
  string_delims : Array[Char]
}

///|
///MoonBit 语言规则。
pub fn moonbit() -> Lang {
  Lang::{
    name: "MoonBit",
    exts: ["mbt"],
    slash_line: true,
    hash_line: false,
    dash_line: false,
    slash_block: true,
    nested_block: false,
    string_delims: ['"', '\'', '`'],
  }
}

///|
///C 家族语言规则（C/C++/Java/Go/Rust/JS/TS/CSS 等）。
pub fn c_like() -> Lang {
  Lang::{
    name: "C/C++/Java/Go/Rust/JS/TS/CSS",
    exts: [
      "c", "h", "cpp", "hpp", "cc", "hh", "hxx", "java", "go", "rs", "js", "jsx",
      "ts", "tsx", "kt", "swift", "dart", "scala", "cs", "css", "scss", "less", "php",
      "jsonc",
    ],
    slash_line: true,
    hash_line: true,
    dash_line: false,
    slash_block: true,
    nested_block: false,
    string_delims: ['"', '\'', '`'],
  }
}

///|
///Python / Shell / Ruby / YAML / TOML 等以 "#" 为行注释的语言。
pub fn hash_like() -> Lang {
  Lang::{
    name: "Python/Shell/Ruby/YAML/TOML",
    exts: ["py", "pyw", "rb", "sh", "bash", "zsh", "yml", "yaml", "toml"],
    slash_line: false,
    hash_line: true,
    dash_line: false,
    slash_block: false,
    nested_block: false,
    string_delims: ['"', '\''],
  }
}

///|
///SQL 语言规则："--" 行注释 + "/* ... */" 块注释，字符串为单引号。
pub fn sql_lang() -> Lang {
  Lang::{
    name: "SQL",
    exts: ["sql"],
    slash_line: false,
    hash_line: false,
    dash_line: true,
    slash_block: true,
    nested_block: false,
    string_delims: ['\''],
  }
}

///|
///JSON（无注释语法）。
pub fn json_lang() -> Lang {
  Lang::{
    name: "JSON",
    exts: ["json"],
    slash_line: false,
    hash_line: false,
    dash_line: false,
    slash_block: false,
    nested_block: false,
    string_delims: ['"'],
  }
}

///|
///构造自定义语言规则。
///
///`Lang` 是只读结构，只能在定义包内部构造字面量；
///其他包需要定义预置语言表之外的规则时，请使用本函数。
pub fn make_lang(
  name : String,
  exts : Array[String],
  slash_line : Bool,
  hash_line : Bool,
  dash_line : Bool,
  slash_block : Bool,
  nested_block : Bool,
  string_delims : Array[Char],
) -> Lang {
  Lang::{
    name,
    exts,
    slash_line,
    hash_line,
    dash_line,
    slash_block,
    nested_block,
    string_delims,
  }
}

///|
///内置语言表。
pub fn builtin_langs() -> Array[Lang] {
  [moonbit(), c_like(), hash_like(), sql_lang(), json_lang()]
}

///|
///按扩展名识别语言；未注册的扩展名返回 `None`。
pub fn detect_ext(path : String) -> Lang? {
  match ext_of(path) {
    None => None
    Some(ext) => find_by_ext(ext)
  }
}

///|
///按扩展名在语言表中查找。
fn find_by_ext(ext : String) -> Lang? {
  for lang in builtin_langs() {
    for e in lang.exts {
      if e == ext {
        return Some(lang)
      }
    }
  }
  None
}

///|
///取路径中的扩展名（最后一个点号之后的部分）。
///
///路径中不含点号、或最后一个点号后为空时返回 `None`。
pub fn ext_of(path : String) -> String? {
  let mut sb = StringBuilder()
  let mut found = false
  for ch in path {
    if ch == '.' {
      found = true
      sb = StringBuilder()
    } else {
      sb.write_char(ch)
    }
  }
  if found {
    let ext = sb.to_string()
    if ext.length() > 0 {
      return Some(ext)
    }
  }
  None
}
