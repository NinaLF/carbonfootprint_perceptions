### Carbon footprint perceptions
# preparation script, pre-processing


# load packages
library("lubridate")
library(readxl)
library(psych)
library(tidyverse); library(ggplot2)
library(rcompanion)
library(broom)
library(vegan)
library(sjPlot) # for tab_model
library(lmerTest); library(lme4)
library(sjlabelled)
library(sjmisc)
library(emmeans)
library("rmcorr")
library(Hmisc)
library(corrplot)
library(GPArotation)
library(ircor)

set_theme(base=theme_classic())

### wave 2 data set from Qualtrics
data_raw0 <- read.csv("carbon_footprint_data.csv")
data_raw1 <- data_raw0[,-c(4:7,10:23, 25,26,33:37)]
data_raw1.1 <- data_raw1 %>% 
  select(!c(ends_with("subsession") , ends_with("round_number"), ends_with("id_in_group") , ends_with("player.role"),ends_with("player.payoff") ) )



# Define a list of column indices and the number of characters to remove for each set of columns
column_changes <- list(
  columns_6_to_11 = list(indices = 6:11, remove_chars = 1:21),
  columns_12_to_59 = list(indices = 12:59, remove_chars = 1:25),
  columns_60_to_68 = list(indices = 60:68, remove_chars = 1:47),
  columns_69_to_86 = list(indices = 69:86, remove_chars = 1:28)
  
  
)

data <- data_raw1.1

## I am currently too incapble of looping through this

# Specify the range of columns you want to modify
columns_to_modify <- 6:11
# Loop through the specified columns and remove the first 20 characters from their names
for (col_index in columns_to_modify) {
  col_name <- colnames(data)[col_index]
  new_col_name <- substr(col_name, 22, nchar(col_name))
  colnames(data)[col_index] <- new_col_name
}
columns_to_modify <- 12:38
for (col_index in columns_to_modify) {
  col_name <- colnames(data)[col_index]
  new_col_name <- substr(col_name, 17, nchar(col_name))
  colnames(data)[col_index] <- new_col_name
}
columns_to_modify <- 39:59
for (col_index in columns_to_modify) {
  col_name <- colnames(data)[col_index]
  new_col_name <- substr(col_name, 17, nchar(col_name))
  colnames(data)[col_index] <- new_col_name
}
columns_to_modify <- 60:68
for (col_index in columns_to_modify) {
  col_name <- colnames(data)[col_index]
  new_col_name <- substr(col_name, 36, nchar(col_name))
  colnames(data)[col_index] <- new_col_name
}
columns_to_modify <-69:86
for (col_index in columns_to_modify) {
  col_name <- colnames(data)[col_index]
  new_col_name <- substr(col_name, 29, nchar(col_name))
  colnames(data)[col_index] <- new_col_name
}
names(data)

## total co2 footprint reported in sample
ggplot(data, aes(x=total_co2)) +
  geom_boxplot() +
  theme_minimal()

## prepping policy support
data$climate_change_concern1 <- -data$climate_change_concern1+7
data$climate_change_concern2 <- -data$climate_change_concern2+7
data$climate_change_concern3 <- -data$climate_change_concern3+7
data$climate_change_concern4 <- -data$climate_change_concern4+7

data <- data %>% 
  mutate(cc_concern.mean=rowMeans(cbind(climate_change_concern1,climate_change_concern2,climate_change_concern3,climate_change_concern4) ),
         policy.support.total=rowMeans(cbind(policy_item1,policy_item3,policy_item5, policy_item8,policy_item10,policy_item11 ,
                                             policy_item2,policy_item4,policy_item6, policy_item7,policy_item9,policy_item12 )) ) 
