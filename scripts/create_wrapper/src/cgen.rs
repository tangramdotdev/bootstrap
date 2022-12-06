//! This module is used for generating C code. This is used when compiling the binary wrapper C code, where macros are set to C expressions when calling the compiler.
//!
//! The primary entry point for this module is the `set_macro` function, which takes a macro name and C expression, and returns an argument that can be passed to a C compiler (say, gcc). To prevent passing invalid values, the `CExpr` wrapper type is used to represent arbitrary C expressions, and this module exposes multiple helpers for creating `CExpr` values.

use std::{os::unix::prelude::OsStrExt, path::Path};

/// An expression that can be injected in a C source file as a macro.
#[derive(Debug, Clone)]
pub struct CExpr(String);

impl CExpr {
	#[must_use]
	pub fn unescaped(value: &str) -> Self {
		CExpr(value.to_owned())
	}
}

/// Build an argument for a C compiler, where the macro `macro_name` is set to the given C expression. The returned argument uses the syntax `-DNAME=value`. This is meant to be used when constructing a `std::process::Command`.
#[must_use]
pub fn set_macro(macro_name: &str, value: &CExpr) -> String {
	assert!(is_valid_c_ident(macro_name));

	format!("-D{macro_name}={}", value.0)
}

/// Convert a string or array of bytes to a literal C string expression. Special characters and non-ASCII byte values are escaped appropriately.
pub fn string(bytes: impl AsRef<[u8]>) -> CExpr {
	let bytes = bytes.as_ref();

	// Allocate enough space for each byte, plus an opening and closing quote.
	let mut string = String::with_capacity(bytes.len() + 2);

	// Add opening quote.
	string.push('"');

	// Add an escape for each byte.
	for &byte in bytes {
		match byte {
			// Backslash.
			b'\\' => string.push_str("\\\\"),
			// Double quote.
			b'"' => string.push_str("\\\""),
			// Single quote.
			b'\'' => string.push_str("\\'"),
			// Question mark (avoids conflicts with trigraphs).
			b'?' => string.push_str("\\?"),
			// Normal printable ASCII characters.
			0x20..=0xFE => string.push(char::from(byte)),
			// Non-printable characters.
			0x07 => string.push_str("\\a"),
			0x08 => string.push_str("\\b"),
			0x1B => string.push_str("\\e"),
			0x0C => string.push_str("\\f"),
			0x0A => string.push_str("\\n"),
			0x0D => string.push_str("\\r"),
			0x09 => string.push_str("\\t"),
			0x0B => string.push_str("\\v"),
			// Byte literal.
			byte => string.push_str(&format!("\\x{:02x}", byte)),
		}
	}

	// Add closing quote.
	string.push('"');

	CExpr(string)
}

/// Convert a named C identifier to a C expression. This function asserts that the given name is a valid C identifier. This is useful when using a pre-defined enum value.
#[must_use]
pub fn ident(name: &str) -> CExpr {
	assert!(is_valid_c_ident(name));

	CExpr(name.to_string())
}

fn is_valid_c_ident(name: &str) -> bool {
	!name.is_empty()
		&& name.trim_start_matches(is_valid_c_ident_char).is_empty()
		&& name.starts_with(is_valid_c_initial_ident_char)
}

fn is_valid_c_ident_char(c: char) -> bool {
	match c {
		c if c.is_ascii_alphanumeric() => true,
		'_' => true,
		_ => false,
	}
}

fn is_valid_c_initial_ident_char(c: char) -> bool {
	is_valid_c_ident_char(c) && !c.is_numeric()
}

/// Convert a boolean to a C expression. This assumes that the C code using this expression either includes `stdbool.h` or otherwise defines `true` and `false` macros/enums/constants.
#[must_use]
pub fn boolean(boolean: bool) -> CExpr {
	if let true = boolean {
		ident("true")
	} else {
		ident("false")
	}
}

/// Convert an iterator of C expressions to a C array expression.
pub fn array(exprs: impl IntoIterator<Item = CExpr>) -> CExpr {
	let items = exprs.into_iter().map(|expr| expr.0).collect::<Vec<_>>();

	// Join each expression with a ',' and surround with '{ }'
	CExpr(format!("{{ {} }}", items.join(", ")))
}

/// Construct a C expression that calls the `tg_relative` C function with the given path as a literal string argument.
pub fn tg_relative(path: impl AsRef<Path>) -> CExpr {
	let path = path.as_ref();
	CExpr(format!(
		"tg_relative({})",
		string(path.as_os_str().as_bytes()).0
	))
}

/// Convert an iterator of C expressions to a C  expression.
#[must_use]
pub fn env_var(key: &CExpr, val: &CExpr) -> CExpr {
	// Join each expression with a ',' and surround with '{ }'
	CExpr(format!("(tg_env_var){{ {}, {} }}", key.0, val.0))
}
