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
D=${RUNNER_TEMP}/adoc.$$
rm -rf $D
mkdir -p $D

echo Building single-page HTML version of AsciiDoc
asciidoctor -r asciidoctor-diagram -o $D/index.html --verbose test.adoc || true

echo Building PDF from AsciiDoc
asciidoctor-pdf -r asciidoctor-diagram -o $D/book.pdf --verbose test.adoc || true

echo Building multi-page HTML from AsciiDoc
asciidoctor-multipage -r asciidoctor-diagram -D $D -o $D/paged.html --verbose test.adoc || true

echo Putting output into $INPUT_OUTPUT
tar --dereference -C $D -cvf $INPUT_OUTPUT --exclude .asciidoctor .
ls -al $RUNNER_TEMP
ls -l $INPUT_OUTPUT

# Names of chapter html files start with underscores, which Jekyll does not preserve,
# so the repo needs a .nojekyll in the root.

