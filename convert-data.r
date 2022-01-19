#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

#### New R step #####

# It's installed already
#install.packages('plyr')
library('plyr')

PICRUStIn <- function(OTUtable, Hits, MissNames, OutputTable){
  otucounts <- read.delim(OTUtable, stringsAsFactors=TRUE, header = TRUE)
  otucounts<-otucounts[!names(otucounts) =="total"]
  newnames <- read.delim(Hits, header=F, stringsAsFactors=TRUE)
  if (file.info(MissNames)$size == 0) {
    test<-otucounts
    } else {
      missnames <- read.delim(MissNames, header=F, stringsAsFactors=TRUE)
      misses<-as.character(missnames$V1)
      todelete<-match(misses, otucounts[,1])
      test<-otucounts[-todelete,]
      newnames<-newnames[match(test[,1], newnames[,1]),]
      }
  test$NEW<-newnames$V2
  test<-test[-1]
  otucoll<-ddply(test, "NEW",numcolwise(sum))
  write.table(otucoll, file = OutputTable, sep = "\t", quote = F, row.names = F)
}

PICRUStIn(args[1], args[2], args[3], args[4])