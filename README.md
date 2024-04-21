# Proof-of-concept geautomatiseerde data workflow

Alle scripts voor dit project zijn te vinden in de `scripts` map.

## 1.1 Verzamelen ruwe tijdseriedata

Het script dat ik voor deze stap heb geschreven noemt `collect-data.sh`. Ik heb gekozen om data te verzamelen van 2 APIs.

De eerste API haalt informatie op over het laatste Ethereum-blok in de Ethereum Blockchain
van de [Etherscan API](https://docs.etherscan.io/api-endpoints/geth-parity-proxy). Voor deze API heb je een API-key nodig. Ik sla deze key op als omgevingsvariabele op mijn systeem zodat je ze niet kan zien in het script. Om de data van het laatste Ethereum-blok op te kunnen vragen heb je het bloknummer van het laatste blok nodig.
Dit haal ik daarom eerst op door een ander API endpoint van de Etherscan API aan te spreken die het laatste bloknummer teruggeeft.
Vervolgens gebruik ik dit bloknummer als parameter in de request voor het laatste Ethereum blok. Meer informatie over een Ethereum-blok kan je vinden op de [Ethereum website](https://ethereum.org/en/developers/docs/blocks/).

De tweede API haalt de huidige Ethereum-prijs in USD (US Dollars) en BTC (Bitcoin) op van de [CoinGecko API](https://www.coingecko.com/api/documentation).

De verzamelde gegevens worden vervolgens opgeslagen in JSON-bestanden
met een tijdstempel in een opgegeven directory. Er wordt ook gecheckt op fouten en of de juiste dependencies geïnstalleerd zijn. Als het ophalen van de data misloopt of de nodige dependencies niet geïnstalleerd is zal er een foutmelding met een tijdstempel weggeschreven worden naar het gespecifieërde logbestand.

Ik heb ervoor gekozen om op 09/12/2023 van 12u30 tot en met 20u30 elk half uur data te verzamelen. Ik heb dit proces geautomatiseerd aan de hand van een crontab.

Om dit script uit te voeren moet je `jq` installeren:

```bash
sudo apt install jq
```

## 1.2 Data transformeren

Hiervoor heb ik een script geschreven met als doel de verzamelde gegevens in JSON omzetten in een csv-bestand. Het script noemt `transform-data.sh`.

Het script sorteert eerst de bestanden in de data directory op basis van de datum die in hun naam staat. Vervolgens overloopt het script deze gesorteerde bestanden per twee (een Ethereum-blok bestand en een prijs bestand). Uit het Ethereum-blok bestand wordt de `timestamp, gasUsed, baseFeePerGas, transactionCount` gehaald door gebruik te maken van `jq` (a JSON processor). Sommige van deze gegevens staan in hexadecimaal formaat, daarom is er een functie voorzien om deze gegevens om te zetten in een decimaal formaat. Daarnaast staat de `baseFee` in `wei` beschreven (data-eenheid van de Ethereum blockchain om de hoeveelheid gas van een transactie voor te stellen). Om deze leesbaarder te maken is er een functie die wei omzet in Gwei (Giga wei). Uit het prijs bestand wordt de prijs van Ethereum in USD (`usdPrice`) en BTC (`btcPrice`) gehaald. Vervolgens worden al deze gegevens toegevoegd aan het gespecifieerde csv-bestand. Als er iets fout loopt wordt er een foutmelding met een tijdstempel weggeschreven naar het gespecifieerde logfile. Scripts die verwerkt zijn worden aan een tekstbestand `processed_files.txt` toegevoegd zodat ze niet opnieuw verwerkt moeten worden als er nieuwe raw data is bijgekomen en het script opnieuw wordt uitgevoerd.

Om dit script uit te voeren moet je naast `jq` ook `bc` installeren:

```bash
sudo apt install bc
```

## 1.3. Data analyseren

Voor deze stap heb ik een script geschreven genaamd `data-analysis.py`. Dit is een python script dat het csv-bestand, dat in de vorige stap genenereerd werd, analyseert en visualiseert aan de hand van grafieken en tabellen. Het script maakt gebruik van de `pandas` library om het csv-bestand in te lezen en de tabellen te genereren. Vervolgens wordt de `matplotlib` library gebruikt om de grafieken te genereren.

Om dit script uit te voeren moeten [python](https://www.python.org/downloads/) en `pandas, matplotlib, tabulate` geïnstalleerd worden:

```python
pip install pandas matplotlib tabulate
```

## 1.4. Rapport genereren

Om het rapport te genereren heb ik een script geschreven genaamd `generate-report.sh`. Het doel van dit script is om de afbeeldingen en tabellen die in de vorige stap gegenereerd zijn te gebruiken om een raport van te maken. Ik gebruikt voor deze stap een template markdown-bestand met placeholders waar de afbeeldingen en tabellen zullen moeten komen. Vervolgens gebruik ik het sed commando om elke placeholder te vervangen door een afbeelding of tabel en schrijf ik de output hiervan weg naar een bestand in de map waar de rapporten bewaard worden (`reports`). Ik maak hetzelfde raport ook aan in het `index.md` bestand van de `docs` map in de `reports` map zodat dit markdown bestand gebruikt kan worden om met `mkdocs` een html pagina van te genereren. Deze pagina is te vinden in `reports/site/index.html`. Als tweede soort rapport heb ik voor een pdf-bestand gekozen. Dit genereer ik met behulp van de `pandoc` package die een markdown bestand in een pdf bestand kan omzetten.

Om dit script uit te voeren moeten `pandoc, mkdocs` geïnstalleerd zijn:

```bash
sudo apt install pandoc
```

```python
pip install mkdocs
```

## 1.5. Gehele workflow automatiseren

Voor deze stap heb ik een `Makefile` geschreven die zich in de `scripts` map bevindt. Deze `Makefile` zal de scripts voor het transformeren en analyseren van de data en het genereren van het raport sequentieel uitvoeren wanneer het commando `make` wordt uitgevoerd in de `scripts` map. Er wordt telkens een nieuw rapport gegenereerd en het oude wordt verwijderd.
