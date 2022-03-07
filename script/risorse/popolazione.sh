#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

<"$folder"/../../dati/risorse/rawdata/province-popolazione.csv tail -n +2 | head -n -1 | mlr --csv cut -f "Codice provincia",Età,"Totale Maschi","Totale Femmine" then filter '${Età}=="Totale"' then put '${Totale Popolazione}=${Totale Maschi}+${Totale Femmine}' then rename "Codice provincia","Codice Provincia" then cut -x -f "Età" >"$folder"/../../dati/risorse/province-popolazione.csv
