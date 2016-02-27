# NAS related stuff

It 'd be nice if can keep an updated summary of all scripts within this folder;
they all (should) run remotely via cron, so we are doomed to forget what they
actually do sooner or later.

* `compile_year_report.sh`

This is a `bash` script meant to be run on the (either of the two) NAS server. It
basicaly scans through a yearly directory tree and makes a quick summary of the (RINEX) files
archive therein.

* `yday_to_mday.awk`

This is an `awk` script to assist (i.e. called by) `compile_year_report.sh`. Given a year and a day 
of year (i.e. doy), this script will transform the given date to YYYY-MM-DD format.

* `sync_nas.sh`

A script to synchronize selected folders between `raskolnikov` and `babylon`. Uses `rsync` and
`(open)ssh`.

* `rep2json.py`

This is a python program to transform a report output from `compile_year_report.sh` (or actually multiple
such reports) and transform them to `json` format. This script consults a database for further station
info.

* `data_map.js`

Someday ... this script will automate the web presentation of the NAS RINEX archives. You first run
`compile_year_report.sh`, filter through `rep2json.py` and finaly call `data_map.js`
