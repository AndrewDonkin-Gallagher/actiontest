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

sed -i \
    -e 's@\[source,mermaid\]@[mermaid]@' \
    -e "s@%%GITHUB_RUN_NUMBER%%@$GITHUB_RUN_NUMBER@" \
    -e "s@%%GITHUB_SHA%%@$GITHUB_SHA@" \
    -e "s@%%GITHUB_TRIGGERING_ACTOR%%@$GITHUB_TRIGGERING_ACTOR@" \
    -e "s@%%DATE%%@${date}@" \
    test.adoc

echo Plain
asciidoctor -o index.html --verbose test.adoc || true

echo Diagram
asciidoctor -r asciidoctor-diagram -o index2.html --verbose test.adoc || true

echo Book
asciidoctor-pdf -r asciidoctor-diagram -o book.pdf --verbose test.adoc || true

# Git insists on these
git config --global user.email "action@github.com"
git config --global user.name "GitHub Action"

echo "Adding *.html assets book.pdf to gh-pages branch"
git add -f *.html assets book.pdf
git rm -rf .gitignore .github action || true
git status
git commit -m "Asciidoctored $GITHUB_SHA"

echo Pushing
git push -f --set-upstream origin gh-pages
