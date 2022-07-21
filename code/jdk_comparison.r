#!/usr/bin/env Rscript

library ('boot')
library ('digest')
library ('logger')
library ('zeallot')
library ('jsonlite')
library ('parallel')
library ('tidyverse')
library ('assertthat')
library ('changepoint')

options (boot.parallel = 'multicore')
options (boot.ncpus = detectCores ())

DATA_PATH <- '.'
DATA_FILE <- file.path (DATA_PATH, 'data.Rds')
NAME_VM_FILE <- file.path (DATA_PATH, 'name_vm.csv')
NAME_METRICS_FILE <- file.path (DATA_PATH, 'name_metrics.csv')

PLOT_ROWS <- 4
PLOT_WIDTH <- 300
PLOT_HEIGHT <- 300

REPLICATES <- 33333
CONFIDENCE <- 0.99

OUTLIER_LIMIT <- 0.05
OUTLIER_SLACK <- 0.1

# The size of the window is in samples.
OUTLIER_WINDOW <- 333

METRICS <- tribble (~name, ~label, ~unit, ~suffix,
    'time', 'time', 's', 'time',
    'ubench_agent_PAPI_ref_cycles', 'clock cycles', '1', 'cycles',
    'ubench_agent_PAPI_instructions', 'instructions', 'ins', 'instructions',
    'ubench_agent_PAPI_branch_instructions', 'branch instructions', 'ins', 'branch-refs',
    'ubench_agent_PAPI_branch_misses', 'branch misses', 'miss', 'branch-miss',
    'ubench_agent_PAPI_cache_references', 'cache references', 'ref', 'cache-refs',
    'ubench_agent_PAPI_cache_misses', 'cache misses', 'miss', 'cache-miss',
)

# Load modules.

MODULES <- c (
    'util.r',
    'load_util.r', 'load_csv.r', 'load_json.r',
    'comp_util.r', 'comp_warmup.r', 'comp_mean_with_ci.r', 'comp_ratio_with_ci.r',
    'plot_util.r', 'plot_simple_samples.r', 'plot_simple_mean.r', 'plot_jdk_comparison.r'
)

library ('scriptName')
HOME_PATH <- dirname (current_filename ())
for (module in MODULES) source (file.path (HOME_PATH, module))


# Load data.

if (file.exists (DATA_FILE)) {
    data_both <- readRDS (DATA_FILE)
} else {
    data_both <- load_data_json (DATA_PATH)
    saveRDS (data_both, DATA_FILE)
}

# Add VM and JDK information.
data_both <- data_both %>% add_vm_jdk_from_name_version_configuration (NAME_VM_FILE)

# Keep warm data separately.
data_warm <- data_both %>% comp_warm () %>% filter (warm) %>% select (-warm)

first_jdk <- data_both %>%
  select(jdk) %>%
  distinct(jdk) %>%
  pull(jdk) %>%
  sort() %>%
  first()
baseline <- sprintf ('OpenJDK %d', first_jdk)
print(sprintf('Using %s as baseline', baseline))
data_warm_openjdk <- data_warm %>% filter (startsWith(as.character(vm), 'OpenJDK'))
data_ratio_with_ci <- data_warm_openjdk %>% group_by (vm, benchmark) %>% comp_ratio_with_ci (baseline, 'time') %>% ungroup ()
plot_jdk_comparison (data_ratio_with_ci, sprintf ('jdk-comparison.png'))
write_csv (data_ratio_with_ci, 'jdk-comparison.csv')
