#!/bin/bash

cmd="psql template1 --tuples-only --command \"select count(*) from pg_database where datname = 'soccer-w';\""

db_exists=`eval $cmd`
 
if [ $db_exists -eq 0 ] ; then
   cmd="createdb soccer-w;"
   eval $cmd
fi

psql soccer-w -f schema/create_schema.sql

tail -q -n+2 csv/ncaa_games_*.csv > /tmp/ncaa_games.csv
rpl ",-," ",," /tmp/ncaa_games.csv
psql soccer-w -f loaders/load_games.sql
rm /tmp/ncaa_games.csv

cat csv/ncaa_players_*.csv >> /tmp/ncaa_statistics.csv
rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ".," "," /tmp/ncaa_statistics.csv

rpl ".0," "," /tmp/ncaa_statistics.csv
rpl -e ".0\n" "\n" /tmp/ncaa_statistics.csv

rpl ".00," "," /tmp/ncaa_statistics.csv
rpl -e ".00\n" "\n" /tmp/ncaa_statistics.csv

rpl ".000," "," /tmp/ncaa_statistics.csv
rpl -e ".000\n" "\n" /tmp/ncaa_statistics.csv

rpl -e ",-\n" ",\n" /tmp/ncaa_statistics.csv
psql soccer-w -f loaders/load_statistics.sql
rm /tmp/ncaa_statistics.csv

psql soccer-w -f schema/create_players.sql

cp csv/ncaa_schools.csv /tmp/ncaa_schools.csv
psql soccer-w -f loaders/load_schools.sql
rm /tmp/ncaa_schools.csv

cp csv/ncaa_divisions.csv /tmp/ncaa_divisions.csv
psql soccer-w -f loaders/load_divisions.sql
rm /tmp/ncaa_divisions.csv

cp csv/ncaa_colors.csv /tmp/ncaa_colors.csv
psql soccer-w -f loaders/load_colors.sql
rm /tmp/ncaa_colors.csv
