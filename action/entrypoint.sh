#! /bin/sh -l

# Bail on error.
set -e
# Hush ownership complaints
#git config --global --add safe.directory /github/workspace

#echo Fetch:
#git fetch --all

#echo Deleting gh-pages branch
#git branch --quiet -D gh-pages 2>/dev/null || true
#echo Starting new gh-pages branch
#git checkout --orphan gh-pages "${GITHUB_SHA}"

echo Args
echo $*

echo Env
env

[[ x"$OUTPUT" != x ]]

sed -i \
    -e 's@\[source,mermaid\]@[mermaid]@' \
    -e "s@%%GITHUB_RUN_NUMBER%%@$GITHUB_RUN_NUMBER@" \
    -e "s@%%GITHUB_SHA%%@$GITHUB_SHA@" \
    -e "s@%%DATE%%@$(date)@" \
    test.adoc

D=temp.$$
rm -rf $D
mkdir -p $D

echo Diagram
asciidoctor -r asciidoctor-diagram -o $D/index.html --verbose test.adoc || true

echo Book
asciidoctor-pdf -r asciidoctor-diagram -o $D/book.pdf --verbose test.adoc || true

echo Multipage
asciidoctor-multipage -r asciidoctor-diagram -D $D/paged --verbose test.adoc || true

tar --dereference --hard-dereference -C $D -cvf $OUTPUT .

# Names of chapter html files start with underscores, which Jekyll does not preserve,
# so the repo needs a .nojekyll in the root.

# Git insists on these
#git config --global user.email "action@github.com"
#git config --global user.name "GitHub Action"

#echo "Adding *.html assets book.pdf to gh-pages branch"
#git add -f *.html assets book.pdf paged
#git rm -rf .gitignore .github action || true
#git status
#git commit -m "Asciidoctored $GITHUB_SHA"

#echo Pushing
#git push -f --set-upstream origin gh-pages
