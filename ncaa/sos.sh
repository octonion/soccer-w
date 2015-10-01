#!/bin/bash

psql soccer-w -c "drop table if exists ncaa.results;"

psql soccer-w -f sos/standardized_results.sql

psql soccer-w -c "vacuum full verbose analyze ncaa.results;"

psql soccer-w -c "drop table if exists ncaa._basic_factors;"
psql soccer-w -c "drop table if exists ncaa._parameter_levels;"

R --vanilla -f sos/lmer.R

psql soccer-w -c "vacuum full verbose analyze ncaa._parameter_levels;"
psql soccer-w -c "vacuum full verbose analyze ncaa._basic_factors;"

psql soccer-w -f sos/normalize_factors.sql
psql soccer-w -c "vacuum full verbose analyze ncaa._factors;"

psql soccer-w -f sos/schedule_factors.sql
psql soccer-w -c "vacuum full verbose analyze ncaa._schedule_factors;"

psql soccer-w -f sos/current_ranking.sql > sos/current_ranking.txt
cp /tmp/current_ranking.csv sos/current_ranking.csv

psql soccer-w -f sos/division_ranking.sql > sos/division_ranking.txt

psql soccer-w -f sos/connectivity.sql > sos/connectivity.txt

psql soccer-w -f sos/test_predictions.sql > sos/test_predictions.txt

psql soccer-w -f sos/predict_daily.sql > sos/predict_daily.txt
cp /tmp/predict_daily.csv sos/predict_daily.csv

psql soccer-w -f sos/predict_weekly.sql > sos/predict_weekly.txt
cp /tmp/predict_weekly.csv sos/predict_weekly.csv

psql soccer-w -f sos/predict.sql > sos/predict.txt
cp /tmp/predict.csv sos/predict.csv
