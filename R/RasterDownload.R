
#' Download Landsat Image as Raster
#'
#' This function downloads a median composite of Landsat images over a date range and region.
#'
#' @param start_date Start date (e.g. "2023-01-01")
#' @param end_date End date (e.g. "2023-12-31")
#' @param roi Numeric vector of [minLon, minLat, maxLon, maxLat]
#' @param scale Resolution in meters (default is 30 for Landsat)
#' @param via Method to fetch image:  "drive" ( safe export)
#' @return A SpatRaster object
#' @export

for (pkg in c("googledrive", "stars", "future","sf", "geojsonio")) {
  if (!requireNamespace(pkg, quietly = TRUE)) install.packages(pkg)
}


getLandsatData <- function(start_date, end_date, roi, scale = 30) {
  if (!requireNamespace("googledrive", quietly = TRUE)) {
    install.packages("googledrive")
  }
  
  library(rgee)
  library(terra)
  library(googledrive)
  
  ee_Initialize(drive = TRUE)
  
  ee_roi <- ee$Geometry$Rectangle(roi)
  
  
  image <- ee$ImageCollection("LANDSAT/LC08/C02/T1_L2")$
    filterBounds(ee_roi)$
    filterDate(start_date, end_date)$
    map(function(img) {
      qa <- img$select("QA_PIXEL")
      mask <- qa$bitwiseAnd(ee$Number(1)$leftShift(3))$eq(0)
      img$updateMask(mask)
    })$
    median()$
    select(c("SR_B.*", "ST_B.*"))
  
  ee_as_rast(
    image = image,
    region = ee_roi,
    scale = scale,
    via = "drive"
  )
}
  





#' Get Sentinel-2 Data from GEE 
#' 
#' @param roi Numeric vector of [minLon, minLat, maxLon, maxLat]
#' @param start_date Start date as string (YYYY-MM-DD)
#' @param end_date End date as string (YYYY-MM-DD)
#' @param scale Scale/resolution in meters 10m for sentinel
#' @param via Method to fetch image:  "drive" ( safe export)
#' @return A sentinel 2 image
#' @export


getSentinelData <- function(start_date, end_date, roi, scale = 10) {
  library(rgee)
  library(terra)
  
  ee_Initialize()
  
  ee_roi <- ee$Geometry$Rectangle(roi)
  
  # Sentinel-2 surface reflectance collection
  col <- ee$ImageCollection("COPERNICUS/S2_SR")$
    filterBounds(ee_roi)$
    filterDate(start_date, end_date)$
    map(function(img) {
      # Cloud masking using QA60
      qa <- img$select("QA60")
      mask <- qa$bitwiseAnd(ee$Number(1)$leftShift(10))$eq(0)$And(
        qa$bitwiseAnd(ee$Number(1)$leftShift(11))$eq(0)
      )
      img$updateMask(mask)
    })$
    median()
  
  # Get download URL
  url <- col$getDownloadURL(list(
    region = ee_roi,
    scale = scale,
    format = "GeoTIFF"
  ))
  
  # Download the image to a temporary file
  tempfilepath <- tempfile(fileext = ".tif")
  download.file(url, tempfilepath, mode = "wb")
  
  # Read into R as a SpatRaster
  raster_img <- terra::rast(tempfilepath)
  return(raster_img)
} 


