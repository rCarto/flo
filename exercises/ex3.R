library(mapview)
library(sf)
library(cartography)

############## Q 1 

sir_31 <- readRDS("./data/sir_31.rds")
mapview(sir_31, map.types = "OpenStreetMap", 
        col.regions = "#940000", 
        label = paste(sir_31$L2_NORMALISEE, sir_31$NOMEN_LONG, sep = " - "), 
        color = "white", legend = TRUE, layer.name = "Restaurants in SIRENE",
        homebutton = FALSE, lwd = 0.5) 



############# Q 2
# import
iris_31 <- readRDS("./data/iris_31.rds")


# function to create a grid and count points in it
pt_in_grid <- function(feat, adm, cellsize = 50){
  grid <- st_make_grid(x = adm, cellsize = cellsize, what = "polygons")
  . <- st_intersects(grid, adm)
  grid <- grid[sapply(X = ., FUN = length)>0]
  . <- st_intersects(grid, feat)
  grid <- st_sf(n = sapply(X = ., FUN = length), grid)
  return(grid)
}

# create a grid and count points in it 
grid <- pt_in_grid(sir_31, iris_31, 2000)

# default plot
plot(grid)

# n of rest / km2
grid$n <- grid$n*1000*1000/as.numeric(st_area(grid))


# custom plot with equal length classes
bks <- getBreaks(grid$n[grid$n>0], method = "equal", nclass = 9)
cols <- carto.pal("wine.pal", length(bks)-1)
# ou 
# cols <- mapview::mapviewGetOption("raster.palette")(length(bks)-1)
opar <- par(mar = c(0,0,1.2,0), bg = "#FBEDDA")
plot(st_geometry(iris_31), col = "ivory3", border = "NA", lwd = 0.5)
choroLayer(grid, var = "n", border = NA,
           breaks = bks, col = cols, legend.values.rnd = 2,
           legend.pos = "topleft", legend.title.txt = "Restaurants / km2",
           add=T)
layoutLayer(title = "Restaurant Distribution in Haute-Garonne", scale = 5, 
            frame = FALSE, tabtitle = TRUE, north = TRUE,
            author = "Kim & Tim", sources = "INSEE - 2018, Sirene - 2018")

############# Q 3
# reinitiate default par
par(opar)
hist(grid$n[grid$n>0], 150)
## => highly dissymetric distributiion => use a geometric progression classification

bks <- getBreaks(grid$n[grid$n>0], method = "geom", nclass = 9)
cols <- carto.pal("wine.pal", length(bks)-1)
# ou 
# cols <- mapview::mapviewGetOption("raster.palette")(length(bks)-1)
par(mar = c(0,0,1.2,0), bg = "#FBEDDA")
plot(st_geometry(iris_31), col = "ivory3", border = "NA", lwd = 0.5)
choroLayer(grid, var = "n", border = NA,
           breaks = bks, col = cols,
           legend.pos = "topleft", legend.values.rnd = 2,
           legend.title.txt = "Restaurants / km2",
           add=T)
layoutLayer(title = "Restaurant Distribution in Haute-Garonne", scale = 5, 
            frame = FALSE, tabtitle = TRUE, north = TRUE,
            author = "Kim & Tim", sources = "INSEE - 2018, Sirene - 2018")


############# Q 4
library(spatstat)
library(maptools)
library(raster)
compute_kde <- function(feat, adm, title, sigma = 100, res = 50){
  w <- as.owin(as(adm, "Spatial"))
  pts <- st_coordinates(feat)
  p <- ppp(pts[,1], pts[,2], window=w)
  dens <- density.ppp(p, sigma = sigma, eps = res)
  result <- raster(dens, crs = st_crs(adm)[[2]]) * 1000000
  return(result)
}

x <- compute_kde(feat = sir_31, adm = iris_31, sigma = 2000, res = 2000)
bks <- getBreaks(values(x), nclass = 12, method = "quantile")
cols <- carto.pal("wine.pal", length(bks)-1)
# ou 
# cols <- mapview::mapviewGetOption("raster.palette")(length(bks)-1)
par(mar = c(0,0,1.2,0), bg = "#FBEDDA")
plot(st_geometry(iris_31), col = NA, border = NA, main="", bg = "#FBEDDA")
plot(x, breaks = bks, col=cols, add = T,legend=F)
legendChoro(pos = "topleft",
            title.txt = "Restaurant / km2)",values.cex = 0.5,
            breaks = bks, nodata = FALSE,values.rnd = 2,
            col = cols)
layoutLayer(title = "Smoothed Density of Restaurants in HG", scale = 5,
            tabtitle = TRUE, frame = FALSE,
            author = "Kim & Tim", sources = "INSEE - 2018, Sirene - 2018")



############# Q 5
x <- compute_kde(feat = sir_31, adm = iris_31, sigma = 2000, res = 500)
bks <- getBreaks(values(x), nclass = 12, method = "quantile")
cols <- carto.pal("wine.pal", length(bks)-1)
# ou 
# cols <- mapview::mapviewGetOption("raster.palette")(length(bks)-1)
par(mar = c(0,0,1.2,0), bg = "#FBEDDA")
plot(st_geometry(iris_31), col = NA, border = NA, main="", bg = "#FBEDDA")
plot(x, breaks = bks, col=cols, add = T,legend=F)
legendChoro(pos = "topleft",
            title.txt = "Restaurant Density\n(rest./km2)",values.cex = 0.5,
            breaks = bks, nodata = FALSE,values.rnd = 2,
            col = cols)
layoutLayer(title = "Smoothed Density of Restaurants in HG", scale = 5,
            tabtitle = TRUE, frame = FALSE,
            author = "Kim & Tim", sources = "INSEE - 2018, Sirene - 2018")




