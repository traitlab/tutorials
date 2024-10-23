library(terra)


path_dsm <- "20210528_sblz1_p4rtk/20210528_sblz1_p4rtk_dsm_highdis.cog.tif"
path_dtm <- "20240429_sblz1z2_l2/20240429_sblz1z2_l2_dtm.tif"
output_path <- "20210528_sblz1_p4rtk/20210528_sblz1_p4rtk_chm_highdis.tif"

# Processing steps
dsm <- rast(path_dsm) # Load DSM
dtm <- rast(path_dtm) # Load DTM

# Resample DTM to match the DSM's resolution and extent
dtm_resampled <- resample(dtm, dsm, method = "bilinear")

# Align the extent of both rasters (crop to common extent)
ext_common <- intersect(ext(dsm), ext(dtm_resampled))
dsm_cropped <- crop(dsm, ext_common)
dtm_cropped <- crop(dtm_resampled, ext_common)

# Subtract DTM from DSM to get CHM
chm <- dsm_cropped - dtm_cropped

# Write the CHM raster to output
writeRaster(chm, output_path, overwrite=TRUE)



#### Example with 2021_sbl_cloutier data and loop ------------------------------
# Define the list of dates
dates <- c("20210528", "20210617", "20210721", "20210818", "20210902", "20210928", "20211007")

# Define the different zones
zones <- c("sblz1", "sblz2", "sblz3")

# Initialize a counter
start_time <- Sys.time()
counter <- 0
total <- length(dates) * length(zones) # Total number of iterations

# Iterate over each date and zone
for (date in dates) {
  for (zone in zones) {
    # Increment the counter
    counter <- counter + 1
    
    # Define the folder path
    folder_path <- paste0(date, "_", zone, "_p4rtk/")
    
    # Search for all files containing 'dsm_highdis'
    file_name <- list.files(path = folder_path, pattern = "dsm_highdis", full.names = TRUE)

    # Ensure a file is found before proceeding
    if (length(file_name) == 1) {
      path_dsm <- file_name # The path to the DSM file
    } else {
      print(paste("No file or multiple files found in", folder_path, "for", date, zone))
      next # Skip to the next iteration if no file or multiple files are found
    }
    
    # Set DTM path depending on the zone
    if (zone == "sblz1" || zone == "sblz2") {
      path_dtm <- "20240429_sblz1z2_l2/20240429_sblz1z2_l2_dtm.tif"
    } else if (zone == "sblz3") {
      path_dtm <- "20240429_sblz3_l2/20240429_sblz3_l2_dtm.tif"
    }
    
    # Set up output path
    output_path <- paste0(date, "_", zone, "_p4rtk/", date, "_", zone, "_p4rtk_chm.tif")
    
    # Processing steps
    dsm <- rast(path_dsm) # Load DSM
    dtm <- rast(path_dtm) # Load DTM
    
    # Resample DTM to match the DSM's resolution and extent
    dtm_resampled <- resample(dtm, dsm, method = "bilinear")
    
    # Align the extent of both rasters (crop to common extent)
    ext_common <- intersect(ext(dsm), ext(dtm_resampled))
    dsm_cropped <- crop(dsm, ext_common)
    dtm_cropped <- crop(dtm_resampled, ext_common)
    
    # Subtract DSM and DTM to get CHM
    chm <- dsm_cropped - dtm_cropped
    
    # Write the CHM raster to output
    writeRaster(chm, output_path, overwrite=TRUE)

    # Print progress with count
    print(paste("Processed", output_path, "- Progress:", counter, "out of", total))
  }
}
end_time <- Sys.time()
end_time - start_time