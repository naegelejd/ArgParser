parser := ArgParser clone
parser setDescription("sample argument parser")

# parser setOptionPrefix("/", "/")
parser addBoolOption("v", "enable verbose mode")
parser addBoolOption("reverse", "reverse mode")
parser addBoolOption("h", "help", "print usage")
parser addOption("o", "output", "output filename")
parser addNumericOption("c", "repetition count")
parser addArgument("filename", "input filename")

parser printUsage

args := parser parseArgs
args foreach(name, val, "#{name}: #{val}" interpolate println)
