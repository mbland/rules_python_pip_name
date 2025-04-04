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

def _collect_runfiles(deps):
    return depset(transitive = [
        dep[DefaultInfo].default_runfiles.files
        for dep in deps
    ])

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
    runfiles = _collect_runfiles(ctx.attr.deps).to_list()
    srcs = [src.path for src in runfiles if src.owner.repo_name == _THIS_REPO]
    ctx.actions.write(ctx.outputs.srcs_list, "\n".join(sorted(srcs)) + "\n")

pip_and_srcs_lists = rule(
    implementation = _pip_and_srcs_lists_impl,
    attrs = {
        "deps": attr.label_list(),
        "pip_list": attr.output(),
        "srcs_list": attr.output(),
    },
)

def _name_from_metadata_path(f):
    # Presumes that the version suffix itself doesn't contain "-".
    p = f.dirname.removesuffix(".dist-info").rsplit("-", 1)[0]
    # Not sure if this will work on Windows.
    return p.rsplit("/", 1)[1]

def _collect_pip_names_from_metadata_files(deps):
    return [
        _name_from_metadata_path(f)
        for f in _collect_runfiles(deps).to_list()
        if f.basename == "METADATA"
    ]

def _pips_from_metadata_files(ctx):
    names = _collect_pip_names_from_metadata_files(ctx.attr.deps)
    ctx.actions.write(ctx.outputs.meta_list, "\n".join(sorted(names)) + "\n")

pips_from_metadata_files = rule(
    implementation = _pips_from_metadata_files,
    attrs = {
        "deps": attr.label_list(),
        "meta_list": attr.output(),
    },
)

PypiAspectInfo = provider(
    "PyPI metadata returned by pypi_info_aspect.",
    fields = {
        "names": "Depset containing names of all PyPI package dependencies",
    }
)

def _pypi_info_aspect_impl(_target, ctx):
    names = _collect_pip_names_from_metadata_files(ctx.rule.attr.deps)
    return PypiAspectInfo(names = depset(direct = names))

pypi_info_aspect = aspect(
    implementation = _pypi_info_aspect_impl,
    attr_aspects = ['deps'],
)

def _pips_from_metadata_files_aspect_impl(ctx):
    names = depset(transitive = [
        dep[PypiAspectInfo].names for dep in ctx.attr.deps
    ]).to_list()
    ctx.actions.write(ctx.outputs.aspect_list, "\n".join(sorted(names)) + "\n")

pips_from_metadata_files_aspect = rule(
    implementation = _pips_from_metadata_files_aspect_impl,
    attrs = {
        "deps": attr.label_list(aspects = [pypi_info_aspect]),
        "aspect_list": attr.output(),
    }
)
