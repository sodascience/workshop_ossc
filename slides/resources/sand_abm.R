child_a <- \(sand) sand + runif(1, 0, 0.1)
child_b <- \(sand) if (sand > 0.95) runif(1, 0.05, 0.2) else sand

sand_vec <- numeric(100)
sand_vec[1] <- 0.5
for (i in 2:100) {
  sand_vec[i] <- child_a(sand_vec[i-1])
  sand_vec[i] <- child_b(sand_vec[i])
}

png("slides/fig/sand.png", 3000, 2000, res = 400)
plot(sand_vec, type = "l", bty = "L", col = "seagreen", xlab = "Time", ylab = "Sand in bucket (l)")
points(sand_vec, pch = 21, bg = "black", cex = 0.4)
dev.off()
