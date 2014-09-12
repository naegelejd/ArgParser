# ArgParser

A simple command-line argument parser for Io.

See `demo.io` for an example.

## API

### Parser

`setDescription (desc)`

>   Set the description of the program containing the `ArgParser`.

>   Example:

>       parser setDescription("a simple command-line tool")

`printUsage`

>   Print the command line usage. The usage is an abbreviated form of the help doc.

>   Example:

>       parser printUsage

`parseArgs`

>   Parse arguments supplied on the command line.
>   Returns a `Map` of options/names to their values.

>   Example:

>       args := parser parseArgs

`setOptionPrefix (shortPrefix, longPrefix)`

>   Change the prefix char for options.
>   The default short and long prefixes are "-" and "--", respectively.

>   Example:

>       parser setOptionPrefix("/", "/")

### Options

The format supplied to each `addOption` method should be one of the following:

- a *short* option string
- a *long* option string
- both a *short* and *long* option string

`addBoolOption (format, help string)`

>   Add a boolean option. All boolean options default to `false`.

>   Examples:

>       parser addBoolOption ("v", "verbose")
>       parser addBoolOption ("r", "reverse", "reverse mode")
>       parser addBoolOption ("standalone", "standalone mode")

`addNumericOption (format, help string)`

>   Add a numeric option. All numeric options default to `0`.

>   Examples:

>       parser addNumericOption ("c", "count")
>       parser addNumericOption ("r", "repetitions", "number of repetitions")
>       parser addNumericOption ("size", "size in inches")

`addOption (format, help string)`

>   Add a numeric option. All numeric options default to `0`.

>   Examples:

>       parser addOption ("i", "input filename")
>       parser addOption ("o", "output", "output filename")
>       parser addOption ("url", "base URL")

### Arguments

Positional arguments are mandatory parameters to the program.
They can only appear after all other options.


`addArgument (name, help string)`

>   Add a positional argument.

>   Example:

>       parser addArgument ("input", "input filename")

