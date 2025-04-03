load("//:pip_tags.bzl", "pip_names", "pip_names_query")
load("@rules_python//python:pip.bzl", "compile_pip_requirements")
load("@rules_python//python:py_library.bzl", "py_library")

compile_pip_requirements(
    name = "requirements",
    src = "requirements.in",
    requirements_txt = "requirements_lock.txt",
)

py_library(
    name = "testlib",
    deps = [
        "@pips//pyfakefs",
        "@pips//urllib3",
        "@pips//zipp",
    ],
)

pip_names_query(
    name = "names.json",
    target = ":testlib",
)

pip_names(
    name = "names",
    deps = [":testlib"],
    output = "names.txt",
)
