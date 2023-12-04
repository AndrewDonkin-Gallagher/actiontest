#! /bin/sh -l

# Bail on error.
set -e

sed -i \
    -e 's@\[source,mermaid\]@[mermaid]@' \
    -e "s@%%GITHUB_RUN_NUMBER%%@$GITHUB_RUN_NUMBER@" \
    -e "s@%%GITHUB_SHA%%@$GITHUB_SHA@" \
    -e "s@%%DATE%%@$(date)@" \
    test.adoc

echo Building single-page HTML version of AsciiDoc
asciidoctor -r asciidoctor-diagram -o index.html --verbose test.adoc || true

echo Building multi-page HTML from AsciiDoc
asciidoctor-multipage -r asciidoctor-diagram -D multipage -o multipage/index.html --verbose test.adoc || true

