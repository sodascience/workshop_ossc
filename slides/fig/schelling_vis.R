source("src/schelling.R")
set.seed(45)
init <- abm(c(.5, .5), iter = 0)

png("slides/fig/abm_init.png", 2000, 2000, res = 400)
par(mar = rep(0, 4))
plot_state(init$M)
dev.off()


set.seed(45)
three <- abm(c(.5, .5), iter = 3)
png("slides/fig/abm_three.png", 2000, 2000, res = 400)
par(mar = rep(0, 4))
plot_state(three$M)
dev.off()


set.seed(45)
nine <- abm(c(.5, .5), iter = 9)
png("slides/fig/abm_nine.png", 2000, 2000, res = 400)
par(mar = rep(0, 4))
plot_state(nine$M)
dev.off()



set.seed(45)
twenty <- abm(c(.5, .5), iter = 20)
png("slides/fig/abm_twenty.png", 2000, 2000, res = 400)
par(mar = rep(0, 4))
plot_state(twenty$M)
dev.off()


set.seed(45)
fifty <- abm(c(.5, .5), iter = 50)
png("slides/fig/abm_fifty.png", 2000, 2000, res = 400)
par(mar = rep(0, 4))
plot_state(fifty$M)
dev.off()

