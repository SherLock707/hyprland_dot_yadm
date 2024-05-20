# Aspell plugin

The text will be checked for misspells as you type. It understands the syntax
of XML, HTML, TeX and Markdown. On C++, C and Perl only comments and string
literals will be checked.

You need to have Aspell installed and available in your PATH. It does not come
with this plugin. If you are on Windows, you can install Aspell through
[MSYS2](https://www.msys2.org/).

## Options

* `aspell.check`: controls whether spellchecking is performed. Possible values
   are `on`, `off` and `auto`. When set to `auto`, the file will be checked
   only if it's one of these filetypes: XML, C++, C, HTML, Perl, TeX,
   Markdown, Groff/Troff, Manpage, Email or Git commit. Defaults to `auto`.

* `aspell.lang`: language to use. Two letter language code, optionally followed
   by an underscore or a dash and a two letter country code. It will be passed
   to Aspell in the `--lang` option.

* `aspell.dict`: dictionary to use. Run `aspell dicts` in a terminal to see
   available dictionaries. It will be passed to Aspell in the `--master` option.

If both `aspell.dict` and `aspell.lang` are left empty (which is the default),
Aspell will follow locale settings.

* `aspell.sugmode`: one of `ultra`, `fast`, `normal`, `slow` or `bad-spellers`.
   It will be passed to Aspell in the `--sug-mode` option. Defaults to `normal`.
   You may wish to change it to `fast`, if you feel that the spellchecking is
   too slow. For an explanation of what each option does, see
   http://aspell.net/man-html/Notes-on-the-Different-Suggestion-Modes.html

* `aspell.args`: additional command line arguments, that will be passed to
   Aspell.

When you change some of these settings while in Micro using `setlocal` or
`set`, you might not see the effect until you modify a buffer.

You can also disable or enable spellchecking for specific file types in your
`settings.json`:

```json
{
    "*.txt": {
        "aspell.check": "on"
    },
    "ft:markdown": {
        "aspell.check": "off"
    }
}
```

## Commands

* `togglecheck`: turns the spellchecking on/off. You can bind it to a key as
   `lua:aspell.addpersonal`. The effect's the same as changing `aspell.check`
   using `setlocal`.

* `addpersonal`: adds the word the cursor is on to your personal dictionary, so
   that it won't be highlighted as a misspell anymore. You can bind it to a key
   as `lua:aspell.addpersonal`.

* `acceptsug 'n'?`: accepts the nth suggestion for the word the cursor is on.
   You can bind it to a key as `lua:aspell.acceptsug`. If `n` is not provided or
   this command is invoked with a keyboard shortcut, it will start to cycle
   through the suggestions. Use `Tab` and `Backtab` to cycle through them.

You can also use them in chain keybindings with `,`, `&` and `|` (see
`help keybindings`). Example `bindings.json`:

```json
{
    "Tab": "Autocomplete|lua:aspell.acceptsug|IndentSelection|InsertTab"
}
```
