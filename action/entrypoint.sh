#! /bin/sh -l

# Bail on error.
set -e

# Arguments:
# $1 == $INPUT_OUTPUT :  filename for tarball artifact

[[ x"$INPUT_OUTPUT" != x ]]

sed -i \
    -e 's@\[source,mermaid\]@[mermaid]@' \
    -e "s@%%GITHUB_RUN_NUMBER%%@$GITHUB_RUN_NUMBER@" \
    -e "s@%%GITHUB_SHA%%@$GITHUB_SHA@" \
    -e "s@%%DATE%%@$(date)@" \
    test.adoc

# $$ is probably "1"
T=${RUNNER_TEMP}/adoc.$$.tar

echo Building single-page HTML version of AsciiDoc
asciidoctor -r asciidoctor-diagram -o index.html --verbose test.adoc || true

echo Building multi-page HTML from AsciiDoc
asciidoctor-multipage -r asciidoctor-diagram -D multipage -o multipage/index.html --verbose test.adoc || true

echo Putting output into $INPUT_OUTPUT
tar --dereference -cvf $T --exclude .asciidoctor .
ls -alr $RUNNER_TEMP
mv $T $INPUT_OUTPUT

echo Artifact: $INPUT_OUTPUT
ls -l $INPUT_OUTPUT

