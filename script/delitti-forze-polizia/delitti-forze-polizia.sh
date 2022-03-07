#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/rawdata
mkdir -p "$folder"/processing

### estrazione codifica categorie delitti ###

# categorie da FILE XLS 2020
in2csv -I --sheet ITALIA "$folder"/../../dati/delitti-forze-polizia/rawdata/2020/DELITTIITA-REG-PROV2020.xls |
  # rimuovi le prime due righe
  tail -n +3 |
  # rimuovi la riga con i totali
  grep -vP 'TOTALE DELITTI,' >"$folder"/processing/tmp-01.csv

# estrai i codici delle categorie delitti da schema XLS, senza cambiare l'ordine
mlr -I --csv cat -n then cut -f n,DELITTO then uniq -a then sort -n n then cut -f DELITTO then clean-whitespace "$folder"/processing/tmp-01.csv

# estrai i codici delle categorie delitti da schema CSV

# cambia il carriage return in stile Linux
dos2unix -n "$folder"/../../dati/delitti-forze-polizia/rawdata/2019/NT00062_Delitti_denunciati__-_dati_anno_2019_-_dati_Provinciali.csv "$folder"/processing/tmp-02.csv

# rimuovi il separatore di campo di fine riga, è un errore
sed -i 's/;$//g' "$folder"/processing/tmp-02.csv

# rimuovi la 6 colonna, è un errore. Esiste soltanto perché c'è un valore di cella errato
mlr -I --csv -N --ifs ";" cut -x -f 6 "$folder"/processing/tmp-02.csv


mlr -I --csv cut -f Reato then uniq -a then sort -f Reato then clean-whitespace then filter -x '$Reato=~"TOTALE"' then put -S '$Reato=gsub($Reato,"([0-9])\. +","\1.");$codice=sub($Reato,"^(.{4}).+$","\1");$etichetta=sub($Reato,"^(.{4}) (.+)$","\2");${Livello-01}=sub($codice,"^(.+)\.(.+)$","\1");${Livello-02}=sub($codice,"^(.+)\.(.+)$","\2");if($Reato=~"\.0"){$categoria=$etichetta}else{$categoria=""}' then fill-down -f categoria "$folder"/processing/tmp-02.csv

### predisponi tutti i dati dei delitti per provincia ###

# I CSV

# questo find estra i CSV sui delitti dal 2016 al 2019
find "$folder"/../../dati/delitti-forze-polizia/rawdata -name "*Deli*csv" -type f | while read line; do
  # estrai l'anno, in modo da usarlo per nominare i file di output
  name=$(echo "${line}" | grep -oP '_[0-9]{4}_' | grep -oP '[0-9]{4}')
  dos2unix -n "$line" "$folder"/processing/"${name}".csv
  iconv -f iso-8859-1 -t UTF-8 "$folder"/processing/"${name}".csv >"$folder"/processing/tmp.csv
  mv "$folder"/processing/tmp.csv "$folder"/processing/"${name}".csv
  # cambia il separatore di campo da ";" a "," e rimuovi eventuale colonna 6 se presente
  mlr -I --csv -N --ifs ";" cut -x -f 6 "$folder"/processing/"${name}".csv
  # rimuovi da tutti i CSV la colonna sulle regioni, è ridondante. Se esiste una categoria scritta "15. c", correggere in "15.c"
  # correggi categoria scritta in modo errato
  mlr -I --csv cut -x -r -f "egion" then label ANNO,Provincia,Reato,Totale then put '$Reato=gsub($Reato,"([0-9])\. +","\1.");$Reato=sub($Reato,"15.. Furti in danno di u","15.c Furti in danno di u")' "$folder"/processing/"${name}".csv
done

# Gli XLS del 2020 e 2016

find "$folder"/../../dati/delitti-forze-polizia/rawdata -iname "*Deli*016*xls*" -or -iname "*Deli*020*xls*" -type f | while read line; do
  name=$(echo "${line}" | grep -oP '/[0-9]{4}/' | grep -oP '[0-9]{4}')
  nomeProvinceSheet=$(in2csv -n "$line" | grep -iP 'rov')
  in2csv -I --sheet "$nomeProvinceSheet" "$line" >"$folder"/processing/"${name}".csv
done

# rimuovi righe di intestazione
tail <"$folder"/processing/2020.csv -n +3 >"$folder"/processing/tmp-03.csv

# aggiungi colonna ANNO e rimuovi le righe con i totali
mlr --csv put '$ANNO=2020' then reorder -f ANNO then label ANNO,Provincia,Reato,Totale then filter -x 'tolower($Reato)=~"otal"' "$folder"/processing/tmp-03.csv >"$folder"/processing/2020.csv

