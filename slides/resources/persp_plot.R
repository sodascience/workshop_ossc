f <- \(x, y) 0.1*x^3 + 0.2*x*y + 0.6*y^2 + 0.3*x^2*y
X <- seq(-2, 1, length.out = 60)
Y <- seq(-2, 1, length.out = 60)
Z <- outer(X, Y, f)

png("slides/fig/persp.png", 3000, 2000, res = 300)
persp(X, Y, Z, theta = 220, phi = 20, 
      xlab = "arousal", ylab = "perturbation", 
      zlab = "fear", col = "light seagreen", 
      shade = 0.9)
dev.off()
