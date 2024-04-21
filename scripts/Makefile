.POSIX:
.SUFFIXES:

all: transform analyse report

transform: transform-data.sh
	./transform-data.sh

analyse: data-analysis.py
	./data-analysis.py

report: generate_report.sh
	./generate_report.sh

.PHONY: all