data$conservative_liberal.binary <- ifelse(data$conservative_liberal >5, "right-leaning", "left-leaning")
data2 <- data %>%
  mutate(policy.car=rowMeans(cbind(policy_item1,policy_item2)),
         policy.flying=rowMeans(cbind(policy_item3,policy_item4)),
         policy.RE=rowMeans(cbind(policy_item5,policy_item6)),
         policy.meat=rowMeans(cbind(policy_item7,policy_item8)),
         policy.recycle=rowMeans(cbind(policy_item9,policy_item10)),
         policy.regional_food=rowMeans(cbind(policy_item11,policy_item12)),
         policies.subsidies=rowMeans(cbind(policy_item1,policy_item3,policy_item5, policy_item8,policy_item10,policy_item11 )),
         policies.taxes=rowMeans(cbind(policy_item2,policy_item4,policy_item6, policy_item7,policy_item9,policy_item12 ))
  ) %>%
  rename( footprint.regional=footprint_1,
          footprint.recycling=footprint_2,
          footprint.diet=footprint_3,
          footprint.travel.car=footprint_4,
          footprint.travel.bus=footprint_5,
          footprint.travel.train=footprint_6,
          footprint.flying=footprint_7,
          footprint.electricity=footprint_8,
          ) %>%
  rename(policy.car.sub = policy_item1,
         policy.car.tax = policy_item2,
         policy.flying.sub = policy_item3,
         policy.flying.tax = policy_item4,
         policy.RE.sub = policy_item5,
         policy.RE.tax = policy_item6,
         policy.meat.tax = policy_item7,
         policy.meat.sub = policy_item8,
         policy.recycle.sub =policy_item10,
         policy.recycle.tax = policy_item9,
         policy.regional_food.sub = policy_item11,
         policy.regional_food.tax = policy_item12
         
  )


# prepping reported behavior
data2$footprint.regional <- factor(data2$footprint.regional, levels=c(1,2,3,4,5),
                                   labels=c(0, -0.11, -0.22, -0.33, -0.44))
data2$footprint.regional <- as.character(data2$footprint.regional)
data2$footprint.regional <- as.numeric(data2$footprint.regional)
data2$footprint.recycling <- factor(data2$footprint.recycling, levels=c("1","2"),
                                   labels=c(-0.0575, 0))
data2$footprint.recycling <- as.character(data2$footprint.recycling)
data2$footprint.recycling <- as.numeric(data2$footprint.recycling)
data2$footprint.diet <- factor(data2$footprint.diet, levels=c(1,2,3,4,5,6),
                                   labels=c(0.955, 1.053 , 1.431 , 1.234, 3.160,  2.282 ))
data2$footprint.diet <- as.character(data2$footprint.diet)
data2$footprint.diet <- as.numeric(data2$footprint.diet)
data2$footprint.travel.car <- factor(data2$footprint.travel.car, levels=c(1,2,3,4,5,6),
                                     labels=c(4.0896,  3.27168, 2.0414, 1.0872, 0.2726, 0.0  )  )
data2$footprint.travel.car <- as.character(data2$footprint.travel.car)
data2$footprint.travel.car <- as.numeric(data2$footprint.travel.car)
data2$footprint.travel.bus <- factor(data2$footprint.travel.bus, levels=c(1,2,3,4,5,6),
                                     labels=c(2.3328, 1.8662, 1.11645,  0.6201, 0.1555, 0.0  )  )
data2$footprint.travel.bus <- as.character(data2$footprint.travel.bus)
data2$footprint.travel.bus <- as.numeric(data2$footprint.travel.bus)
data2$footprint.travel.train <- factor(data2$footprint.travel.train, levels=c(1,2,3,4,5,6),
                                     labels=c(1.0944,0.8755, 0.5463,  0.2909,0.0729, 0.0  )  )
data2$footprint.travel.train <- as.character(data2$footprint.travel.train)
data2$footprint.travel.train <- as.numeric(data2$footprint.travel.train)
data2$footprint.flying <- factor(data2$footprint.flying, levels=c(1,2,3,4,5,6, 7),
                                       labels=c( 13.48,  6.74, 3.59, 2.07, 0.90,  0.36,  0.0  )  )
