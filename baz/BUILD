load("@rules_python//python:py_library.bzl", "py_library")

py_library(
    name = "baz",
    srcs = [
        "__init__.py",
        "baz.py",
    ],
    deps = [
        "@pips//urllib3",
        "@pips//zipp",
    ],
    visibility = ["//visibility:public"],
)

