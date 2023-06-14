## Visualizing schaefer400 NBS results for individualised and group Parc
# Plots dysconnectivity degree on brain
# Calculates and plots dysconnectivity grouped by network
# Code for plotting edges using brainconn is commented out, but can be included

# Make sure to change atlas choice accordingly 

#Script by Sidhant Chopra and Priscila Levi 

# setup
install.packages("remotes")
remotes::install_github("sidchop/brainconn")
library(brainconn)
library(ggseg)
library(ggplot2)
devtools::install_github("LCBC-UiO/ggsegSchaefer")
library(ggsegSchaefer)

# set your working directory
setwd("~/kg98/Priscila/GPIP_HCP-EP_clean/")

#read in Adj matrix - change for different parcellations!
adj_grp <-  read.table("adj_grp.txt") 
adj_ind <-  read.table("adj_ind.txt") 

#Visualise adj matrix
pheatmap::pheatmap(adj_grp, cluster_rows = F, cluster_cols = F)
pheatmap::pheatmap(adj_ind, cluster_rows = F, cluster_cols = F)

#update atlas to remove excluded regions
exclude <- scan("excludedROIs.txt")
schaefer100_n7_updated <- schaefer100_n7[-exclude,]
ROI_labels  <- schaefer100_n7_updated$`ROI.Name`


## Visualise edges in the brains
#very slow when theres lots edges!!
#brainconn(atlas = schaefer100_n7_updated,
#          conmat = adj_matrix, 
#          view = "top", 
#          edge.width = 0.2,
#          node.size = rowSums(adj_matrix)/100)

# View(schaefer100_n7_updated$network)
  
## Assign to networks for group-based
source("utils_lib/plotClassifiedEdges.R") 
source("utils_lib/makeNetworkMatrix2.R") 

id <- 8-as.numeric(factor(schaefer100_n7_updated$network))
labels <- unique(schaefer100_n7_updated$network)

PCE <- plotClassifiedEdges(adj = as.matrix(adj_grp),
                           ids =  id,
                           labels = labels)
makeNetworkMatrix2(PCE[[3]], PCE[[1]])

#save matrices
write.table(PCE[[1]], file="output/grp_network_mat.txt", row.names=FALSE, col.names=FALSE)
write.table(PCE[[3]], file="outpu/grp_proportion_mat.txt", row.names=FALSE, col.names=FALSE)


## Assign to networks for individualized
id <- 8-as.numeric(factor(schaefer100_n7_updated$network))
labels <- unique(schaefer100_n7_updated$network)

PCE <- plotClassifiedEdges(adj = as.matrix(adj_ind),
                           ids =  id,
                           labels = labels)
makeNetworkMatrix2(PCE[[3]], PCE[[1]])

#save matrices
write.table(PCE[[1]], file="output/ind_netwrk_mat.txt", row.names=FALSE, col.names=FALSE)
write.table(PCE[[3]], file="output/ind_proportion_mat.txt", row.names=FALSE, col.names=FALSE)

  
## Plot degree on brain

degree_ind <- rowSums(adj_ind)
data_ind <- as.data.frame(cbind(ROI_labels, degree_ind))
colnames(data_ind) <- c("region", "degree")
data_ind$degree <- as.numeric(data_ind$degree)

ggplot(data_ind) +
  geom_brain(atlas = schaefer7_100, 
             position = position_brain(hemi ~ side),
             aes(fill = degree_ind), 
             size = 1,      #line size
             colour="black") +  #line colour
  scale_fill_viridis_c() + #colour scale, can use any ggplot continuous scale_fill_* scales
  theme_void() + #removes all the background lines etc
  labs(title = "Degree of dysconnectivity", 
       subtitle = "individualized parcellation") 

degree_grp <- rowSums(adj_grp)
data_grp <- as.data.frame(cbind(ROI_labels, degree_grp))
colnames(data_grp) <- c("region", "degree")
data_grp$degree <- as.numeric(data_grp$degree)

ggplot(data_grp) +
  geom_brain(atlas = schaefer7_100, 
             position = position_brain(hemi ~ side),
             aes(fill = degree_ind), 
             size = 1,      #line size
             colour="black") +  #line colour
  scale_fill_viridis_c() + #colour scale, can use any ggplot continuous scale_fill_* scales
  theme_void() + #removes all the background lines etc
  labs(title = "Degree of dysconnectivity", 
       subtitle = "group-based parcellation") 
