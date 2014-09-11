/* doFile("argparse.io") */

parser := ArgParser clone
parser setDescription("sample argument parser")

parser addArgument("-v", true, "enable verbose mode")
parser addArgument("--reverse", true, "reverse mode")
parser addArgument("-h", "--help", true, "print usage")
parser addArgument("-o", "--output", "output filename")
parser addArgument("name", "input filename")

parser printUsage

values := parser parseArgs
values foreach(name, val, "#{name}: #{val}" interpolate println)
