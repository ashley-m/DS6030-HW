library(adabag)

control_params <- rpart.control(maxdepth = 1)

# Fit AdaBoost model in parallel
set.seed(666)
ada_models <- foreach(i = 1:16, .packages = 'adabag') %dopar% {
  boosting(Survived ~ Class + Sex + Age + Fare + sibsp + parch + Joined, 
           data = titanic_train, 
           boos = TRUE, 
           mfinal = 13, 
           control = control_params)
}

# Combine models sequentially
ada_model <- Reduce(combine_models, ada_models)

stopCluster(cl)
registerDoSEQ()