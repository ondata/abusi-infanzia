# Dati

Si tratta dei "**Numero dei Delitti denunciati all'autorità Giudiziaria dalle forze di Polizia**".

La fonte è l'ufficio centrale di statistica del Ministero degli interni:<br>
<http://ucs.interno.gov.it/ucs/contenuti/Numero_dei_delitti_denunciati_all_autorita_giudiziaria_dalle_forze_di_polizia_int_00062-7730889.htm>

I dati grezzi, così come dalla fonte, sono stati archivati in [questa cartella](rawdata).

Quelli del 2020 - ancora non pubblicati sul sito al 6 marzo 2022 - sono stati ottenuti con una richiesta via PEC inviata dall'Associazione onData all'ufficio statistico.

I dati relativi alla delittuosità "Anno 2021" non sono ancora disponibili perché in fase di consolidamento da parte dell’ufficio competente. Saranno disponibili nel periodo settembre/ottobre per i dati che si riferiscono all'anno precedente.

Due raggruppamenti categorici:

- per numero di delitti;
- per persone denunciate.

Tre raggruppamenti geografici: nazionale, per regione, per provincia.

> Al riguardo si specifica che i dati statistici in materia di delittuosità comprendono i delitti commessi e denunciati all'A.G. da tutte le forze di Polizia (Polizia di Stato, Arma dei Carabinieri, Guardia di Finanza, Corpo Forestale dello Stato, Polizia Penitenziaria, DIA, Polizia Municipale, Polizia Provinciale, Guardia Costiera) e che **il totale delle informazioni** riferite a **ciascuno degli ambiti territoriali** considerati dal Sistema (comuni, province, regioni) **può non coincidere con il dato di sintesi riferito al livello immediatamente superiore** (ad esempio: la somma dei dati provinciali può differire dal dato riferito all'intera regione, ecc.). Ciò si verifica perché i "delitti commessi" non localizzabili in un determinato ambito territoriale (comune, provincia, regione) sono rilevati dal sistema al piu ampio livello nel quale è possibile collocarli (provincia, regione, stato).

# Chiedere al Ministero

- conferma dello "0 reati" per categoria 12.c e 12.d. Come è possibile?
- manca la Provincia del Sud Sardegna: come mai?
- capire come funzionano le categorie di alto livello, perché spesso il totale non è la somma delle voci di categoria di rango inferiore. Ad esempio per il 2020, ad Agrigento, per la categoria `15.0` ci sono 2277 reati, ma la somma delle altre categorie è 1145
  - potrebbe dipendere dalla nota di sopra, per cui quando un reato non è localizzato rispetto alla provincia, si mette a livello regionale, ma la differenza è troppo grande
- chiedere anche i dati sulle persone;

# Verifiche da fare


# Note di lavoro

- il separatore dei CSV è `;`;
- l'encoding sembra `ISO-8859-1` (via chardetect)
- nel file XLS dei delitti del 2020 la colonna con i tipi di reato si chiama `DELITTO`, nel CSV del 2019 si chiama `Reato`
- il file CSV delitti del 2019 ha per una sola cella, una colonna in più
- ci sono righe con i totali, sono da togliere
- nel CSV dei delitti del 2019 c'è il separatore delle migliaia. Da rimuovere
- nel CSV dei delitti del 2019 la categoria `02. 0 STRAGE` è da correggere in `02.0 STRAGE`
- nel CSV dei delitti del 2017 non c'è il campo regioni
- i nomi provincia a volte sono in tutto maiuscolo, a volte no
- i nomi di provincia non sono tutti corretti (come Reggio Emilia)
- non ci sono i codici geografici
- nel delitti CSV del 2017, c'è "15.. Furti in dan..." al posto di "15.c Furti in dan..."
- tutti i CSV sono poco utilizzabili
