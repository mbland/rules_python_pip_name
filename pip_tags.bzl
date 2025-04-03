"""Macros and rules that parse PyPI information from py_library targets."""

load("@rules_python//python:defs.bzl", "PyInfo", "PypiInfo")

_THIS_REPO = Label("//:unused").repo_name

def pip_names_query(name, target):
    target = native.package_relative_label(target)
    native.genquery(
        name = name,
        expression = "attr('tags', 'pypi_name=.*', deps(%s))" % target,
        scope = [target],
        opts = ["--output=streamed_jsonproto"],
    )

def _pip_and_srcs_lists_impl(ctx):
    direct_pypi_deps = [dep for dep in ctx.attr.deps if PypiInfo in dep]
    indirect_deps = [dep[PypiInfo].pypi_deps for dep in direct_pypi_deps]
    all_deps = depset(direct = direct_pypi_deps, transitive = indirect_deps)

    # Here we could return a `provider` containing anything we want out of
    # `all_deps`. For this example, we just write the names out to a file.
    infos = [dep[PypiInfo] for dep in all_deps.to_list()]
    names = [info.name for info in infos if hasattr(info, "name")]
    ctx.actions.write(ctx.outputs.pip_list, "\n".join(sorted(names)) + "\n")

    # Now write out all the transitive sources belonging to this repo.
    transitive_srcs = [
        dep[PyInfo].transitive_original_sources
        for dep in ctx.attr.deps
        if PyInfo in dep
    ]
    srcs = [
        src.path
        for src in depset(transitive = transitive_srcs).to_list()
        if src.owner.repo_name == _THIS_REPO
    ]
    ctx.actions.write(ctx.outputs.srcs_list, "\n".join(sorted(srcs)) + "\n")

pip_and_srcs_lists = rule(
    implementation = _pip_and_srcs_lists_impl,
    attrs = {
        "deps": attr.label_list(),
        "pip_list": attr.output(),
        "srcs_list": attr.output(),
    },
)
