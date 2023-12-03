#! /bin/sh -l

# Bail on error.
set -e
# Hush ownership complaints
git config --global --add safe.directory /github/workspace

env

echo Fetch:
git fetch --all

echo Deleting gh-pages branch
git branch --quiet -D gh-pages 2>/dev/null || true
echo Starting new gh-pages branch
git checkout --orphan gh-pages "${GITHUB_SHA}"
# git checkout "${GITHUB_SHA}" -B gh-pages

T=test.adoc.$$

sed 's@\[source,mermaid\]@[mermaid]@' < test.adoc > $T

echo Plain
asciidoctor -o index.html --verbose $T || true

echo Diagram
asciidoctor -r asciidoctor-diagram -o index2.html --verbose $T || true

echo Book
asciidoctor-pdf -r asciidoctor-diagram -o book.pdf --verbose $T || true

ls -alR

rm -f $T ||:

# Git insists on these
git config --global user.email "action@github.com"
git config --global user.name "GitHub Action"

echo "Adding *.html assets book.pdf to gh-pages branch"
git add -f *.html assets book.pdf
git rm -rf .github action || true
git status
git commit -m "Asciidoctored $GITHUB_SHA"

echo Pushing
git push -f --set-upstream origin gh-pages
