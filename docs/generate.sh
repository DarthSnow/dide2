OUTPUT_DIR="../public/"
MD_FILES=$(find *.md*);

if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir $OUTPUT_DIR
fi

for MD_FILE in $MD_FILES; do
    OFILE=$OUTPUT_DIR$"${MD_FILE%.*}".html
    pandoc -o$OFILE $MD_FILE --css=style.css --standalone --toc
done

cp -r img $OUTPUT_DIR/img/
cp -r ../icons $OUTPUT_DIR/icons/
cp -r style.css $OUTPUT_DIR/style.css
