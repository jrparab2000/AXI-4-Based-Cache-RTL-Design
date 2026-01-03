TOP_LEVEL ?= cache_top
LINT = $(PROJ_HOME)/lint
FILELIST = $(LINT)/filelist/filelist.f
REPORT_DIR = $(LINT)/reports

lint_cache:
	$(LINT)/scripts/verilator_lint.sh $(TOP_LEVEL) $(FILELIST) $(REPORT_DIR) $(RTL_DIR)
