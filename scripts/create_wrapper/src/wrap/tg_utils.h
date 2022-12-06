#ifndef TG_UTILS_H
#define TG_UTILS_H

// When set to `true`, the current executable path can be set at runtime using the `$TG_WRAPPER_EXECUTABLE_PATH` environment variable.
#ifndef TG_EXECUTABLE_PATH_IMPORT
#error "TG_EXECUTABLE_PATH_IMPORT must be defined!"
#endif

// When set to `true`, the environment variable `$TG_WRAPPER_EXECUTABLE_PATH` will be set when `tg_set_executable_path()` is called.
#ifndef TG_EXECUTABLE_PATH_EXPORT
#error "TG_EXECUTABLE_PATH_EXPORT must be defined!"
#endif

#include <errno.h>
#include <libgen.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/auxv.h>
#include <unistd.h>

#define TG_ARRAY_LENGTH(array) sizeof(array) / sizeof(array[0])

typedef enum tg_env_var_behavior {
	TG_ENV_VAR_DEFAULT,
	TG_ENV_VAR_OVERRIDE
} tg_env_var_behavior;

typedef struct tg_env_var {
	char* name;
	char* value;
	tg_env_var_behavior behavior;
} tg_env_var;

static void tg_bail(const char* msg) {
	const char label[] = "tangram wrapper: ";
	char* buf = (char*)calloc(1, sizeof(label) + strlen(msg) + 2 /* NUL + \n */);
	if (buf == NULL) {
		_exit(124);
	}
	strcat(buf, label);
	strcat(buf, msg);
	strcat(buf, "\n");
	fputs(buf, stderr);
	_exit(123);
}

static void tg_bail_errno(const char* msg) {
	char errno_str[] = ": errno \0\0\0";
	errno_str[8] = '0' + (errno / 100) % 10;
	errno_str[9] = '0' + (errno / 10) % 10;
	errno_str[10] = '0' + (errno / 1) % 10;

	char* buf = (char*)calloc(1, strlen(msg) + sizeof(errno_str) + 1);
	if (buf == NULL) {
		_exit(124);
	}

	strcat(buf, msg);
	strcat(buf, errno_str);
	tg_bail(buf);
}

static void tg_assert(bool cond, const char* failure_msg) {
	if (!cond) {
		tg_bail(failure_msg);
	}
}

static void tg_check_alloc(void* ptr) {
	tg_assert(ptr != NULL, "failed to allocate");
}

static bool tg_is_str_empty(char* str) {
	return str == NULL || *str == '\0';
}

static char* tg_str_clone(char* source) {
	char* cloned = (char*)calloc(1, strlen(source) + 1);
	tg_check_alloc(cloned);

	strcpy(cloned, source);

	return cloned;
}

static size_t tg_items_length(char** items) {
	// Calculate the length of `items` by iterating until we find `NULL`.
	size_t items_length = 0;
	while (items[items_length] != NULL) {
		items_length++;
	}
}

typedef struct tg_list {
	size_t capacity;
	size_t length;
	char** items;
} tg_list;

static tg_list tg_list_create(size_t capacity) {
	// Build a new empty list.
	tg_list new_list;
	new_list.capacity = capacity + 1; // Add one extra space for NULL.
	new_list.length = 0;

	new_list.items = (char**)calloc(sizeof(char*), new_list.capacity);
	tg_check_alloc(new_list.items);

	// Set the first item to NULL.
	new_list.items[0] = NULL;

	return new_list;
}

/**
 * Ensure that a list has enough space for at least `new_length` items. The
 * list will be resized as needed.
 */
static void tg_list_grow(tg_list* list, size_t new_length) {
	size_t new_capacity = new_length + 1;
	if (new_capacity > list->capacity) {
		// Allocate a new array. We avoid realloc to decrease binary size.
		char** new_items = (char**)calloc(sizeof(char*), new_capacity);
		tg_check_alloc(new_items);

		size_t current_length = list->length;
		for (size_t i = 0; i < current_length; ++i) {
			new_items[i] = list->items[i];
		}

		list->items = new_items;
		list->capacity = new_capacity;
	}
}

static void tg_append(tg_list* list, char* item) {
	size_t new_list_length = list->length + 1;

	// Resize the list if we need to.
	tg_list_grow(list, new_list_length);

	// Append the item.
	list->items[new_list_length - 1] = item;
	list->items[new_list_length] = NULL;

	// Update the list length.
	list->length = new_list_length;
}

static void tg_append_all(tg_list* list, char** items, size_t items_length) {
	size_t initial_list_length = list->length;
	size_t new_list_length = initial_list_length + items_length;

	// Resize the list if we need to.
	tg_list_grow(list, new_list_length);

	// Copy over items from the array.
	for (size_t i = 0; i < items_length; ++i) {
		list->items[initial_list_length + i] = items[i];
	}

	// Add the NULL terminator.
	list->items[new_list_length] = NULL;

	// Update the list length.
	list->length = new_list_length;
}

// Get an environment variable.
static inline char* tg_getenv(const char* name) {
	return getenv(name);
}

// Set an environment variable if it's unset.
static inline void tg_setenv_default(const char* name, const char* value) {
	if (setenv(name, value, 0 /* no overwrite */) == -1) {
		tg_bail_errno("failed to set environment variable with default");
	}
}

// Set an environment variable unconditionally.
static inline void tg_setenv(const char* name, const char* value) {
	if (setenv(name, value, 1 /* overwrite */) == -1) {
		tg_bail_errno("failed to set environment variable");
	};
}


static char* cached_executable_path = NULL;