data2$footprint.flying <- as.character(data2$footprint.flying)
data2$footprint.flying <- as.numeric(data2$footprint.flying)
data2$footprint.electricity <- factor(data2$footprint.electricity, levels=c(1,2,3,4),
                                 labels=c( 0.1031 ,  0.6988837, 1.294697, 1.294697  )  )
data2$footprint.electricity <- as.character(data2$footprint.electricity)
data2$footprint.electricity <- as.numeric(data2$footprint.electricity)

# full data
write.csv(data2, "data/data.all_variables.csv")



### Analyzing policy
data.policies <- data %>% select(participant.label, age, gender, income, education, conservative_liberal, conservative_liberal.binary, cc_concern.mean, starts_with("policy"))
data.policies <- na.omit(data.policies)
data.policies.long <- pivot_longer(data.policies, policy_item1:policy_item12, names_to = "policy", values_to = "support")
data.policies.long$policy <- factor(data.policies.long$policy,
                                  levels=c("policy_item1", "policy_item10" ,"policy_item11" ,"policy_item12",  "policy_item2",  "policy_item3",
                                           "policy_item4" , "policy_item5" , "policy_item6",  "policy_item7" , "policy_item8",  "policy_item9"),
                                  labels=c("expand public transport", "expand recycling", "subsidies regional food", "taxes imported food", "ban diesel&petrol cars", "subsidies alternative flying",
                                           "taxes air travel", "subsidies RE projects", "electricity price peak times", "taxes red meat", "subsidies low emission foods", "taxes non-recylabes"))
data.policies.long$policy2 <- factor(data.policies.long$policy,
                                    levels=c("subsidies alternative flying", "expand public transport", "subsidies RE projects", "subsidies low emission foods","subsidies regional food", "expand recycling",   
                                             "taxes air travel","ban diesel&petrol cars",  "electricity price peak times", "taxes red meat", "taxes imported food",   "taxes non-recylabes"))

data.policies.long$type <- rep(c("subsidy","cost","subsidy" ,"cost", "subsidy", "cost", "cost", "subsidy", "cost","subsidy","subsidy","cost"), 200)
data.policies.long$support.f <- factor(data.policies.long$support)

write.csv(data.policies.long, "data/data.policies.long.csv")



## basics, reliability etc
psych::alpha(data.policies[c("policy_item1", "policy_item10" ,"policy_item11" ,  "policy_item3", "policy_item5" , "policy_item8", 
                             "policy_item12",  "policy_item2", "policy_item4" , "policy_item6",  "policy_item7" , "policy_item9")])

# alpha = 0.88
# "subscaling" subsidies = 0.79
psych::alpha(data.policies[c("policy_item1", "policy_item10" ,"policy_item11" ,  "policy_item3", "policy_item5" , "policy_item8")])
# "subscaling" taxes = 0.89
psych::alpha(data.policies[c( "policy_item12",  "policy_item2", "policy_item4" , "policy_item6",  "policy_item7" , "policy_item9")])



corr <- data.policies %>% select(starts_with("policy")) %>%
  rename(expand.public_transport=policy_item1,
         expand.recycling =policy_item10,
         subsidy.regional_food = policy_item11,
         taxes.non_regional_food = policy_item12,
         ban.conv_cars = policy_item2,
         subsidy.flying_alternative = policy_item3,
         taxes.flying = policy_item4,
         subsidy.renwable_energy = policy_item5,
         cost.electricity_peak = policy_item6,
         taxes.meat =policy_item7,
         subsidy.low_emission_food = policy_item8,
         taxes.non_recyclables = policy_item9
         )

coef2 <- rcorr(as.matrix(corr))

corrplot(coef2$r, type="upper", order="hclust", 
         p.mat = coef2$P, sig.level = 0.05, insig = "blank")


### efa
Nfacs <- 2  # This is for four factors. You can change this as needed.
fit <- factanal(corr, Nfacs, rotation="varimax")

