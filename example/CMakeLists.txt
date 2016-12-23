
cmake_minimum_required(VERSION 3.2)

include(../FeatureToggles.cmake)

project(Foo)

add_executable(Foo
  foo.c
  foo_config.h)

add_feature_toggle(Foo ENABLE_FEATURE_1 "Include feature 1." OFF)
add_feature_toggle(Foo COMPRESSION_LEVEL "Default ZLib compression level." 6)
set_feature_toggle_header(Foo foo_config.h)
