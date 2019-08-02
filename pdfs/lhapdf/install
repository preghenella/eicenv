#! /usr/bin/env bash

for PDF in $@; do
    echo "--- Installing PDF: $PDF ---"
    curl -k -L -O http://www.hepforge.org/archive/lhapdf/pdfsets/6.2/$PDF.tar.gz && \
	tar zxvf $PDF.tar.gz -C $LHAPDF_ROOT/share/LHAPDF && \
	rm $PDF.tar.gz
done
