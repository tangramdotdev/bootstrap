// This file is compiled when calling `wrapBins` from `tangram:std`. When
// called, there are several macros that are set on the command line:
// - `TG_INTERPRETER`: Expression that evaluates to a `char*` path to the
// interpreter. Example value: 'tg_relative("../../deps/ld-linux-x86-64.so.2")'
// - `TG_EXECUTABLE`: Expression that evaluates to a `char*` path to the wrapped
// executable. Example value: 'tg_relative("./.tg-hello")'
// - `TG_LIBRARY_PATHS`: Array literal ('{ ... }') of expressions that evaluate to `char*` paths to dynamic library search directories. The returned expression is not NULL-terminated, and the length can be found with the `TG_ARRAY_LENGTH` macro. Example value: '{ tg_relative("../../deps/libc/lib") }'
// - `TG_ENV_VARS`: Array literal of `tg_env_var` structs. Example value: `{ (tg_env_vars){ "PATH", "/usr/local/bin", TG_ENV_VAR_DEFAULT } }

#define TG_INTERPRETER_FLAVOR_LD_LINUX 1
#define TG_INTERPRETER_FLAVOR_SCRIPT 2

#if !defined(TG_INTERPRETER_FLAVOR)
#error "TG_INTERPRETER_FLAVOR macro must be defined!"
#endif

#if !defined(TG_INTERPRETER)
#error "TG_INTERPRETER macro must be defined!"
#endif

#if !defined(TG_EXECUTABLE)
#error "TG_EXECUTABLE macro must be defined!"
#endif

#if !defined(TG_ENV_VARS)
#error "TG_ENV_VARS macro must be defined!"
#endif

#if !defined(TG_LIBRARY_PATHS)
#error "TG_LIBRARY_PATHS macro must be defined!"
#endif

#include <linux/limits.h>
#include "tg_utils.h"

int main(int argc, char** argv) {
	char* interpreter = TG_INTERPRETER;
	char* executable = TG_EXECUTABLE;
	tg_env_var tg_env_vars[] = TG_ENV_VARS;
	size_t tg_env_vars_length = TG_ARRAY_LENGTH(tg_env_vars);
	char* tg_library_paths[] = TG_LIBRARY_PATHS;
	size_t tg_library_paths_length = TG_ARRAY_LENGTH(tg_library_paths);
	char* tg_preloads[] = TG_PRELOADS;
	size_t tg_preloads_length = TG_ARRAY_LENGTH(tg_preloads);

	char* interpreter_library_path = NULL;
	char* interpreter_preload = NULL;

	// Allocate a buffer to read the path of the current process using the symlink `/proc/self/exe`.
	size_t proc_self_exe_path_buf_length = PATH_MAX + 1;
	char* proc_self_exe_path_buf = (char*)calloc(1, proc_self_exe_path_buf_length);
	tg_check_alloc(proc_self_exe_path_buf);

	size_t proc_self_exe_path_length = readlink("/proc/self/exe", proc_self_exe_path_buf, proc_self_exe_path_buf_length);

	if (proc_self_exe_path_length < 0) {
		// Failed to read /proc/self/exe.

		tg_bail_errno("failed to read link /proc/self/exe");
	} else if (proc_self_exe_path_length >= proc_self_exe_path_buf_length) {
		// The path was truncated (meaning the path was longer than the buffer length).

		tg_bail("maximum path size exceeded for path of /proc/self/exe");
	}

	// NUL-terminate the path.
	proc_self_exe_path_buf[proc_self_exe_path_length] = '\0';

	// Set /proc/self/exe as the executable path.
	tg_set_executable_path(proc_self_exe_path_buf);

	// Override the interpreter's library paths only if we have Tangram-managed dynamic libraries to load.
	if (tg_library_paths_length > 0) {
		// Create a new list. The new list will be joined with $LIBRARY_PATH if set, so increase the capacity by 1.
		tg_list library_path_list = tg_list_create(tg_library_paths_length + 1);

		// Add $LD_LIBRARY_PATH first if set.
		char* env_library_path = getenv("LD_LIBRARY_PATH");
		if (!tg_is_str_empty(env_library_path)) {
			// Clone the string (getenv is not guaranteed to be reentrant).
			tg_append(&library_path_list, tg_str_clone(env_library_path));
		}

		// Add all the Tangram dynamic libraries.
		tg_append_all(&library_path_list, tg_library_paths,
									tg_library_paths_length);

		// Join all the library paths into a colon-separated string.
		interpreter_library_path = tg_list_join(library_path_list, ":");
	}

	// Override the interpreter's preload paths only if we have Tangram-managed preloads to load.
	if (tg_preloads_length > 0) {
		// Create a new list. The new list will be joined with $LD_PRELOAD if set,
		// so increase the capacity by 1.
		tg_list preload_list = tg_list_create(tg_preloads_length + 1);

		// Add $LD_PRELOAD first if set.
		char* env_preload = getenv("LD_PRELOAD");
		if (!tg_is_str_empty(env_preload)) {
			// Clone the string (getenv is not guaranteed to be reentrant).
			tg_append(&preload_list, tg_str_clone(env_preload));
		}

		// Add all the Tangram preloads.
		tg_append_all(&preload_list, tg_preloads, tg_preloads_length);

		// Join all the preloads into a colon-separated string.
		interpreter_preload = tg_list_join(preload_list, ":");
	}

	// Set environment variables.
	for (size_t i = 0; i < tg_env_vars_length; ++i) {
		setenv(tg_env_vars[i].name, tg_env_vars[i].value, tg_env_vars[i].behavior == TG_ENV_VAR_OVERRIDE);
	}

	// Create a list of arguments.
	tg_list arg_list = tg_list_create(argc + 6);

	// Set arg0 to the interpreter.
	tg_append(&arg_list, interpreter);

	// Set options specific for ld-linux.so.
#if TG_INTERPRETER_FLAVOR == TG_INTERPRETER_FLAVOR_LD_LINUX

	// Add the library paths if set.
	if (!tg_is_str_empty(interpreter_library_path)) {
		tg_append(&arg_list, "--library-path");
		tg_append(&arg_list, interpreter_library_path);
	}

	// Add the preloads if set.
	if (!tg_is_str_empty(interpreter_preload)) {
		tg_append(&arg_list, "--preload");
		tg_append(&arg_list, interpreter_preload);
	}

	// Set arg0 to the original executable's name instead of the '.tg-' name.
	if (argc >= 1) {
		tg_append(&arg_list, "--argv0");
		tg_append(&arg_list, argv[0]);
	}

#endif // TG_INTERPRETER_FLAVOR == TG_INTERPRETER_FLAVOR_LD_LINUX

	// Call the original executable.
	tg_append(&arg_list, executable);

	// Pass the remaining arguments.
	if (argc >= 1) {
		tg_append_all(&arg_list, &argv[1], argc - 1);
	}

	// Invoke the interpreter to run the original executable.
	tg_exec(interpreter, arg_list);
}
