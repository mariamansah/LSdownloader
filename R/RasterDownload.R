

#' Download Landsat Image as Raster
#'
#' This function downloads a median composite of Landsat images over a date range and region.
#'
#' @param start_date Start date (e.g. "2023-01-01")
#' @param end_date End date (e.g. "2023-12-31")
#' @param roi Numeric vector of [minLon, minLat, maxLon, maxLat]
#' @param scale Resolution in meters (default is 30 for Landsat)
#' @return A SpatRaster object
#' @export

getLandsatData <- function(start_date, end_date, roi, scale = 30) {
  library(rgee)
  library(terra)
  
  ee_Initialize()
  
  ee_roi <- ee$Geometry$Rectangle(roi)
  
  collection <- ee$ImageCollection("LANDSAT/LC08/C02/T1_L2")$
    filterBounds(ee_roi)$
    filterDate(start_date, end_date)$
    map(function(img) {
      qa <- img$select("QA_PIXEL")
      mask <- qa$bitwiseAnd(1 < 3)$eq(0)  # Cloud bit = 0 (clear)
      img$updateMask(mask)
    })$
    median()
  
  
  # Get download URL
  url <- collection$getDownloadURL(list(
    region = ee_roi$coordinates(),
    scale = scale,
    format = "GeoTIFF"
  ))
  
  # Download the image to a temporary file
  temp_file <- tempfile(fileext = ".tif")
  download.file(url, temp_file, mode = "wb")
  
  # Read into R as a SpatRaster
  raster_img <- terra::rast(temp_file)
  return(raster_img)
}




#' Get Sentinel-2 Data from GEE with Cloud Filtering
#' 
#' @param roi Numeric vector of [minLon, minLat, maxLon, maxLat]
#' @param start_date Start date as string (YYYY-MM-DD)
#' @param end_date End date as string (YYYY-MM-DD)
#' @param cloud_perc Cloud cover threshold (0-100)
#' @param scale Scale/resolution in meters 10m for sentinel
#' @return A sentinel 2 image
#' @export


getSentinelData <- function(start_date, end_date, roi, scale = 10) {
  library(rgee)
  library(terra)
  
  ee_Initialize()
  
  ee_roi <- ee$Geometry$Rectangle(roi)
  
  # Sentinel-2 surface reflectance collection
  col <- ee$ImageCollection("COPERNICUS/S2_SR")$
    filterBounds(roi)$
    filterDate(start_date, end_date)$
    filter(ee$Filter$lt('CLOUDY_PIXEL_PERCENTAGE', cloud_perc))$
    map(function(img) {
      # Cloud masking using QA60
      qa <- img$select("QA60")
      mask <- qa$bitwiseAnd(1 < 10)$eq(0)$And(
        qa$bitwiseAnd(1 < 11)$eq(0)
      )
      img$updateMask(mask)
    })$
    median()
  
  # Get download URL
  urls <- col$getDownloadURL(list(
    region = ee_roi$coordinates(),
    scale = scale,
    format = "GeoTIFF"
  ))
  
  # Download the image to a temporary file
  tempFile <- tempfile(fileext = ".tif")
  download.file(url, tempFile, mode = "wb")
  
  # Read into R as a SpatRaster
  raster_imgg <- terra::rast(tempFile)
  return(raster_imgg)
} 