print(fit, digits=2, cutoff=0.3, sort=TRUE)
load <- fit$loadings[,1:2]
plot(load,type="n") # set up plot
text(load,labels=names(corr),cex=.7)

loads <- fit$loadings
fa.diagram(loads)

### cfa 1  factor
## covariance matrix
study1_cov <- cov(corr )
study1_cov


# specify model
study1_model  <- '
policy.support =~ expand.public_transport + ban.conv_cars + subsidy.flying_alternative + taxes.flying + subsidy.renwable_energy + cost.electricity_peak + taxes.meat + 
subsidy.low_emission_food + taxes.non_recyclables + expand.recycling + subsidy.regional_food + taxes.non_regional_food
'
# analyze model
fit_study1 <- cfa(model=study1_model, data=corr, sample.cov=study1_cov, sample.nobs= nrow(corr), estimator="wlsmv")

#show results
#summary(fit_study1, fit.measures=TRUE, standardized=TRUE)
print(fitMeasures(fit_study1, c("chisq", "df", "pvalue", "cfi", "rmsea", "nfi"),
                  output = "text"), add.h0 = TRUE)


##cfa 2 factors
study1_model2  <- '
policy.support.subsidy =~ subsidy.flying_alternative +subsidy.renwable_energy + subsidy.low_emission_food + expand.recycling + subsidy.regional_food
policy.support.costs =~ expand.public_transport + ban.conv_cars +taxes.flying + cost.electricity_peak + taxes.meat + taxes.non_recyclables + taxes.non_regional_food
'
# analyze model
fit_study1.2 <- cfa(model=study1_model2, data=corr, sample.cov=study1_cov, sample.nobs= nrow(corr), estimator="wlsmv")

#show results
#summary(fit_study1.3, fit.measures=TRUE, standardized=TRUE)
print(fitMeasures(fit_study1.2, c("chisq", "df", "pvalue", "cfi", "rmsea", "nfi"),
                  output = "text"), add.h0 = TRUE)




## omega

omega(corr,n.obs=200,title = "Omega")
omega(corr,n.obs=200,title = "Omega", nfactors = 2)



### carbon footprint perceptions
data.perceptions <- data %>% select(participant.label, age, gender, income, education, conservative_liberal, conservative_liberal.binary, cc_concern.mean, total_co2,ends_with("rating0"))
data.perceptions <- na.omit(data.perceptions)
data.perceptions.long1 <- pivot_longer(data.perceptions,'1.player.rating0':'16.player.rating0' , names_to = "type", values_to = "rating")
data.perceptions.long1$type <- substr(data.perceptions.long1$type, 1, 2)

data.perceptions2 <- data %>% select(participant.label,  ends_with("vignetteNumber"))
data.perceptions.long2 <- pivot_longer(data.perceptions2,'1.player.vignetteNumber':'16.player.vignetteNumber' , names_to = "type", values_to = "vignette")
data.perceptions.long2$type <- substr(data.perceptions.long2$type, 1, 2)
data.perceptions.long2$diet <- rep(0, nrow(data.perceptions.long2))
data.perceptions.long2$flying <- rep(0, nrow(data.perceptions.long2))
data.perceptions.long2$electricity <- rep(0, nrow(data.perceptions.long2))
data.perceptions.long2$regional <- rep(0, nrow(data.perceptions.long2))
data.perceptions.long2$recycling <- rep(0, nrow(data.perceptions.long2))
data.perceptions.long2$commute <- rep(0, nrow(data.perceptions.long2))

data.perceptions.long2$vignette <- data.perceptions.long2$vignette+1
data.perceptions.long2$diet <- factor(ifelse(data.perceptions.long2$vignette %in% c(3, 4, 8, 10,11,12,15,16), 2, 1))
data.perceptions.long2$electricity <- factor(ifelse(data.perceptions.long2$vignette %in% c(5,7 ,8, 11,13,14,15,16), 2, 1))
data.perceptions.long2$recycling <- factor(ifelse(data.perceptions.long2$vignette %in% c(3,4,5,6,7,9,10,15,16 ), 2, 1))
data.perceptions.long2$regional <- factor(ifelse(data.perceptions.long2$vignette %in% c(2, 3,6,7,8,12,13,16 ), 2, 1))
data.perceptions.long2$commute <- factor(ifelse(data.perceptions.long2$vignette %in% c(2, 4,7,9,11, 12,14,16 ), 2, 1))
data.perceptions.long2$flying <- factor(ifelse(data.perceptions.long2$vignette %in% c(6,9,10, 12,13,14,15,16 ), 2, 1))

