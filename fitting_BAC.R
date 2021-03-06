library(BAC)
library(ggplot2)
library(glmnet)

data(toyData)

exp <- toyData[, 2]
out <- toyData[, 1]
covs <- toyData[, - c(1, 2)]
num_cov <- ncol(covs)


# Lasso:

p.fac <- c(0, 0, rep(1, num_cov))
des_mat <- cbind(1, exp, covs)

las_mod <- cv.glmnet(x = des_mat, y = out, penalty.factor = p.fac)
las_mod <- glmnet(x = des_mat, y = out, lambda = las_mod$lambda.min,
                  penalty.factor = p.fac)
round(as.numeric(las_mod$beta)[2 : 11], 4)



# BAC.

# (Setting omega = 1 does not use the exposure model to inform adjustment)
omega <- 5000

set.seed(1234)
bac <- BAC(X = exp, Y = out, D = covs, Nsims = 1000, chains = 3, omega = omega)
bac <- BurnThin(bac, burn = 200, thin = 2)
  

plot_data <- data.frame(covar = rep(1 : num_cov, 2),
                        model = rep(c('Exp', 'Out'), each = num_cov),
                        inc_prob = as.numeric(t(apply(bac$alphas, c(1, 4), mean))))
plot_data <- subset(plot_data, covar <= 15)

plot_data$covar <- factor(plot_data$covar, levels = unique(plot_data$covar))

ggplot(data = plot_data, aes(x = covar, y = inc_prob, fill = model)) +
  geom_bar(stat = "identity", position = position_dodge(), width = 0.2)

mean(bac$coefs[2, , , 2])
quantile(bac$coefs[2, , , 2], probs = c(0.025, 0.975))



# Model with highest posterior weight:

post_models <- ModelWeights(bac, model = 'Outcome')

apply(unique_alpha, 2, sum)
apply(unique_alpha, 2, function(x) sum(1 - x))
with(unique_alpha, sum(number_times == 1))
with(unique_alpha, max(proportion))