/**
 * Set the canonical path to the current executable. When called, this will set the value returned by `tg_executable_path()` (and will optionally set the `$TG_WRAPPER_EXECUTABLE_PATH` environment variable).
 */
static void tg_set_executable_path(char* path) {
	// Set the environment variable to the provided value.
	cached_executable_path = path;

#if TG_EXECUTABLE_PATH_EXPORT == true
	// Set the environment variable (if configured to).
	if (setenv("TG_WRAPPER_EXECUTABLE_PATH", path, true) == -1) {
		tg_bail_errno("failed to export $TG_WRAPPER_EXECUTABLE_PATH");
	}
#endif
}

/**
 * Get the canonical path to the current executable. The current executable path should be set explicitly by calling `tg_set_executable_path()` before this method is called (or by setting `$TG_WRAPPER_EXECUTABLE_PATH` if using the environment variable is enabled).
 *
 * While it would ideally be possible for this function to work without any extra context, there are a number of challenges when using this function in different environments:
 *
 * - Using /proc/self/exe: Not practical for the implementation of the "$LD_PRELOAD" library.
 * - Using the AT_EXECFN auxiliary vector: Doesn't seem to work on ARM64, and also doesn't seem to work in musl.
 * - Using argv[0]: Difficult to resolve to an absolute path, unreliable, not practical for the implementation of the "$LD_PRELOAD" library.
 *
 * As a compromise, `tg_set_executable_path` can be used to explicitly set the executable path based on whichever method works best for the context. Using `$TG_WRAPPER_EXECUTABLE_PATH` is also a simple compromise that works well for the `$LD_PRELOAD` library.
 */
static char* tg_executable_path() {
	// Return the existing value if already set.
	if (cached_executable_path != NULL) {
		return cached_executable_path;
	}

#if TG_EXECUTABLE_PATH_IMPORT == true
	// Read the environment variable and return a copy if set.
	char* env_exe_path = getenv("TG_WRAPPER_EXECUTABLE_PATH");
	if (env_exe_path != NULL && *env_exe_path != '\0') {
		cached_executable_path = tg_str_clone(env_exe_path);
		return cached_executable_path;
	}

	// Bail because the executable path should have been set with an environment variable.
	tg_bail("$TG_WRAPPER_EXECUTABLE_PATH is not set");

#else

	// Bail because the executable path should have been set explicitly.
	tg_bail("executable path not set");

#endif
}

/**
 * Get the length of the path returned by `tg_executable_path`.
 */
static size_t tg_executable_path_length() {
	static size_t cached_executable_path_length = 0;
	if (cached_executable_path_length > 0) {
		return cached_executable_path_length;
	}

	cached_executable_path_length = strlen(tg_executable_path());
	return cached_executable_path_length;
}

/**
 * Get the path to the currently-executing wrapper executable.
 */
static char* tg_executable_dir() {
	// Don't recompute if called multiple times
	static char* cached_executable_dir = NULL;
	if (cached_executable_dir) {
		return cached_executable_dir;
	}

	// Get the location of the binary from the auxiliary vector.
	char* raw_path = (char*)getauxval(AT_EXECFN);

	// Canonicalize the path, resolving '.' and '..' terms (as well as any symlinks).
	char* executable_path = realpath(raw_path, NULL);
	if (executable_path == NULL) {
		tg_bail_errno("failed to canonicalize path to wrapper");
	}

	// Strip the filename.
	char* executable_dir = dirname(executable_path);
	// free(executable_path); // Don't bother freeing anything.

	cached_executable_dir = executable_dir;
	return cached_executable_dir;
}

/**
 * Absolutize a path relative to this executable's location.
 */
static char* tg_relative(const char* relative_path) {
	char* dir = tg_executable_dir();

	char* buf = (char*)calloc(1, strlen(dir) + strlen(relative_path) + 2);
	tg_check_alloc(buf);
	strcat(buf, dir);
	strcat(buf, "/");
	strcat(buf, relative_path);

	return buf;
}

// Filled in by the C library
extern char** environ;

__attribute__((noreturn)) static void tg_exec(char* program, tg_list args) {
	if (execv(program, args.items) == -1) {
		tg_bail_errno("failed to exec");
	}
	__builtin_unreachable();
}

static char* tg_list_join(tg_list list, char* sep) {
	if (list.length == 0) {
		return "";
	}

	// Reserve enough space for (n - 1) string separators, plus the NUL character.
	size_t joined_size = ((list.length - 1) * strlen(sep)) + 1;

	// Add space for each string in the list.
	for (size_t i = 0; i < list.length; ++i) {
		joined_size += strlen(list.items[i]);
	}

	// Allocate the output string.
	char* joined = (char*)calloc(1, joined_size);
	tg_check_alloc(joined);

	// Concatenate all the list items with separators between.
	for (size_t i = 0; i < list.length; ++i) {
		if (i != 0) {
			strcat(joined, sep);
		}

		strcat(joined, list.items[i]);
	}

	return joined;
}

static char* tg_join_strings(size_t length, char** strings) {
	if (length == 0) {
		return "";
	}

	if (length == 1) {
		return strings[0];
	}

	// Reserve enough space for (n - 1) string separators, plus the NUL character.
	size_t joined_size = 1;

	// Add space for each string in the list.
	for (size_t i = 0; i < length; ++i) {
		joined_size += strlen(strings[i]);
	}

	// Allocate the output string.
	char* joined = (char*)calloc(1, joined_size);
	tg_check_alloc(joined);

	// Concatenate all the list items with separators between.
	for (size_t i = 0; i < length; ++i) {
		strcat(joined, strings[i]);
	}

	return joined;
}

#endif // TG_UTILS_H
