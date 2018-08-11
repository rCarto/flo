####### AVEC SP
# couche_carto_sp <- merge(fortify(
#   rgeos::gBuffer(sf:::as_Spatial(couche_carto),
#   width = 0, byid = TRUE), region = "CODE_IRIS"), couche_carto %>% st_set_geometry(NULL), by.x = "id",
#   by.y = "CODE_IRIS", all.x = TRUE)

# q <- ggplot(couche_carto_sp) +
#   geom_polygon(aes(long, lat, group = group, fill = value),
#                data = couche_carto_sp) +
#   scale_fill_identity() +
#   coord_fixed()
# + xlim(c(565000,590000)) + 
# annotation_custom(
#   ggplotGrob(
#     tric$legend +
#       theme(plot.background = element_rect(fill = NA, color = NA))
#   ),
#   xmin = 575000, xmax = 595000, ymin = 6274000, ymax = 6284000) 





        
# # Exercice 5 : Carte tricolore
# 
# #####  {.bonus}
# 
# Réaliser une carte tricolore qui représente les iris de Toulouse en fonction de si elles sont plutôt dotées en restaurants, cafés ou fast foods (données OSM)
# 
# ##### {}
# 
# 
# ```{block, box.type = "warning"}
# Pour le moment, la fonction Tricolore est buggée suite à la mise à jour de ggplot2...
# Une issue a été postée, à voir si ce problème sera fixé avant Florence. 
# A titre d'exemple, j'ai compilé le code de la fonction avec une ancienne version de ggplot2 et j'ai enregistré le résultat de la fonction Tricolore dans tric.rds
# ```
# 
# 
# ```{r, nm=TRUE, solution = TRUE}
# bdd <- readRDS("../data/osm_31.rds") %>% 
# filter(INSEE_COM=="31555")
# 
# bdd_restaurant <- bdd %>% filter(amenity=="restaurant") %>%  
# group_by(CODE_IRIS) %>% 
# summarize(restaurant= n()) %>% 
# st_set_geometry(NULL)
# 
# bdd_fast_food <- bdd %>% filter(amenity=="fast_food") %>%  
# group_by(CODE_IRIS) %>% 
# summarize(fast_food= n()) %>% 
# st_set_geometry(NULL)
# 
# bdd_cafe <- bdd %>% filter(amenity=="cafe") %>%  
# group_by(CODE_IRIS) %>% 
# summarize(cafe= n()) %>% 
# st_set_geometry(NULL)
# 
# couche_carto <- left_join(iris_31 %>%  filter(INSEE_COM=="31555"), 
# bdd_restaurant,
# by=c("CODE_IRIS"="CODE_IRIS")
# ) %>% 
# left_join(bdd_fast_food,by=c("CODE_IRIS"="CODE_IRIS")) %>% 
# left_join(bdd_cafe,by=c("CODE_IRIS"="CODE_IRIS")) %>% 
# replace(is.na(.),0) %>% 
# mutate(part_restaurant = restaurant / (restaurant + fast_food + cafe), 
# part_fast_food = fast_food / (restaurant + fast_food + cafe), 
# part_cafe = cafe / (restaurant + fast_food + cafe)
# )
# 
# #devtools::install_github("jschoeley/tricolore")
# library(tricolore)
# 
# # tric <- Tricolore(couche_carto %>% st_set_geometry(NULL), 'part_restaurant', 'part_fast_food', 'part_cafe', center = NA)
# #saveRDS(object = tric, file = "../data/tric.rds")
# tric <- readRDS("../data/tric.rds") 
# #tric$legend
# 
# 
# couche_carto <- bind_cols(couche_carto,tric$hexsrgb %>% as_data_frame() %>% replace(is.na(.),"#FFFFFFFF"))
# 
# library(ggplot2)
# q <- ggplot(couche_carto) +
# geom_sf(aes(fill = value)) +
# scale_fill_identity() 
# 
# q
# ```
# 
# <center><img src="./img/tricolore.png" alt="legende tricolore" style="border:0px" height="50%" width="50%"/></center>
# 
# bdd <- bind_cols(summarize(bdd %>% group_by(CODE_IRIS)),
#   summarize(bdd %>% group_by(CODE_IRIS) %>%  filter(amenity=="restaurant") %>%  st_set_geometry(NULL),restaurant= n()) %>% select(restaurant),
#   summarize(bdd %>% group_by(CODE_IRIS) %>%  filter(amenity=="fast_food") %>%  st_set_geometry(NULL),fast_food= n()) %>% select(fast_food),
#   summarize(bdd %>% group_by(CODE_IRIS) %>%  filter(amenity=="cafe") %>%  st_set_geometry(NULL),cafe= n()) %>% select(cafe)
#  )
#   

