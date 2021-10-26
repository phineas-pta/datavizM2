shinyUI(fluidPage(title = "Visu ♥♥♥", navbarPage(title = "#DataScience",

###################################################################################################
# 1e onglet : carte

# auto-fit map to screen : https://gist.github.com/byzheng/7e38d36cc260fff5cba3
tabPanel(title = "Carte", tags$div(style = "height: calc(100vh - 80px); padding: 0; margin: 0;",

    # carte
    leafletOutput(outputId = "carte", height = "100%", width = "100%"),

    # curseur pour choisir l'année
    absolutePanel(bottom = 10, right = 500, #draggable = TRUE,
        sliderInput(inputId = "selectYear", width = "500px",
            label = "choisir une année :",
            min = min(annees), max = max(annees), # gamme de valeurs
            value = 2000,#min(annees), # valeur par défaut
            sep = "", # séparateur de milliers, par défauit c'est virgule
            step = 10, animate = animationOptions(interval = 5000) # temps d'attente = 5s car c'est long à charger
        )
    )
)),

###################################################################################################
# 2e onglet : graphique par pays

tabPanel(title = "Évolution des émissions de CO2",
    fluidRow(column(width = 3, wellPanel(
        selectInput(inputId = "Pays",
            label = "Sélectionnez le pays",
            choices = emissions$country,
            selected = "France"
        )
    ))),
    wellPanel(plotlyOutput(outputId = "graphe"))),

###################################################################################################
# 3e onglet : présentation

tabPanel(title = "Données",
    includeHTML("assets/presentation.html"),
    dataTableOutput(outputId = "tableau")
)

###################################################################################################
)))