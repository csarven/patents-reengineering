#!/bin/bash
. ./patents.config.sh

for i in "$cpcscheme"*.xml ; do file=$(basename "$i"); fn=${file%.*}; saxonb-xslt -ext:on -t -tree:linked -s "$i" -xsl "$xslCPC" xmlDocument="$i" > "$cpcscheme""$fn".rdf ; done
