shinyServer(function(input, output) {

    # afficher jeu de données (dans l'onglet "présentation")
    output$tableau <- renderDataTable({emissions}, options = optTabl) # options d'affichage DataTable

    # graphique par pays
    output$graphe <- renderPlotly({
        ggplot(dfm[dfm$country == input$Pays,], aes(x = variable, y = value)) +
            labs(x = "années", y = "émissions (tonnes/personne)", title = input$Pays) +
            geom_line(color = "firebrick4", size = 1, alpha = .8) + optGG
    })

###################################################################################################
# carte générale avec légende et fenêtre d'information
# ref : https://rstudio.github.io/leaflet/choropleths.html
# la partie "fenêtre d'information" est reporté en dessous pour rendre interactif

    output$carte <- renderLeaflet({
        leaflet(jointure) %>%
            addLegend(pal = pal, values = ~tranches, opacity = 0.7, position = "bottomleft",
                title = "CO<sub>2</sub> émission<br>(tonnes/personne)" # format HTML
            ) %>% addProviderTiles(
                provider = providers$OpenStreetMap.France, # fond OpenStreetMap français
                options = providerTileOptions(noWrap = TRUE) # pas de répétition
            ) %>% setView(lng = 22, lat = 23, zoom = 2.5)
    })

###################################################################################################
# animation de la carte
# ref 1 : https://rstudio.github.io/leaflet/shiny.html
# ref 2 : https://gis.stackexchange.com/questions/175398/interactive-and-dynamic-map-with-wind-data-in-r-leaflet

    # colonne correspondant à l'année choisie
    choix_annee <- reactive({jointure[as.character(input$selectYear)]})

    # changement de carte
    observe({

        # transformer les données en vecteur sinon c'est un data frame et ça bug quand on fait des labels
        annee <- unlist(choix_annee()@data, recursive = FALSE, use.names = FALSE)
        labels <- sprintf("<strong>%s</strong><br/>%g tonnes/personne", jointure$COUNTRY, annee) %>% lapply(htmltools::HTML)

        leafletProxy(mapId = "carte", data = choix_annee()) %>% clearShapes() %>% # effacer les formes
            addPolygons(
                weight = 2, opacity = 1, color = "white", dashArray = "3", # options pour le contour
                fillOpacity = 0.5, fillColor = ~pal(annee), # options pour les polygones
                highlight = highlightOptions( # options d'interaction avec la carte
                    color = "#CB4335", dashArray = "", bringToFront = TRUE, weight = 2, opacity = 0.8
                ), label = labels, labelOptions = labelOptions( # options pour les labels
                    textsize = "15px", direction = "auto",
                    style = list("font-weight" = "normal", padding = "3px 8px")
                )
            )
    })

###################################################################################################
})
