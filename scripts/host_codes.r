## INTERACTIVE ##

# LJ generate FIA code list for AP hosts

# for info on host species see "Amanita_phalloides_hosts.txt"

# load FIA taxonomy ------------------------------------------------------------

fiatax <- read.csv(file.path("indata", "final_raster_stack", "FIAtax_clean.csv"))


# species level ---------------------------------------------------------------

# set list of hosts
hostsp <- data.frame(Species = c("Carpinus betulus", "Quercus robur", "Castanea sativa", "Fagus sylvatica", "Corylus avellana", "Quercus garryana", "Quercus rubra", "Quercus coccinea", "Quercus palustris", "Pinus muricata", "Pseudotsuga menziesii", "Quercus agrifolia", "Lithocarpus densiflorus", "Arbutus menziesii", "Corylus cornuta var. californica"))

# match to codes
hostcodes <- fiatax[which(fiatax$latbi %in% hostsp$Species), "SPCD"]


# genus level ------------------------------------------------------------------

hostgen <- data.frame(Genus = c("Tilia", "Corylus", "Betula", "Carpinus", "Cedrus", "Tsuga", "Abies", "Picea", "Pinus", "Castanea", "Fagus", "Lithocarpus", "Quercus", "Pseudotsuga", "Arbutus"))

hostcodes <- fiatax[which(fiatax$Genus %in% hostgen$Genus), "SPCD"]


# family level -----------------------------------------------------------------

# load TPL family/genus table
tplf <- read.csv("/home/liam/Documents/MSc/analysis/misc/TPL_fam-gen/tpl_famgen.csv")

# match relevant genera to their families
hostfam <- unique(merge(hostgen, tplf, by="Genus"))

# remove 2nd Cedrus
hostfam <- hostfam[-which(hostfam$Family == "Meliaceae"),]

# isolate family list
hostfam <- data.frame(Family = unique(hostfam$Family))

# match to codes
hostcodes <- fiatax[which(fiatax$Family %in% hostfam$Family), "SPCD"]

