module extract_last_changelog_part;

void main()
{
    import std.regex    : matchFirst;
    import std.file     : readText;
    import std.stdio    : write;
    import std.string   : strip;

    readText("../CHANGELOG.md")
        .matchFirst(`##[\s\S]*?(?=# v)`)
        .front
        .strip
        .write;
}
