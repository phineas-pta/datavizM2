library(rgdal)
library(leaflet)
library(shiny)
library(plotly)

# shape file contenant le contour et le nom des pays
shapefile <- readOGR("geoMonde/nouveauMonde.shp")
# maptools::readShapeLines est obsolète, on utilise rgdal::readOGR

# émissions de CO2 par pays
emissions <- read.csv("assets/emissions.csv", check.names = FALSE) # nom des colonnes est l'année en chiffre
# read.csv = read.table(header = TRUE, sep = ",")

# liste des années, convertir en numérique pour pouvoir utiliser le curseur
annees <- as.numeric(names(emissions)[-1]) # on exclut le 1er élément qui est "Country"

# melt pour faire des graphiques par pays
# ref : https://stackoverflow.com/questions/12894306/ggplot2-one-line-per-each-row-dataframe
dfm <- reshape::melt(emissions, id.vars = "country")
dfm$variable <- as.numeric(as.character(dfm$variable))

# jointure pour coïncider les lignes des 2 données
# ref : http://www.nickeubank.com/wp-content/uploads/2015/10/RGIS2_MergingSpatialData_part1_Joins.html
jointure <- merge(shapefile, emissions, by.x = "COUNTRY", by.y = "country")

# on définit nos classes de valeurs d'émission
tranches <- c(0, 0.2, 1, 2, 10, 20, 100, Inf)
amplitude <- range(emissions[, -1], na.rm = TRUE)
pal <- colorBin("Reds", domain = amplitude, bins = tranches)

# options graphiques de ggplot
optGG <- theme(
    plot.title = element_text(hjust = .5, size = 30),
    axis.title = element_text(colour = "firebrick4", size = 15),
    panel.background = element_rect(fill = "azure2"),
    plot.background = element_rect(fill = "grey"),
    panel.grid = element_line(colour = "white")
)

# options d'affichage de tableau du jeu de données
# https://datatables.net/plug-ins/i18n/French
optTabl <- list(
    pageLength = 15, # nombre de lignes à afficher par défaut
    scrollX = TRUE, # permette de défiler verticalement
    lengthMenu = list(c(5, 15, -1), c("5", "15", "Tous")), # choisir nombre de lignes à afficher
    language = list( # traduction française
        emptyTable = "Aucune donnée disponible dans le tableau",
        info = "Affichage de l'élément _START_ à _END_ sur _TOTAL_ éléments",
        infoEmpty = "Affichage de l'élément 0 à 0 sur 0 élément",
        infoFiltered = "(filtré de _MAX_ éléments au total)",
        lengthMenu = "Afficher _MENU_ éléments",
        loadingRecords = "Chargement en cours...",
        processing = "Traitement en cours...",
        search = "Rechercher :",
        zeroRecords = "Aucun élément à afficher",
        paginate = list(
            first = "Premier",
            last = "Dernier",
            "next" = "Suivant",
            previous = "Précédent"
        )
    )
)