#1['diet_image_1', 'household_image_1', 'recycling_image_1', 'regional_image_1', 'commute_image_1', 'vacation_image_1'],
#2['diet_image_1', 'household_image_1', 'recycling_image_1', 'regional_image_2', 'commute_image_2', 'vacation_image_1'],
#3['diet_image_2', 'household_image_1', 'recycling_image_2', 'regional_image_2', 'commute_image_1', 'vacation_image_1'],
#4['diet_image_2', 'household_image_1', 'recycling_image_2', 'regional_image_1', 'commute_image_2', 'vacation_image_1'],
#5['diet_image_1', 'household_image_2', 'recycling_image_2', 'regional_image_1', 'commute_image_1', 'vacation_image_1'],
#6['diet_image_1', 'household_image_1', 'recycling_image_2', 'regional_image_2', 'commute_image_1', 'vacation_image_2'],
#7['diet_image_1', 'household_image_2', 'recycling_image_2', 'regional_image_2', 'commute_image_2', 'vacation_image_1'],
#8['diet_image_2', 'household_image_2', 'recycling_image_1', 'regional_image_2', 'commute_image_1', 'vacation_image_1'],
#9['diet_image_1', 'household_image_1', 'recycling_image_2', 'regional_image_1', 'commute_image_2', 'vacation_image_2'],
#10['diet_image_2', 'household_image_1', 'recycling_image_2', 'regional_image_1', 'commute_image_1', 'vacation_image_2'],
#11['diet_image_2', 'household_image_2', 'recycling_image_1', 'regional_image_1', 'commute_image_2', 'vacation_image_1'],
#12['diet_image_2', 'household_image_1', 'recycling_image_1', 'regional_image_2', 'commute_image_2', 'vacation_image_2'],
#13['diet_image_1', 'household_image_2', 'recycling_image_1', 'regional_image_2', 'commute_image_1', 'vacation_image_2'],
#14['diet_image_1', 'household_image_2', 'recycling_image_1', 'regional_image_1', 'commute_image_2', 'vacation_image_2'],
#15['diet_image_2', 'household_image_2', 'recycling_image_2', 'regional_image_1', 'commute_image_1', 'vacation_image_2'],
#16['diet_image_2', 'household_image_2', 'recycling_image_2', 'regional_image_2', 'commute_image_2', 'vacation_image_2']


data.perceptions.total <- merge(data.perceptions.long1, data.perceptions.long2, by=c("participant.label","type"))
data.perceptions.total <- data.perceptions.total %>% filter(!gender=="Prefer not to answer/ diverse")

data.perceptions.total$flying <- factor(data.perceptions.total$flying, 
                                        levels=c(1,2), labels=c("takes train (does not fly)", "flies 2/year"))
data.perceptions.total$diet <- factor(data.perceptions.total$diet, 
                                        levels=c(1,2), labels=c("vegetarian", "meat-based"))
data.perceptions.total$electricity <- factor(data.perceptions.total$electricity, 
                                     levels=c(1,2), labels=c("100% renewable energy supply", "mixed energy supply"))
data.perceptions.total$commute <- factor(data.perceptions.total$commute, 
                                     levels=c(1,2), labels=c("take the bike", "takes the bus"))
data.perceptions.total$regional <- factor(data.perceptions.total$regional, 
                                         levels=c(1,2), labels=c("only regional", "regional and imported"))
