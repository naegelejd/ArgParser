#!/usr/bin/env io

ArgParser := Object clone
ArgParser do (

    desc := ""
    shortPrefix := "-"
    longPrefix := "--"

    options := list()
    positionals := list()
    lookup := Map clone

    init := method (
        arg0 := System args at(0)
        f := File clone
        // this allows the parser to work in the interpreter
        if (arg0, f setPath(System args at(0)))
        self prog := f baseName
        // pre-process args to split '--long=xxx' into two args
        self argv := list()
        System args exSlice(1) foreach(a,
            if (a containsSeq("=")) then (
                idx := a findSeq("=")
                self argv append(a exSlice(0, idx))
                self argv append(a exSlice(idx+1))
            ) else (
                self argv append(a)
            )
        )
    )

    Argument := Object clone
    Argument init := method (
        self name := nil
        self help := nil
    )

    Option := Argument clone
    Option init := method (
        self short := nil
        self long := nil
        self help := nil
    )

    BoolOption := Option clone
    NumericOption := Option clone
    StringOption := Option clone

    /* debug := method (msg, "DEBUG: #{msg}" interpolate println) */
    debug := method ()

    setDescription := method (desc, self desc = desc)
    setOptionPrefix := method (sP, lP, self shortPrefix = sP; self longPrefix = lP)

    _addopt := method (opt, args,
        count := args size
        if (count < 2,
            Exception clone raise ("Error: Must specify at least a short or long name and help message")
        )

        opt help = args at(-1)
        arg0 := args at(0)
        if (count < 3,
            if (arg0 size > 1,
                opt long = arg0
                opt name = opt long,
            // else
                opt short = arg0
                opt name = opt short),
        // else
            opt short = arg0
            opt long = args at(1)
            opt name = opt long
            self lookup atPut(opt short, opt)
        )

        self lookup atPut(opt name, opt)
        self options append(opt)

        return opt
    )

    addOption := method (x, help,
        opt := _addopt(StringOption clone, call evalArgs)
        debug("Added option: #{opt short} #{opt long} #{opt help}" interpolate)
    )

    addBoolOption := method (x, help,
        opt := _addopt(BoolOption clone, call evalArgs)
        debug("Added bool option: #{opt short} #{opt long} #{opt help}" interpolate)
    )

    addNumericOption := method (x, help,
        opt := _addopt(NumericOption clone, call evalArgs)
        debug("Added numeric option: #{opt short} #{opt long} #{opt help}" interpolate)
    )

    addArgument := method (name, help,
        arg := Argument clone
        arg name = name
        arg help = help
        debug("Added positional argument: #{name} #{help}" interpolate)
        self positionals append(arg)
    )

    printUsage := method (
        "usage: #{prog} " interpolate print
        positionals foreach (p, "#{p name} " interpolate print)
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
        positionalCount := 0
        argi := 0
        while (argi < argv size,
            cur := argv at(argi)
            if (cur beginsWithSeq(shortPrefix) or cur beginsWithSeq(longPrefix)) then (
                debug("parsing option #{cur}" interpolate)
                prefix := if (cur beginsWithSeq(shortPrefix), shortPrefix, longPrefix)
                if (parsingPositionals,
                    Exception clone raise ("Error: Found option after positional argument" interpolate)
                )
                stripped := cur asMutable lstrip(prefix)
                if (lookup hasKey(stripped)) then (
                    opt := lookup at(stripped)
                    if (opt isKindOf(BoolOption)) then (
                        values atPut(opt name, true)
                    ) else (
                        argi = argi + 1
                        cur = argv at(argi)
                        if (opt isKindOf(NumericOption)) then (
                            values atPut(opt name, cur asNumber)
                        ) else (
                            values atPut(opt name, cur)
                        )
                    )
                ) else (
                    Exception clone raise ("Error: Invalid option '#{cur}'" interpolate)
                )
            ) else (
                debug("parsing positional argument #{cur}" interpolate)
                parsingPositionals = true
                arg := positionals at(positionalCount)
                values atPut(arg name, cur)
                positionalCount = positionalCount + 1
            )
            argi = argi + 1
        )

        if (positionalCount != positionals size,
            Exception clone raise ("Error: Missing positional arguments")
        )

        return values
    )
)
