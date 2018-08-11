# Geovisualization and Spatial Analysis
----
Kim Antunez & Timothée Giraud

## Contenu prévisionnel de la séance 

**1. Agrégation spatiale**
 
* Agréger des bases de données disponibles à un niveau géographique « fin » en un ou différents niveaux supra-communaux et illustrer ainsi l’effet MAUP

* Réaliser le même type de traitement sur des couches carto et données spatiales (sf)
 
**2. Cartes « classiques » sous R**

*  Cartes en statique avec quelques exemples sur cartography et/ou ggplot2 : choroplètes, ronds proportionnels (éventuellement discontinuités)

* Cartes interactives, webmapping (leaflet, mapview…)
 
**3. Traitements de cartographie avancée**
 
* agrégation dans des grilles régulières

*  lissages spatiaux 
 
* *[sélection de flux, dominants / dominés avec flows : ne s’adapte pas pour le moment à nos données]* 

* *[4. Ouverture : Représenter les données géographiques au-delà des cartes]*

## Liens utiles 

*  [Cartographie avec R T. Giraud Tuto@Mate (avril 2018)](https://rcarto.github.io/tuto-mate/exemple.html)
*  [Cartographic Explorations of the OpenStreetMap Database with R T. Giraud (janvier 2018)](https://rgeomatic.hypotheses.org/1244)
*  [Bistrographie avec SIRENE M. Garnier (2017)](https://github.com/mtmx/bistrographie)
 

## Bases de données mobilisées

### A. Données administratives nationales françaises : la base SIRENE des entreprises

> Le système informatisé du répertoire national des entreprises et des établissements (SIRENE) dont la gestion a été confiée à l'Insee enregistre l'état civil de toutes les entreprises et leurs établissements, quelle que soit leur forme juridique et quel que soit leur secteur d'activité, situés en métropole, dans les Dom (Guadeloupe, Guyane, Martinique, La Réunion et Mayotte) et à Saint-Pierre et Miquelon. Les entreprises étrangères qui ont une représentation ou une activité en France y sont également répertoriées. L'Insee met depuis un an les données de ce répertoire en [open data](https://www.data.gouv.fr/fr/datasets/base-sirene-des-entreprises-et-de-leurs-etablissements-siren-siret/) et Etalab réalise un traitement automatique de géolocalisation de ces fichiers qu'ils mettent en ligne [ici](http://data.cquest.org/geo_sirene/last/).


*Remarque : SIRENE existe désormais sous la forme d'une [API](https://github.com/ColinFay/ariel) mais, tout comme la base fournie par l'Insee, ne contient pas (encore) de données de géolocalisation*

**avantages** : exhaustivité sur le territoire Français (10 millions d'établissements), données en temps réel, contient une variable quantitative (tranche d'effectifs salariés de l'établissement)

**inconvénients** : l'objectif de la base n'est pas initialement de géolocaliser des commerces mais est un répertoire administratif d'entreprises donc peu de précisions sur le type de bar/restaurant, contient une variable de code commune

Il est proposé pour le TP de se focaliser sur le département de la Haute-Garonne (31) dont la préfecture est Toulouse (analyser les bars et restaurants en prévision de userR2019 !).

Les données utilisées sont rangées dans [data/hautegaronne_sirene](./data/hautegaronne_sirene).


#### Liste des variables utiles

**1. ENSEIGNE : Enseigne ou nom de l'exploitation**

> C'est l'appellation désignant l'emplacement ou le local dans lequel est exercée l'activité. Elle permet à la clientèle d'identifier facilement l'établissement (enseigne ou nom de l'exploitation). Lorsqu'elle existe, l'enseigne est reprise dans la seconde ligne de l'adresse géopostale de l'établissement. Exemple :"Coiff Land" est l'enseigne du salon de coiffure détenu par l'entrepreneur individuel "Madame Martin Justine".
Si besoin on peut utiliser également la variable NOMEN_LONG (Nom ou raison sociale de l'entreprise) qui correspond à la raison sociale pour une personne morale ou le nom pour l'entrepreneur individuel. Cette variable indique pour les entrepreneurs individuels le nom de l'entreprise formé par concaténation d'une partie des prénoms et du nom patronymique de l'entrepreneur individuel, du nom de conjoint ou du nom d'usage. Elle indique la dénomination longue pour les personnes morales. 


**2. APET700 : Activité principale de l'établissement**

> Activité principale de l'établissement
Chacun des établissements d'une entreprise se voit attribuer par l'INSEE, lors de son inscription au répertoire SIRENE, un code caractérisant son activité principale, appelé code APE (Activité Principale Exercée). L'APE est codifiée selon la Nomenclature d'Activités Française (NAF : Rév2, 2008). Les établissements d'une même entreprise peuvent avoir des activités différentes.
Cette variable est systématiquement renseignée. Si une entreprise n'a qu'un seul établissement, l'APE de l'établissement (APET) est égal à l'APE de l'entreprise (APEN). Au moment de la déclaration de l'entreprise, il peut arriver que l'INSEE ne soit pas en mesure d'attribuer le bon code APE : la modalité 0000Z peut alors être affectée provisoirement. Possibilité de consulter la nomenclature exhaustive [ici](https://www.insee.fr/fr/information/2406147).

| 56     	| Restauration                                   	|
|--------	|------------------------------------------------	|
|        	|                                                	|
| 56.1   	| Restaurants et services de restauration mobile 	|
| 56.10  	| Restaurants et services de restauration mobile 	|
| 56.10A 	| Restauration traditionnelle                    	|
| 56.10B 	| Cafétérias et autres libres-services           	|
| 56.10C 	| Restauration de type rapide                    	|
|        	|                                                	|
| 56.2   	| Traiteurs et autres services de restauration   	|
| 56.21  	| Services des traiteurs                         	|
| 56.21Z 	| Services des traiteurs                         	|
| 56.29  	| Autres services de restauration                	|
| 56.29A 	| Restauration collective sous contrat           	|
| 56.29B 	| Autres services de restauration n.c.a.         	|
|        	|                                                	|
| 56.3   	| Débits de boissons                             	|
| 56.30  	| Débits de boissons                             	|
| 56.30Z 	| Débits de boissons                             	|

**3. EFETCENT : Effectif salarié de l'établissement à la centaine près**

> Cette variable correspond à l'effectif salarié à la centaine près de l'établissement. C'est une variable statistique, millésimée au 31/12 d'une année donnée, majoritairement l'année n-2. Elle est à rapprocher de sa date de validité, c'est-à-dire de la date de mise à jour de l'effectif salarié de l'établissement. Le code correspond toujours au chiffre inférieur de la tranche. A partir de 100, c'est l'effectif salarié approché à la centaine inférieure qui est précisé.

| code  | libellé       |
|---------      |----------------------------------------       |
| NN    | Unités non employeuses (pas de salarié au cours de l'année de référence et pas d'effectif au 31/12). Cette tranche peut contenir quelques effectifs inconnus       |
| 0     | 0 salarié (n'ayant pas d'effectif au 31/12 mais ayant employé des salariés au cours de l'année de référence)    |
| 1     | 1 à 2 salariés        |
| 3     | 3 à 5 salariés        |
| 6     | 6 à 9 salariés        |
| 10    | 10 à 19 salariés      |
| 20    | 20 à 49 salariés      |
| 50    | 50 à 99 salariés      |
| 100   | 100 à 199 salariés    |
| 200   | 200 à 299 salariés    |
| .../...       | de 100 en 100 jusqu'à 999 999 salariés        |


**4. Géocodage par Etalab**

* longitude (en degrés décimaux, WGS84)
* latitude (en dégrés décimaux, WGS84) 
* geo_score : indice de similarité fournit par le moteur de géocodage 
* geo_type : "housenumber" = n° trouvé, "interpolation" = n° interpolé, "street" = voie trouvée, "locality" = lieu-dit (ou position de la mairie), "municipality" = position de la commune car l'adresse n'a pas été trouvée. 
* geo_adresse : libellé de l'adresse trouvée (exemple : 39 Rue Jean-Jacques Rousseau 75001 Paris) 
* geo_id : id dans le référentiel BAN, ou BANO (si commence par "BANO_") 
* geo_ligne : ligne d'adresse géocodée (G = géographique, N = normalisée, D = déclarée) 
* geo_insee : code INSEE où l'adresse a été géocodée 

### B. OpenStreetMap

**TODO**

## Fonds de cartes mobilisés

**TODO**