data.perceptions.total$recycling <- factor(data.perceptions.total$recycling, 
                                          levels=c(1,2), labels=c("recycles", "does not recycle"))


write.csv(data.perceptions.total, "data/data.perceptions.total.csv")



#### individual regression weights

## beta weights
model.perceptions.weights <- lmer(rating ~ flying + diet + electricity + commute + regional + recycling + (1|participant.label) +
                            (1 + flying + diet + electricity + commute + regional + recycling | participant.label)  + (1|vignette),
                          data=data.perceptions.total)
tab_model(model.perceptions.weights)
AgentsModelH1 <- coef(model.perceptions.weights)$participant.label
Model_H1 <- coef(model.perceptions.weights)

Model_H1Agents.waves <- cbind(rownames(AgentsModelH1),AgentsModelH1)
colnames(Model_H1Agents.waves)[colnames(Model_H1Agents.waves) == "rownames(Model_H1Agents.waves)"] <- "participant.label"
Model_H1Agents.waves <- Model_H1Agents.waves %>%
  rename(participant.label = "rownames(AgentsModelH1)" )


data.id <- data2 %>% 
  select(participant.label, gender, age, income, education, cc_concern.mean, total_co2, conservative_liberal.binary, conservative_liberal ,starts_with("footptint"),
        starts_with("policy.") ,
         footprint.electricity, footprint.regional, footprint.recycling, footprint.diet, footprint.travel.car, footprint.travel.bus, footprint.travel.train, footprint.flying
         )  %>%
  mutate(footprint.public.transport = rowMeans(cbind(footprint.travel.train, footprint.travel.bus) ))

data.regression.weights <- merge(Model_H1Agents.waves, data.id, by=c("participant.label")) 

data.regression.weights <- data.regression.weights %>%
  rename(flying.weight = 'flyingflies 2/year',
         diet.weight = 'dietmeat-based',
         electricity.weight= 'electricitymixed energy supply' ,
         commute.weight = 'commutetakes the bus',
         recycling.weight='recyclingdoes not recycle',
         regional.weight = 'regionalregional and imported')


#save
write.csv(data.regression.weights, "data/data.regression.weights.new.csv")




### regression weights visually
data.regression.weights.long <-  pivot_longer(data.regression.weights,flying2:recycling2, names_to = "behavior", values_to = "regression.weight" )

data.regression.weights.long$behavior.label <- factor(data.regression.weights.long$behavior, 
                                                levels=c("flying2", "diet2", "electricity2" ,"regional2", "commute2","recycling2" ) ,
                                                labels=c("train vs. flying 2/year", "diet vegetarian vs. omnivore", "100% RE vs. mixed",
                                                         "regional only vs imported food", "commute by bus vs. bike", "recycling vs. not")) 

ggplot(data.regression.weights.long, aes(x=reorder(behavior.label,-regression.weight), y=regression.weight, color=behavior.label)) +
  geom_boxplot() + 
  # facet_grid(conservative_liberal.binary~.) +
  theme_minimal() +
  theme(axis.title  = element_text(size = 14), 
        axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size=14, angle=90 ),
        strip.text = element_text(size=14),
        legend.position = "none")  +
  scale_color_viridis_d() + labs(fill=NULL)
  


### accuracy
data.accuracy <- data.perceptions.total 
data.accuracy$actual.ranking <- data.accuracy$vignette
# 1 und 2 sind 1 und 2
data.accuracy$actual.ranking[data.accuracy$actual.ranking==3] <- 4
# 4 is 4data.accuracy$actual.ranking[data.accuracy$actual.ranking==5] <- 3
data.accuracy$actual.ranking[data.accuracy$actual.ranking==6] <- 4
data.accuracy$actual.ranking[data.accuracy$actual.ranking==7] <- 5
data.accuracy$actual.ranking[data.accuracy$actual.ranking==8] <- 7
data.accuracy$actual.ranking[data.accuracy$actual.ranking==9] <- 4
data.accuracy$actual.ranking[data.accuracy$actual.ranking==10] <- 6
data.accuracy$actual.ranking[data.accuracy$actual.ranking==11] <- 7
data.accuracy$actual.ranking[data.accuracy$actual.ranking==14] <- 7
data.accuracy$actual.ranking[data.accuracy$actual.ranking==12] <- 8
data.accuracy$actual.ranking[data.accuracy$actual.ranking==13] <- 7
data.accuracy$actual.ranking[data.accuracy$actual.ranking==15] <- 9
data.accuracy$actual.ranking[data.accuracy$actual.ranking==16] <- 10

