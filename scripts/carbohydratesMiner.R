
filePath <- "/home/carlos/data/miadn/genotyping/Adam Grant/diet_professional.pdf"

getCarbohydrates <- function(filePath){
        
        ## path to store text
        oPath <- "page1.txt"
        
        ## convert page 7 to text
        command <- paste("pdftotext '",filePath,
                         "' '",oPath,"' -f 1 -l 1 -layout",
                         sep="")
        system(command)
        
        ## Extract first page
        firstPage <- readLines(oPath,warn = FALSE)
        
        ## check report language
        language <- ifelse(sum(grepl("irth",firstPage))>0,"English","Spanish")
        
        ## extract client id
        clientLine <- firstPage[grep("MMX",firstPage)]
        clientId <- sub(".*MMX","",clientLine)
        clientId <- paste("MMX",clientId,sep="")
        
        ## list to store results
        genotyping <- list("clientId"=clientId)
        
        ###########################################################
        oPath <- "page7.txt"
        
        ## convert page 7 to text
        command <- paste("pdftotext '",filePath,
                         "' '",oPath,"' -f 7 -l 7 -layout",
                         sep="")
        system(command)
        
        ## Extract first page
        page <- readLines(oPath,warn = FALSE)
        
        ## getting carbohydrate sensitivity level
        level <- grep("You have a|Usted tiene una",page,value = TRUE)
        level <- sub(".*You have a|.*Usted tiene una","",level)
        level <- sub("sensitivity to carbohydrates.*|sensibilidad a los carbohidratos.*",
                     "",level)
        level <- gsub(" ","",level)
        genotyping <- c(genotyping,"level"=level)
        
        ## getting alleles
        snps <- c("ACE","PPARG","TCF7L2","ADRB2","FABP2")
        for (i in 1:length(snps)){
                ## find the line where the snp is
                snpline.index <- grep(snps[i],page)
                snpLine <- page[snpline.index]
                
                ## get the alleles field
                alleles <- substr(snpLine,60,80)
                alleles <- gsub(" ","",alleles)
                
                ## extract effect
                effect <- substr(snpLine,81,nchar(snpLine))
                effect <- gsub(" ","",effect)
                effect <- gsub("•","*",effect)
                
                ## storing results
                result <- list(alleles,effect)
                names(result) <- c(snps[i],paste(snps[i],"effect",sep=""))
                genotyping <- c(genotyping,result)
        }
        
        genotyping
}


#######################################################################################

carbohydratesMiner <- function(fPath){
        ## getting pdf paths from the fPath root dir
        fileNames <- list.files(fPath,recursive = TRUE)
        filePaths <- fileNames[grep("diet_pro",fileNames)]
        filePaths <- paste(fPath,"/",filePaths,sep="")
        
        ## store data
        data <- list()
        
        ## iterate over files
        for (path in filePaths) {
                print(path)
                res <- getCarbohydrates(path)
                res <- as.data.frame(res)
                data <- rbind(data,res)
                
        }
        
        ## massage results
        data <- data.frame(data,row.names = NULL)
        return(data)
} 
