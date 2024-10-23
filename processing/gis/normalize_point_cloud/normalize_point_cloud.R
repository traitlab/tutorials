library(lasR)


path_laz <- "20210528_sblz1_p4rtk/20210528_sblz1_p4rtk_pg.copc.laz"
path_dtm <- "20240429_sblz1z2_l2/20240429_sblz1z2_l2_dtm.tif"
output_path <- "20210528_sblz1_p4rtk/20210528_sblz1_p4rtk_pg_norm.laz"

# Processing steps
las <- reader_las(path_laz) # Read the las/laz/copc.laz
dtm <- load_raster(path_dtm) # Load DTM
normalization <- transform_with(dtm, operator = "-") # Normalize
write <- write_las(output_path) # Define output path

# Create and execute the pipeline
pipeline <- las + dtm + normalization + write
ans <- exec(pipeline, on = las$reader_las$filter, with = list(progress = TRUE))



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
    
    # Search for the file ending with '.copc.laz'
    file_name <- list.files(path = folder_path, pattern = ".copc.laz$", full.names = TRUE)
    
    # Ensure a file is found before proceeding
    if (length(file_name) == 1) {
      path_laz <- file_name # The path to the LAZ file
      
      # Generate output name by replacing '.copc.laz' with '_norm.laz'
      output_file <- gsub(".copc.laz$", "_norm.laz", basename(path_laz))
      output_path <- file.path(dirname(path_laz), output_file)
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
    
    # Processing steps
    las <- reader_las(path_laz) # Read the las/laz/copc.laz
    dtm <- load_raster(path_dtm) # Load DTM
    normalization <- transform_with(dtm, operator = "-") # Normalize
    write <- write_las(output_path) # Define output path
    
    # Create and execute the pipeline
    pipeline <- las + dtm + normalization + write
    ans <- exec(pipeline, on = las$reader_las$filter, with = list(progress = TRUE))
    
    # Print progress with count
    print(paste("Processed", output_path, "- Progress:", counter, "out of", total))
  }
}
end_time <- Sys.time()
end_time - start_time