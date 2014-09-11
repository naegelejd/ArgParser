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
#
# flag
# optparse, argparse
# program_options
# argparser
# OptionParser

ArgParser := Object clone
ArgParser do (

    Argument := Object clone
    Argument do (
        short := nil
        long := nil
        name := nil
        isbool := false
        help := nil

        isPositional := method(name != nil)

        asString := method(
            rep := ""
            if (name) then (
                rep = "<#{name}>"
            ) elseif (short) then (
                if (long, rep = "#{short}, #{long}", rep = "#{short} ")
            ) else (
                rep = "#{long}"
            )
            return rep interpolate
            // return rep asMutable appendSeq("\t\t- #{help}") interpolate
        )
    )

    ArgBool := Object clone
    ArgOpt := Object clone
    ArgPos := Object clone

    init := method (
        self desc := ""
        f := File clone setPath(System args at(0))
        self prog := f baseName
        self argv := System args slice(1) clone
        self arguments := list() clone
        self positionals := list() clone
        self lookup := Map() clone
    )

    setDescription := method(desc, self desc = desc clone)

    addArgument := method (arg0, arg1,
        count := call argCount

        newarg := Argument clone
        newarg help := call evalArgAt(-1)

        if (arg0 beginsWithSeq("--")) then (
            newarg long := arg0
            if (count > 2, newarg isbool := arg1)
        ) elseif (arg0 beginsWithSeq("-")) then (
            newarg short := arg0
            if (count > 3) then (
                newarg long := arg1
                newarg isbool := call evalArgAt(2)
            ) elseif (count > 2) then (
                // just convert arg1 to string... it's possibly true/false
                if (arg1 asString beginsWithSeq("--"), newarg long := arg1, newarg isbool := arg1)
            ) else (
                newarg isbool := arg1
            )
        ) else (
            newarg name := arg0
            if (count > 2, newarg isbool := call evalArgAt(1))
        )

        if (newarg isPositional,
            positionals append(newarg),
        // else
            arguments append(newarg)
            if (newarg short, lookup atPut(newarg short, newarg))
            if (newarg long, lookup atPut(newarg long, newarg))
        )
    )

    printUsage := method (
        "usage: #{prog} " interpolate print
        positionals foreach (p, "#{p} " interpolate print)
        "" println
        "  #{desc}" interpolate println
        "" println
        arguments foreach(arg, "\t#{arg}\t\t#{arg help}" interpolate println)
    )

    printError := method (msg, "Error: #{msg}" interpolate println)

    parseArgs := method (
        values := Map clone
        "parsing..." println
        atArgsEnd := false
        posCount := 0
        argi := 0
        while (argi < argv size,
            argstring := argv at(argi)

            if (lookup hasKey(argstring)) then (
                if (atArgsEnd,
                    Exception clone raise("Options must come before positionals")
                    break
                )
                arg := lookup at(argstring)
                if (arg isbool,
                    values atPut(argstring, true),
                // else
                    argi = argi + 1
                    v := argv at(argi)
                    values atPut(argstring, v)
                )
            ) else (
                if (posCount >= positionals size,
                    Exception clone raise ("Extra argument #{argstring}" interpolate)
                    break
                )
                atArgsEnd = true
                name := positionals at(posCount) name
                "parsed #{name}: #{argstring}" interpolate println
                values atPut(name, argstring)
                posCount = posCount + 1
            )
            argi = argi + 1
        )
        return values
    )
)