# normalizza le categorie dei reati, così come nei CSV 2016
mlr --csv join --ul -j Reato -l Reato -r XLS -f processing/2020.csv then unsparsify then put '$Reato=$CSV' then cut -o -f ANNO,Provincia,Reato,Totale "$folder"/../../dati/delitti-forze-polizia/risorse/stele-reati.csv >"$folder"/processing/tmp-04.csv

mv "$folder"/processing/tmp-04.csv "$folder"/processing/2020.csv

mlr --csv filter -x 'tolower($Reato)=~"otal"' then filter -x 'is_null($Totale)' then filter -x '$Totale==0' then sort -f ANNO,Provincia then put -S '$Totale=sub($Totale,"\.0$","");$Totale=sub($Totale,"\.","");$Provincia=toupper($Provincia)' "$folder"/processing/20[12][7890].csv >"$folder"/../../dati/delitti-forze-polizia/output/numero-delitti-per-provincia.csv

# aggiungi codice province

mlr -I --csv put '$Provincia=sub($Provincia,"AOSTA","Valle d'\''Aosta/Vallée d'\''Aoste");$Provincia=sub($Provincia,"BOLZANO","Bolzano/Bozen");$Provincia=sub($Provincia,"FORL.+CESENA","Forlì-Cesena");$Provincia=sub($Provincia,"REGGIO EMILIA","Reggio nell'\''Emilia");$Provincia=sub($Provincia,"PESA.+BINO","Pesaro e Urbino");$Provincia=sub($Provincia,"VERB.+OLA","Verbano-Cusio-Ossola")' "$folder"/../../dati/delitti-forze-polizia/output/numero-delitti-per-provincia.csv

mlr --csv cut -f Provincia then uniq -a "$folder"/../../dati/delitti-forze-polizia/output/numero-delitti-per-provincia.csv >"$folder"/processing/province.csv

csvmatch --fuzzy levenshtein -r 0.95 -i -a -n "$folder"/processing/province.csv "$folder"/../../dati/risorse/province.csv --fields1 "Provincia" --fields2 "Denominazione dell'Unità territoriale sovracomunale (valida a fini statistici)" --output 1.Provincia 2."Codice dell'Unità territoriale sovracomunale (valida a fini statistici)" --join left-outer >"$folder"/processing/tmp_province.csv

mlr --csv join --ul -j "Provincia" -f "$folder"/../../dati/delitti-forze-polizia/output/numero-delitti-per-provincia.csv then unsparsify "$folder"/processing/tmp_province.csv >"$folder"/processing/tmp.csv

mv "$folder"/processing/tmp.csv "$folder"/../../dati/delitti-forze-polizia/output/numero-delitti-per-provincia.csv

mlr --csv join --ul -j "Codice dell'Unità territoriale sovracomunale (valida a fini statistici)" -f "$folder"/../../dati/delitti-forze-polizia/output/numero-delitti-per-provincia.csv then unsparsify then rename -r 'Codice de.+,Codice Provincia' then rename -r 'Denomina.+,Denominazione Provincia' then rename -r '.+Storic.+,Codice Provincia Storico' "$folder"/../../dati/risorse/province.csv >"$folder"/processing/tmp.csv

mv "$folder"/processing/tmp.csv "$folder"/../../dati/delitti-forze-polizia/output/numero-delitti-per-provincia.csv

# aggiungi categoria reato macro livello

mlr --csv join --ul -j Reato -l Reato -r CSV -f "$folder"/../../dati/delitti-forze-polizia/output/numero-delitti-per-provincia.csv then unsparsify then cut -x -f XLS then reorder -f categoria then sort -f ANNO,Provincia,Reato,categoria "$folder"/../../dati/delitti-forze-polizia/risorse/stele-reati.csv >"$folder"/processing/tmp.csv

mv "$folder"/processing/tmp.csv "$folder"/../../dati/delitti-forze-polizia/output/numero-delitti-per-provincia.csv

# aggiungi data popolazione

mlr --csv join --ul -j "Codice Provincia" -l "Codice Provincia Storico" -r "Codice Provincia" -f "$folder"/../../dati/delitti-forze-polizia/output/numero-delitti-per-provincia.csv then unsparsify then put '$ratio=$Totale/${Totale Popolazione}*100000' "$folder"/../../dati/risorse/province-popolazione.csv >"$folder"/processing/tmp.csv

mv "$folder"/processing/tmp.csv "$folder"/../../dati/delitti-forze-polizia/output/numero-delitti-per-provincia.csv