# 3. Leaflet
# 
# 
# ```{block, box.type = "warning"}
# Les html widgets semblent bugger avec unilur... Issue postée... html modifié à la main pour le moment...
# ```
# 
# 
# ```{r, eval=FALSE, solution=TRUE}
# # Ajout des coordonnées X et Y dans mix_31
# mix_31 <- bind_cols(mix_31,
#                     mix_31 %>%  st_centroid() %>% 
#                       st_transform('+proj=longlat +ellps=GRS80 +no_defs') %>%
#                       st_coordinates() %>% as.data.frame()) 
# 
# library(leaflet)
# carto <- leaflet(mix_31) %>%
#   addTiles('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png') %>%
#   addCircles(lng = ~X, lat = ~Y, weight = 1,
#              radius = ~sqrt(nb_of_rest)*300,
#              popup = ~paste(nb_of_rest),
#              color = ~colorQuantile(cols, domain=mix_31$nb_rest_10000inhab, probs= c(0,0.45,0.6,0.8,1.0))(nb_rest_10000inhab)) %>% 
#   addLegend("topleft", 
#             colors = cols,
#             labels = paste0("[", round(bks,0)[-5], ";", round(bks,0)[-1],"["),
#             title = "Number of restaurants<br>for 10 000 inhabitants",
#             opacity = 1) 
# 
# carto
# 
# ```
# 
# ```{r, echo=FALSE}
# # Ajout des coordonnées X et Y dans mix_31
# mix_31 <- bind_cols(mix_31,
#                     mix_31 %>%  st_centroid() %>% 
#                       st_transform('+proj=longlat +ellps=GRS80 +no_defs') %>%
#                       st_coordinates() %>% as.data.frame()) 
# 
# library(leaflet)
# carto <- leaflet(mix_31) %>%
#   addTiles('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png') %>%
#   addCircles(lng = ~X, lat = ~Y, weight = 1,
#              radius = ~sqrt(nb_of_rest)*300,
#              popup = ~paste(nb_of_rest),
#              color = ~colorQuantile(cols, domain=mix_31$nb_rest_10000inhab, probs= c(0,0.45,0.6,0.8,1.0))(nb_rest_10000inhab)) %>% 
#   addLegend("topleft", 
#             colors = cols,
#             labels = paste0("[", round(bks,0)[-5], ";", round(bks,0)[-1],"["),
#             title = "Number of restaurants<br>for 10 000 inhabitants",
#             opacity = 1) 
# 
# carto
# ```
#### useless
library(cartography)
library(sf)
sir_31 <- readRDS("data/sir_31.rds")
iris_31 <- readRDS("data/iris_31.rds")

###### begins

library(mapview)

mapview(sir_31, map.types = "OpenStreetMap", col.regions = "#940000", label = paste(sir_31$L2_NORMALISEE, sir_31$NOMEN_LONG, sep = " - "), color = "white", legend = TRUE, layer.name = "Restaurants in SIRENE", homebutton = FALSE, lwd = 0.5) 


fufun2 <- function(feat, adm, cs = 500, method="equal",nclass=12) {
  grid <- st_make_grid(x = adm, cellsize = cs, what = "polygons")
  x <- st_intersects(grid, feat) 
  gg <- st_sf(n = sapply(X = x, FUN = length), grid)
  gg <- st_intersection(gg,adm) #NEW
  plot(adm$geometry, col = NA, border = NA, main="", bg = "#FBEDDA")
  bks <- c(0,unique(round(getBreaks(gg$n[gg$n>0], nclass = nclass, method = method),0)))
  cols <- (mapview::mapviewGetOption("raster.palette"))(length(bks) - 1)
  choroLayer(gg, var = "n", border = NA, add = TRUE, method = method, breaks= bks, col= cols, legend.pos="topright", legend.values.cex=0.7, legend.title.cex=0.7, legend.title.txt = "resto per ha", legend.nodata=FALSE,legend.values.rnd=0)
  layoutLayer(title = "Count points in a regular grid", scale = 0.5, tabtitle = TRUE, frame = FALSE)
}

library(spatstat)
library(raster)
library(maptools)
fufun <- function(feat, adm, sigma = 100, res = 50, method="equal",nclass=12) {
  bb <- as(feat, "Spatial")
  bbowin <- as.owin(as(adm, "Spatial"))
  pts <- coordinates(bb)
  p <- ppp(pts[, 1], pts[, 2], window = bbowin)
  ds <- density.ppp(p, sigma = sigma, eps = res)
  rasdens <- raster(ds) * 10000 * 10000
  rasdens <- st_intersection(rasdens,adm) #NEW
  proj4string(rasdens) <- "+init=epsg:2154"
  bks <- unique(round(getBreaks(values(rasdens), nclass = nclass, method = method),0)) 
  cols <- (mapview::mapviewGetOption("raster.palette"))(length(bks) - 1)
  plot(adm$geometry, col = NA, border = NA, main = "", bg = "#FBEDDA")
  plot(rasdens, breaks = bks, col = cols, add = T, legend = F)
  legendChoro(pos = "topright", cex = 0.7, title.cex = 0.7, title.txt = "resto per ha", 
              breaks = bks, nodata = FALSE, values.rnd = 0, col = cols)
  layoutLayer(title = "Smooth density Analysis", scale = 0.5, tabtitle = TRUE, frame = FALSE)
 }

par(mar = c(0, 0, 1.2, 0), mfrow = c(1, 1))
fufun2(sir_31, iris_31, 2000)
fufun2(sir_31, iris_31, 2000,method="quantile",nclass=20)
fufun(sir_31, iris_31,  2000, 2000)
fufun(sir_31, iris_31,  2000, 2000,method="quantile",nclass=12)
fufun(sir_31, iris_31,  2000, 500,method="quantile",nclass=12)


# # installing/loading the package:
# if(!require(installr)) { install.packages("installr"); require(installr)}
# install.pandoc()

# dataprepartion +
#   sm$pcad <- 100 * sm$cad / sm$act



library(ggplot2)


summary(sm$cad)

quantile(sm$cad,probs = seq(0, 1, 0.20))

bks <- getBreaks(v = sm$pcad, method = "quantile", nclass = 6)

?quantile
library(cartography)
  

   
  ?geom_sf
  
  add.alpha <- function(col, alpha=1){
    if(missing(col))
      stop("Please provide a vector of colours.")
    apply(sapply(col, col2rgb)/255, 2, 
          function(x) 
            rgb(x[1], x[2], x[3], alpha=alpha))  
  }
  
  add.alpha("#E84923",0.8)
  
  
    ?scale_fill_continuous
plot(map_ggplot)
