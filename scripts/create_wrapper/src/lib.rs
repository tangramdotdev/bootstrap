#![warn(clippy::pedantic)]
#![allow(clippy::missing_errors_doc)]
#![allow(clippy::missing_panics_doc)]

use std::path::{Path, PathBuf};
use which::which;

pub mod cgen;

/// Common settings for a linker wrapper tool. These settings are derived primarily from compile-time environment variables.
pub struct ToolContext {
	pub static_cc: PathBuf,
	pub wrapper_source: PathBuf,
	pub default_enable_proc_self_exe_hack: bool,
	pub disable_wrap_executable: bool,
}

impl ToolContext {
	#[must_use]
	pub fn get() -> Self {
		let static_cc = which("gcc").unwrap();

		let scripts = std::env::var("SCRIPTS");
		let wrapper_source;
		if let Ok(dir) = scripts.as_deref() {
			wrapper_source = PathBuf::from(dir).join("wrap");
		} else {
			eprintln!("$SCRIPTS must be set!");
			std::process::exit(1);
		};

		let env_tg_linker_proc_self_exe_hack = std::env::var("TG_LINKER_PROC_SELF_EXE_HACK");
		let default_enable_proc_self_exe_hack =
			matches!(env_tg_linker_proc_self_exe_hack.as_deref(), Ok("true"));

		let env_tg_linker_disable_wrap_executable =
			std::env::var("TG_LINKER_DISABLE_WRAP_EXECUTABLE");
		let disable_wrap_executable =
			matches!(env_tg_linker_disable_wrap_executable.as_deref(), Ok("true"));

		Self {
			static_cc,
			wrapper_source,
			default_enable_proc_self_exe_hack,
			disable_wrap_executable,
		}
	}
}

/// Move a file from `source` to `target`. This function is similar to `std::fs::rename`, but it also supports crossing devices by first copying the file then deleting the source.
pub fn move_file(source: impl AsRef<Path>, target: impl AsRef<Path>) -> std::io::Result<()> {
	let source = source.as_ref();
	let target = target.as_ref();

	match std::fs::rename(source, target) {
		Ok(()) => Ok(()),
		Err(error) => {
			match error.kind() {
				std::io::ErrorKind::NotFound | std::io::ErrorKind::PermissionDenied => {
					// Short-circuit and don't retry if we know for sure that the error wasn't caused by crossing the filesystem boundary.
					Err(error)
				},
				_ => {
					std::fs::copy(source, target)?;
					std::fs::remove_file(source)?;
					Ok(())
				},
			}
		},
	}
}
