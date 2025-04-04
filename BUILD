load(
    "//:pip_tags.bzl",
    "pip_and_srcs_lists",
    "pip_names_query",
    "pips_from_metadata_files",
    "pips_from_metadata_files_aspect",
    "requirements",
)
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
        "//foo",
        "//bar",
        "//baz",
        "@pips//pyfakefs",
        "@pips//urllib3",
    ],
)

pip_names_query(
    name = "names.json",
    target = ":testlib",
)

pip_and_srcs_lists(
    name = "lists",
    deps = [":testlib"],
    pip_list = "pip-list.txt",
    srcs_list = "srcs-list.txt",
)

pips_from_metadata_files(
    name = "metas",
    deps = [":testlib"],
    meta_list = "meta-list.txt",
)

pips_from_metadata_files_aspect(
    name = "aspect",
    deps = [":testlib"],
    aspect_list = "aspect-list.txt",
)

requirements(
    name = "requirements_file",
    deps = [":testlib"],
    requirements_file = "requirements.txt",
)
