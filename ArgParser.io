#!/usr/bin/env io

# Grammar:
# cmdline = { opt } { arg }
# arg = [\w_]+
# opt = short | long
# short = '-' \w [ \w+ ]
# long = '-' '-' \w+ [ \w+ ]
#
#   -v              1 param
#   -v --verbose    2 param
#   --verbose       1 param
#   name            1 param

# last := call evalArgAt(-1)
# count := call argCount
#
# --long, help                  2
# --long, isbool, help          3
# -short, help                  2
# -short, isbool, help          3
# -short, --long, help          3
# -short, --long, isbool, help  4
# name, help                    2

ArgParser := Object clone
ArgParser do (

    desc := ""
    shortPrefix := "-"
    longPrefix := "--"

    options := list()
    arguments := list()
    lookup := Map()

    init := method (
        f := File clone setPath(System args at(0))
        self prog := f baseName
        self argv := System args slice(1) clone
    )

    Argument := Object clone
    Argument init := method (
        self name := nil
        self help := nil
    )
    Argument asString := method (
        "<#{name}>" interpolate
    )

    Option := Object clone
    Option init := method (
        self short := nil
        self long := nil
        self help := nil
    )

    BoolOption := Option clone
    NumericOption := Option clone

    debug := method (msg,
        msg println
    )

    setDescription := method (desc, self desc = desc)
    setOptionPrefix := method (sP, lP, self shortPrefix = sP; self longPrefix = lP)

    makeOpt := method (opt, args,
        count := args size
        if (count < 2,
            Exception clone raise ("Error: Must specify at least a short or long name and help message")
        )

        opt help = args at(-1)
        arg0 := args at(0)
        if (count < 3,
            if (arg0 size > 1, opt long = arg0, opt short = arg0),
        // else
            opt short = arg0
            opt long = args at(1)
        )

        return opt
    )

    addOption := method (x, help,
        opt := Option clone
        args := call evalArgs
        opt = makeOpt(opt, args)
        debug("Added option: #{opt short} #{opt long} #{opt help}" interpolate)
        self options append(opt)
    )

    addBoolOption := method (x, help,
        opt := BoolOption clone
        args := call evalArgs
        opt = makeOpt(opt, args)
        debug("Added bool option: #{opt short} #{opt long} #{opt help}" interpolate)
        self options append(opt)
    )

    addNumericOption := method (x, help,
        opt := NumericOption clone
        args := call evalArgs
        opt = makeOpt(opt, args)
        debug("Added numeric option: #{opt short} #{opt long} #{opt help}" interpolate)
        self options append(opt)
    )

    addArgument := method (name, help,
        arg := Argument clone
        arg name = name
        arg help = help
        debug("Added positional argument: #{name} #{help}" interpolate)
        self arguments append(arg)
    )

    printUsage := method (
        "usage: #{prog} " interpolate print
        arguments foreach (p, "#{p} " interpolate print)
        "" println
        "  #{desc}" interpolate println
        "" println
        options foreach(opt,
            s := if (opt short,
                if (opt long,
                    "#{shortPrefix}#{opt short}, " interpolate,
                    "#{shortPrefix}#{opt short}" interpolate),
                // else
                    "")
            l := if (opt long, "#{longPrefix}#{opt long}" interpolate, "")
            "\t#{s}#{l}\t\t#{opt help}" interpolate println
        )
    )

    printError := method (msg, "Error: #{msg}" interpolate println)

    parseArgs := method (
        values := Map clone
        parsingPositionals := false
        posCount := 0
        argi := 0
        while (argi < argv size,
            argstring := argv at(argi)
            argi = argi + 1
        )
        return values
    )
)
