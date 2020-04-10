#created by mtecim May 2019

#dowlanding necessary packages

library(e1071)
library(ISLR)
library(caret)
library (ROCR )

#Data is read

read_data<-read.csv("ICUPatients.csv")
#str(read_data)
#summary(read_data)


#Main features are assigned

Features<-c("ICU_Type", "Dest_Level_of_Care", "age", "sex", "LOS",
            "Initial_SOFA_Liver", "Initial_SOFA_Coagulation", "Initial_SOFA_Nerv","Initial_SOFA_Renal","Initial_SOFA_Respiratory","Initial_SOFA_Cardio",
            "Discharge_SOFA_Liver","Discharge_SOFA_Coagulation","Discharge_SOFA_Nerv","Discharge_SOFA_Renal","Discharge_SOFA_Respiratory","Discharge_SOFA_Cardio",
            "Max_SOFA_Liver","Max_SOFA_Coagulation","Max_SOFA_Nerv","Max_SOFA_Renal","Max_SOFA_Respiratory","Max_SOFA_Cardio",
            "Aver_SOFA_Liver","Aver_SOFA_Coagulation","Aver_SOFA_Nerv","Aver_SOFA_Renal","Aver_SOFA_Respiratory","Aver_SOFA_Cardio",
            "Var_SOFA_Liver","Var_SOFA_Coagulation","var_SOFA_Nerv","Var_SOFA_Renal","Var_SOFA_Respiratory","Var_SOFA_Cardio",
            "AdmitApache","Charlson_index","cvc_status","Type","disch_night","weekend","previous_ICU_stays","SIRS_48_hour","MV_24_hour"
            ,"death" )
#View(Features)
#View(read_data[Features])
#summary(read_data[Features])


#for checking missing values
#anyNA(read_data[Features])

#data cleaning and preapre features data  = main_df

#Main data frame is created
main_df<-feed_df[Features]
#summary(main_df)
#str(main_df)
#View(main_df)


#Dataslicing,K-Fold Cross Validation and Roc Curves


set.seed(1) 
#for creating rondom numbers assigned a seed number
folds <- cut(seq(1,nrow(main_df)),breaks=10,labels=FALSE)
#Perform 10 fold cross validation
#This method is used to make our work replicable

for(i in 1:10){
  #Segement your data by fold using the which() function 
  testIndexes <- which(folds==i,arr.ind=TRUE)
  
  testData <- main_df[testIndexes, ]
  #View(testData)
  #Test data is created 
  
  trainData <- main_df[-testIndexes, ]
  #View(testData)
  #Train data is created 

y = trainData$death
#Considering the death results of patient, we try to find a separator.

svmfit =svm  (y~. ,data= trainData, kernel ="radial", gamma =1,
              cost =1)
summary(svmfit)
#Primary model is built and its properties are summarized.


tuned_parameters <- tune.svm(death~., data = trainData, gamma = 10^(-5:-1), cost = 10^(-3:1))
summary(tuned_parameters )
#Tune.svm is a generic function tunes hyperparameters of statistical methods using a grid search over supplied parameter ranges.
#At the given parameter range tune.svm finds best parameters and performances.

fitted = predict(svmfit,testData,type="response")
#Predicting the model success into test data.

rocplot <- function (fitted,truth){
  predob = prediction (as.numeric(fitted),as.numeric(truth))
  perf = performance (predob, "tpr", "fpr")
  plot(perf)
  AUC = performance(predob,"auc")
  print(AUC@y.values)
  #Area under curve values are printed.

  
}
rocplot(fitted,testData$death)
#ROC Curves are printed.
}




"""
#caret slicing
#intrain <- createDataPartition(y = heart_df$V14, p= 0.7, list = FALSE)
#The “y” parameter takes the value of variable according to which data needs to be partitioned. In our case, target variable is at V14, so we are passing heart_df$V14 (heart data frame’s V14 column).


Parameters:
  SVM-Type:  eps-regression 
SVM-Kernel:  radial 
cost:  1 
gamma:  1 
epsilon:  0.1 


Number of Support Vectors:  12041


[[1]]
[1] 0.9809049

[[1]]
[1] 0.9797862

[[1]]
[1] 0.9885363

[[1]]
[1] 0.9892307

[[1]]
[1] 0.9875881

[[1]]
[1] 0.9879331

[[1]]
[1] 0.9871937

[[1]]
[1] 0.9924649

[[1]]
[1] 0.9867157

[[1]]
[1] 0.9946612



"""

