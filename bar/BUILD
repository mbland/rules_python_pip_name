load("@rules_python//python:py_library.bzl", "py_library")

py_library(
    name = "bar",
    srcs = [
        "__init__.py",
        "bar.py",
    ],
    deps = ["@pips//urllib3"],
    visibility = ["//visibility:public"],
)

