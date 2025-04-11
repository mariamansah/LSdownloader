library(reticulate)
use_python("C:/Users/mariam/anaconda3/envs/rgee/python.exe", required = TRUE)


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

download_landsat_raster <- function(start_date, end_date, roi, scale = 30) {
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

