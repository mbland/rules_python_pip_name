#!/usr/bin/env bash

jquery=(
    '.rule.attribute[] |'
    'select(.name=="tags") |'
    '.stringListValue[] |'
    'match("pypi_name=(.*)") |'
    '.captures[0].string'
)
bazel query 'attr("tags", "pypi_name=.*", deps(//...))' \
    --output=streamed_jsonproto | jq "${jquery[*]}"
