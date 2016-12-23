# Feature toggles via CMake variables

FeatureToggles.cmake adds simple feature toggles via CMake options, configurable via cmake, ccmake or the CMake GUI
to any project. This cmake script will generate a header file in your project with `#define` lines that correspond
to the state of the feature toggles.

The reason for generating a file instead of passing the definitions to the compiler is that it makes them available
for other dependent projects without an explicit dependency chain.

## Prerequisites

* [CMake 3.2][1]

## Getting started

To get started copy FeatureToggles.cmake to a suitable location in your project. I'd personally recommend using git
submodules if you are using git and your git client supports submodules:

```sh
git submodule add https://github.com/grover/CMakeFeatureToggles
```

## Using

Given the following example CMakeList.txt:

```cmake
cmake_minimum_required(VERSION 3.2)

project(Foo)

add_executable(Foo
  foo.c)
```

Your first step is to include FeatureToggles.cmake at the top:

```cmake
include(FeatureToggles.cmake)
```

After that you can add feature toggles:

```cmake
add_feature_toggle(Foo ENABLE_FEATURE_1 "Include feature 1." OFF)
add_feature_toggle(Foo COMPRESSION_LEVEL "Default ZLib compression level." 6)
```

Finally you have to tell which header file to put the feature toggles into:

```cmake
set_feature_toggle_header(Foo foo_config.h)
```

To force generation of `foo_config.h` you finally have to add it to the target. The full CMakeList.txt after all changes
have been applied:

```cmake
cmake_minimum_required(VERSION 3.2)

include(../FeatureToggles.cmake)

project(Foo)

add_executable(Foo
  foo.c
  foo_config.h)

add_feature_toggle(Foo ENABLE_FEATURE_1 "Include feature 1." OFF)
add_feature_toggle(Foo COMPRESSION_LEVEL "Default ZLib compression level." 6)
set_feature_toggle_header(Foo foo_config.h)
```

And the resulting header file:

```C
/**
 * Automatically generated configuration header file from CMake options
 *
 * The license of the project that created this configuration file
 * applies.
 *
 */

#ifndef FOO_CONFIG_H
#define FOO_CONFIG_H

#define FOO_FEATURE_COMPRESSION_LEVEL 6
#undef FOO_FEATURE_ENABLE_FEATURE_1

#endif /* FOO_CONFIG_H */
```

Please not that `FOO_FEATURE_ENABLE_FEATURE_1` is `#undef`'ed as the option is OFF. These options
can be configured via any of the cmake tools.

The example project is also in this repository.

[1]: https://cmake.org/
