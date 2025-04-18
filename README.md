# LSdownloader

Download Landsat & Sentinel-2 data from Google Earth Engine (GEE) into R

------------------------------------------------------------------------

## Overview

`LSdownloader` provides two simple R functions:

- `getLandsatData()` – Download cloud-masked Landsat 8 imagery  

- `getSentinelData()` – Download cloud-masked Sentinel-2 imagery

- The package leverages [`rgee`](https://github.com/r-spatial/rgee) and
  Google Earth Engine to fetch satellite imagery

- Using `ee_as_rast()` with Google Drive exports

- Loading directly into R as a `SpatRaster`.

------------------------------------------------------------------------

## Dependencies

The package automatically installs the following if missing:

- `rgee`
- `terra`
- `googledrive`
- `stars`, `future`, `sf`, `geojsonio` for raster handling

------------------------------------------------------------------------

## Installation

``` r
devtools::install_github("mariamansah/LSdownloader")
```

## Workflow

Load package

``` r
library(LSdownloader)
library(rgee)
ee_Initialize(drive = TRUE)
```

Authenticate with Earth Engine and Google Drive

## Example

``` r
library(LSdownloader)

my_roi <- c(-0.25, 5.50, 0.10, 5.70) #Accra  # Define your area of interest

landsat_img <- getLandsatData("2023-01-01", "2023-12-31", my_roi)
sentinel_img <- getSentinelData("2023-01-01", "2023-12-31", my_roi)

# Visualize Landsat RGB
plotRGB(landsat_img, r = 4, g = 3, b = 2, stretch = "lin")

# Visualize Sentinel RGB
plotRGB(sentinel_img, r = 4, g = 3, b = 2, stretch = "lin")
```

## Plots

<pre><code>```{r landsat-example, echo=FALSE, fig.align="center", out.width="100%"} library(LSdownloader) library(terra) library(rgee) ee_Initialize(drive = TRUE) aoi <- c(-0.25, 5.50, 0.10, 5.70) landsat_img <- getLandsatData("2023-01-01", "2023-12-31", roi = aoi) plotRGB(landsat_img, r = 4, g = 3, b = 2, stretch = "lin") ```</code></pre>
<pre><code>```{r sentinel-example, echo=FALSE, fig.align="center", out.width="100%"} library(LSdownloader) library(terra) library(rgee) ee_Initialize(drive = TRUE) aoi <- c(-0.25, 5.50, 0.10, 5.70) sentinel_img <- getSentinelData("2023-01-01", "2023-12-31", roi = aoi) plotRGB(sentinel_img, r = 4, g = 3, b = 2, stretch = "lin") ```</code></pre>

## Notes

- Downloaded files are temporary unless manually saved.
- Exports occur via Google Drive, so ensure adequate space & connection.

## Future Advances

getSentinelData() uses QA60 for masking for better accuracy possible
using COPERNICUS/S2_CLOUD_PROBABILITY.

## Author

Mariam Ansah Email: <mariam-naa-odey.ansah@stud-mail.uni-wuerzburg.de>
License: MIT
