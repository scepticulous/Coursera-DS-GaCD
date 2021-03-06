library("reshape2")

# Get the raw data: Create data subdir, download raw data and extract it
get_data <- function(){
  # download the data if the zip does not exist yet
  zip_name <- "getdata_projectfiles_UCI HAR Dataset.zip"

  old_wd <- getwd()
  if(!file.exists("./data")){
    print("creating data subdirectory")
    dir.create("./data")
  }
  setwd("./data")
    
  if(!file.exists("UCI HAR Dataset")){
    print("data directory missing")
    if(!file.exists(zip_name)){
      print("data archive missing. starting download")
      download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",zip_name,method="curl",quiet = T)
    }else{
      print("zip already present.skipping download")
    }
    print("unpacking dataset")
    unzip(zip_name, exdir = "./", setTimes = FALSE)
  }else{
    print("Data directory already present.Starting analysis")
  }
  setwd(old_wd)
}

load_and_merge_data <- function(){
  # read the test data set into one data frame
  test_x       <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
  test_y       <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
  test_subject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

  # read the train dataset into another data fram
  train_x       <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
  train_y       <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
  train_subject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

  # load the measurement labels from the second column 
  column_names   <- read.table("./data/UCI HAR Dataset/features.txt",stringsAsFactors = F)[,2]
  activity_names <- read.table("./data/UCI HAR Dataset/activity_labels.txt",stringsAsFactors = F)[,2]
  
  ##### create subject dataset
  subject_data <- rbind(test_subject, train_subject)
  colnames(subject_data) <- "subject"

  # merge datasets and assign proper column names
  x_data <- rbind(train_x,test_x)
  colnames(x_data) <- column_names
  
  ########### add the y values to the relevant dataset and label the column
  y_data <- rbind(train_y,test_y)
  y_data[,2] <- activity_names[y_data[,1]]
  
  full_data <- cbind(subject_data,y_data,x_data)
  colnames(full_data)[1:3] <- c("id","activity","activity_name")
  full_data

 }

# filter all the columns that contain mean or std values
filter_mean_and_std <- function(d){
  search <- grep("-mean|-std", colnames(d))
  d[,c(1,2,3,search)]
}

build_tidy_data <- function(input){
  # Compute the means, grouped by subject/label
  
  # dont use the activity id column
  input$activity <- NULL
  
  # calculate the mean of the data grouped by subject(id) and activity-name
  melted <- melt(input, id.var = c("id", "activity_name"))
  result <- dcast(melted , id + activity_name ~ variable, mean)
  result
}

# save the given data to the given filename
save_data <- function(data,filename){
  write.table(data, file=filename,row.name=FALSE)
}

run_analysis <- function(){
  get_data()
  merged_data <- load_and_merge_data()
  subset      <- filter_mean_and_std(merged_data)
  tidy_data   <- build_tidy_data(subset)
  save_data(tidy_data,"./data/tidy_data.txt")
  
}

# main function, that invokes all the sub routines
run_analysis()

