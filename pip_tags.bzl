"""Macros and rules that parse PyPI information from py_library targets."""

load("@rules_python//python:defs.bzl", "PypiInfo")

_THIS_REPO = Label("//:unused").repo_name

def pip_names_query(name, target):
    target = native.package_relative_label(target)
    native.genquery(
        name = name,
        expression = "attr('tags', 'pypi_name=.*', deps(%s))" % target,
        scope = [target],
        opts = ["--output=streamed_jsonproto"],
    )

def _pip_names_impl(ctx):
    direct_deps = [dep for dep in ctx.attr.deps if PypiInfo in dep]
    indirect_deps = [dep[PypiInfo].pypi_deps for dep in direct_deps]
    all_deps = depset(direct = direct_deps, transitive = indirect_deps)

    # Here we could return a `provider` containing anything we want out of
    # `all_deps`. For this example, we just write the names out to a file.
    infos = [dep[PypiInfo] for dep in all_deps.to_list()]
    names = [info.name for info in infos if hasattr(info, "name")]
    ctx.actions.write(ctx.outputs.output, "\n".join(sorted(names)) + "\n")

pip_names = rule(
    implementation = _pip_names_impl,
    attrs = {
        "deps": attr.label_list(),
        "output": attr.output(),
    },
)
