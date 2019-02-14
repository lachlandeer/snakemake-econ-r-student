## Snakemake - MRW Replication
##
## @yourname
##

from pathlib import Path

# --- Importing Configuration Files --- #

configfile: "config.yaml"

# Universal OS compatability
def str_from_path(file_path):
    return str(file_path)

def glob_wildcards_path(file_path):
    path_as_str = str_from_path(file_path)
    return glob_wildcards(path_as_str)

# --- Dictionaries --- #
# Identify subset conditions for data
DATA_SUBSET = glob_wildcards_path(Path(config["src_data_specs"]) /
                                    "{fname}.json").fname
DATA_SUBSET = list(filter(lambda x: x.startswith("subset"), DATA_SUBSET))
print(DATA_SUBSET)
# Models we want to estimate
MODELS = glob_wildcards_path(Path(config["src_model_specs"]) /
                                "{fname}.json").fname

FIGURES = glob_wildcards_path(Path(config["src_figures"]) /
                                "{fname}.R").fname
TABLES  = [
            "tab01_textbook_solow",
            "tab02_augment_solow"
]

# --- Sub Workflows --- #
# subworkflow tables:
#    workdir: str_from_pathPath(config["ROOT"]))
#    snakefile:  str_from_path(Path(config["src_tables"]) / "Snakefile")

subworkflow analysis:
   workdir: str_from_path(Path(config["ROOT"]))
   snakefile:  str_from_path(Path(config["src_analysis"]) / "Snakefile")

# subworkflow figs:
#    workdir: str_from_path(Path(config["ROOT"]))
#    snakefile:  str_from_path(Path(config["src_figures"]) / "Snakefile")

# --- Build Rules --- #

## all                : builds all final outputs
rule all:
    input:
        # figs   = figs(expand(config["out_figures"] +
        #                     "{iFigure}.pdf",
        #                     iFigure = FIGURES)
        #                     ),
        models = analysis(expand(str_from_path(Path(config["out_analysis"]) /
                            "{iModel}_ols_{iSubset}.rds"),
                            iModel = MODELS,
                            iSubset = DATA_SUBSET)
                            ),
        # tables  = tables(expand(config["out_tables"] +
        #                     "{iTable}.tex",
        #                     iTable = TABLES)
        #                     )

# --- Clean Rules --- #
## clean              : removes all content from out/ directory
rule clean:
    shell:
        "rm -rf out/*"

# --- Help Rules --- #
## help               : prints help comments for Snakefile
rule help:
    input:
        main     = "Snakefile",
        tables   = config["src_tables"] + "Snakefile",
        analysis = config["src_analysis"] + "Snakefile",
        data_mgt = config["src_data_mgt"] + "Snakefile",
        figs     = config["src_figures"] + "Snakefile"
    output: "HELP.txt"
    shell:
        "find . -type f -name 'Snakefile' | tac | xargs sed -n 's/^##//p' \
            > {output}"
