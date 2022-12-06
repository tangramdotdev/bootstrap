#![warn(clippy::pedantic)]
use clap::Parser;
use create_wrapper::{cgen, move_file};
use std::{collections::HashMap, path::PathBuf, process::ExitCode};

#[derive(Parser)]
struct Args {
	#[clap(long, help = "The executable to create a wrapper for")]
	executable: PathBuf,
	#[clap(
		long,
		help = "Environment to add.  `.` and `..` in the leading position are relative to the executable"
	)]
	env: Vec<String>,
	#[clap(long, help = "The type of wrapper to produce, ld_musl or script")]
	flavor: Flavor,
	#[clap(long, help = "The path to the interpreter, relative to the executable")]
	interpreter: PathBuf,
}

/// This tool supports wrapping against musl's ld-linux ELF interpreter or a scripting language interpreter.
#[derive(Clone, Copy, PartialEq)]
enum Flavor {
	LdMusl,
	Script,
}

impl std::str::FromStr for Flavor {
	type Err = std::io::Error;
	fn from_str(s: &str) -> Result<Self, Self::Err> {
		match s {
			"ld_musl" => Ok(Flavor::LdMusl),
			"script" => Ok(Flavor::Script),
			_ => Err(std::io::Error::new(
				std::io::ErrorKind::InvalidInput,
				"unsupported interpreter flavor",
			)),
		}
	}
}

fn main() -> ExitCode {
	let args = Args::parse();
	let ctx = create_wrapper::ToolContext::get();

	// Environment to set in the wrapper.
	let mut relative_envs: HashMap<String, PathBuf> = HashMap::new();
	for env in args.env {
		let (key, val) = env.split_once('=').unwrap();
		relative_envs.insert(key.to_string(), PathBuf::from(val));
	}
	// Construct a list of C expressions to build the env vars.
	let env_vars = relative_envs
		.iter()
		.map(|(key, val)| cgen::env_var(&cgen::string(key), &cgen::tg_relative(val)));
	let env_vars = cgen::array(env_vars);

	// Move unwrapped file
	let unwrapped_out_path = PathBuf::from(&format!(".{}", args.executable.file_name().unwrap().to_str().unwrap()));
	let out_path = args.executable;
	move_file(&out_path, &unwrapped_out_path).expect("Unable to move unwrapped file");

	let lib_path_exprs = [cgen::tg_relative("../lib")];

	let interpreter_link = args.interpreter;

	// Proc/self/exe hack is not used in the bootstrap_tools.
	let proc_self_exe_hack = false;
	let preload_exprs = cgen::array([]);

	let flavor = match args.flavor {
		Flavor::LdMusl => "TG_INTERPRETER_FLAVOR_LD_LINUX",
		Flavor::Script => "TG_INTERPRETER_FLAVOR_SCRIPT",
	};

	// Compile a statically-linked wrapper executable that calls the unwrapped executable. We clear the environment variables so that $PATH and others don't interfere with the static toolchain. We also set an env var to prevent wrapping recursively.
	let cc_wrapper_result = std::process::Command::new(&ctx.static_cc)
		.arg("-static")
		.arg("-s")
		.arg("-O3")
		.arg("-o")
		.arg(&out_path)
		.arg(cgen::set_macro(
			"TG_EXECUTABLE",
			&cgen::tg_relative(unwrapped_out_path),
		))
		.arg(cgen::set_macro(
			"TG_INTERPRETER",
			&cgen::tg_relative(interpreter_link),
		))
		.arg(cgen::set_macro(
			"TG_INTERPRETER_FLAVOR",
			&cgen::ident(flavor),
		))
		.arg(cgen::set_macro("TG_ENV_VARS", &env_vars))
		.arg(cgen::set_macro(
			"TG_LIBRARY_PATHS",
			&cgen::array(lib_path_exprs),
		))
		.arg(cgen::set_macro("TG_PRELOADS", &preload_exprs))
		.arg(cgen::set_macro(
			"TG_EXECUTABLE_PATH_IMPORT",
			&cgen::boolean(false),
		))
		.arg(cgen::set_macro(
			"TG_EXECUTABLE_PATH_EXPORT",
			&cgen::boolean(proc_self_exe_hack),
		))
		.arg(ctx.wrapper_source.join("wrapper.c"))
		.env_clear()
		.env("TG_LINKER_DISABLE_WRAP_EXECUTABLE", "true")
		.status()
		.expect("failed to execute static CC process");

	// Return an error if compilation failed. Since this compilation is purely internal, we don't try to preserve the exit code.
	assert!(
		cc_wrapper_result.success(),
		"failed to compile wrapper binary (exit status {cc_wrapper_result:?}"
	);

	ExitCode::SUCCESS
}