table(data.accuracy$actual.ranking)

ggplot(data.accuracy, aes(x=actual.ranking, y=rating)) +
  geom_jitter() +
  theme_minimal()


cor.test(data.accuracy$actual.ranking, data.accuracy$rating, method="spearman")
tau_b(data.accuracy$actual.ranking, data.accuracy$rating)

accuracy.estimates <- data.accuracy %>% 
  nest(data = -participant.label) %>%
  mutate(cor=map(data,~cor.test(.x$actual.ranking, .x$rating, method = "spearman"))) %>%
  mutate(tidied = map(cor, tidy)) %>% 
  unnest(tidied) %>% 
  select(-data, -cor)
write.csv(data.accuracy.score, "data/data.accuracy.score.csv")

data.accuracy.score <- merge(data, accuracy.estimates, by="participant.label")

model.accuracy <- lm(estimate ~ age + gender + education + 
                       cc_concern.mean + conservative_liberal + total_co2,
                       data=data.accuracy.score)
summary(model.accuracy)
tab_model(model.accuracy)

plot_model(model.accuracy, terms=c("total_co2"), type="pred")


ggplot(data.accuracy.score, aes(x=total_co2, y=estimate)) +
  geom_point() +
  theme_minimal()


model.support.accuracy <- lm(policy.support.total ~ estimate+
                              age + gender + education + income +
                              cc_concern.mean ,
                            data=data.accuracy.score)
tab_model(model.support.accuracy)

model.behavior.accuracy <- lm(total_co2 ~ estimate+
                               age + gender + education + income +
                               cc_concern.mean,
                             data=data.accuracy.score)
tab_model(model.behavior.accuracy)

ggplot(data.accuracy.score, aes(x=estimate)) +
  geom_density() +
  theme_minimal()


## with tau


accuracy.estimates.tau <- data.accuracy %>% 
  nest(data = -participant.label) %>%
  mutate(cor.tau=map(data,~tau_b(.x$actual.ranking, .x$rating))) %>%
  select(cor.tau, participant.label)

data.accuracy.score2 <- merge(data, accuracy.estimates.tau, by="participant.label")
data.accuracy.score2$cor.tau <- as.numeric(data.accuracy.score2$cor.tau)
data.accuracy.score2$rel_cc_concern.mean <- scale(data.accuracy.score2$cc_concern.mean)[,1]
data.accuracy.score2$rel_cc_concern.mean.f <- cut(data.accuracy.score2$rel_cc_concern.mean, breaks=c(-3, -1, 0, 2))
data.accuracy.score2$rel_cc_concern.mean.f <- factor(data.accuracy.score2$rel_cc_concern.mean.f ,
                                                   levels=c("(-3,-1]" , "(-1,0]",   "(0,2]" ) ,
                                                   labels=c("-1", "0", "1"))

data.accuracy.score2$rel_cor.tau <- scale(data.accuracy.score2$cor.tau)[,1]
data.accuracy.score2$rel_cor.tau.f <- cut(data.accuracy.score2$rel_cor.tau, breaks=c(-5, -1, 0, 2))
data.accuracy.score2$rel_cor.tau.f <- factor(data.accuracy.score2$rel_cor.tau.f ,
                                                   levels=c("(-5,-1]" , "(-1,0]",   "(0,2]" ) ,
                                                   labels=c("-1", "0", "1"))
write.csv(data.accuracy.score2, "data/data.accuracy.score.tau.csv")









