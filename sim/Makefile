export PROJ_HOME ?= $(PWD)/..

include $(PROJ_HOME)/lint/Makefile

lint_all: lint_cache

debug: 
	qrun -64 \
	-sv \
	-gui \
	-onfinish stop \
	-classdebug \
	-msgmode both \
	-l logs.log \
	-f filelist.f \
	-do wave.do \
	-top testbench_cache_core

clean:
	rm -rf work
	rm -rf certe_dump.xml
	rm -rf design.bin
	rm -rf qrun.out
	rm -rf .visualizer
	rm -rf qwave.db
	rm -rf logs/*.log
	rm -rf *.log
	rm -rf *.ucdb
	rm -rf transcript
	rm -rf *.wlf
	rm -rf ucdb/*.txt