###THE CLEANED UP VERSION-----------------------
##loading data and imports--------

#contribution (here the weight plays a part)
plot.CA(CA_genre_nouns,shadow = TRUE, 
        axes= c(1,2),
        title="CA genre vs nouns (contribution highlights)",
        selectCol = "contrib 10",
        selectRow = "contrib 10",
        cex=0.5)


sort(CA_genre_nouns$row$contrib[,"Dim 1"],decreasing=T) #only rap and pop rock contribute to axis 1
sort(CA_genre_nouns$row$contrib[,"Dim 2"],decreasing=T) #R&B 56% , pop en country +-15%
sort(CA_genre_nouns$row$contrib["Rap",],decreasing=T)
sort(CA_genre_nouns$col$contrib[,"Dim 1"][1:20],decreasing=T) #only rap and pop rock contribute to axis 1



## doing CA : for genre vs moods -------
df_genre_moods = column_to_rownames(df_genre_moods,'X')
CA_genre_moods <- CA(df_genre_moods)

plot.CA(CA_genre_moods,shadow = TRUE, title="CA genre vs moods",
        selectCol = "cos2 10",
        selectRow = "cos2 15",
        cex=0.5)


## doing CA : for genre vs words with moods as supplementary variables -------
  ##step1 join the 2 datasets
##finding the supplementary columns for 1 dimension
#based on big : Aggressive Brash Confident Energetic Exciting Exuberant Menacing Street-Smart Tough
sup_col_sel = c("Street.Smart","Brash","Angry","Tough",
                "Hedonistic","Joyous","Devotional","Poignant",
                "Pastoral","Earthy","Organic","Bittersweet",
                "Elegant","Gritty","Sensual", "Romantic","Sexy","Melancholy")
sup_col_idx= rep(0,length(sup_col_sel))
for (i in seq(1,length(sup_col_sel))){
  sup_col_idx[i] = which(colnames(df_genre_moods)== sup_col_sel[i])
}
sup_col_idx 
sup_col_idx_ca <- seq(length(df_genre_nouns_s)+1,
                      length(df_genre_nouns_s)+length(sup_col_idx))
df_genre_nouns_sup <- cbind(df_genre_nouns_s,df_genre_moods[,sup_col_idx])

CA_genre_nouns <- CA(df_genre_nouns_sup,
                     col.sup = sup_col_idx_ca)


plot.CA(CA_genre_nouns,shadow = TRUE, title="CA genre vs nouns",
        selectCol = "cos2 30",
        selectRow = "cos2 5", #enkel 10 met beste representatie getoond
        cex=0.5)


##DRAFT !!!!#########################-----------------------------
##NOTES ---------
# CA says nothing about significance of relationships because it uses probabilities, not the number of observations !

# projection is to maximize inertia : this means that the axis are drown towards : 
#   - profiles that are heavy (fi. is big= sum of words is big = overrepresented = eg rap)
#   - profiles that use common words differently than the meanprofile
#          - common words give more weight to the chi2 distance
#          - difference with mean = the euclidean distance to the center of the cloud
#    reason : inertia of a point = (chi2 distance)^2 * weight
#             inertia of the cloud = sum over all points
#             intertia associated with an axis s = lambda s
#   - this means that a underrepresented genre will not influence the axis much
#      but ! it can still have a large value on that axis if it just happens to lie in the direction of the axis
# 

#create a pie chart with ggplot------------

#normal pie
pie <- pie(x=t_wordcount_genre$wordcount,
           labels=if_else(t_wordcount_genre$genre1 != "Other",
                          t_wordcount_genre$genre1,
                          ""))

#ggplot barchart
t_wordcount_genre <- cbind(t_genre_nouns_s[,1],
                           wordcount = apply(t_genre_nouns_s[,-1],1,sum))
t_wordcount_genre
t_wordcount_genre$genre1 <- if_else(t_wordcount_genre$genre1%in%c('Rap','R&B','Country','Pop/Rock','Electronic'),
                                    as.character(t_wordcount_genre$genre1),
                                    "")                              
t_wordcount_genre$genre1 [16] <- "Other"

t_wordcount_genre <- arrange(t_wordcount_genre,desc(wordcount))

t_wordcount_genre <- t_wordcount_genre %>% mutate(pos = cumsum(t_wordcount_genre$wordcount)-(t_wordcount_genre$wordcount/2))

t_wordcount_genre$genre1 <- reorder(t_wordcount_genre$genre1,t_wordcount_genre$wordcount)
piegg <- ggplot(data = t_wordcount_genre
                , mapping = aes(1,y=wordcount, fill = factor(genre1)))
piegg <- piegg + geom_bar(width = 1, position ="stack",show.legend = F,stat = "identity")
piegg <- piegg + geom_text(data=t_wordcount_genre, aes(1,y = pos, label = genre1),size=3)
piegg <- piegg + scale_fill_brewer() 
piegg <- piegg + theme_bw()
piegg <- piegg + theme(axis.title.x = element_blank())
piegg <- piegg + theme(axis.text.x = element_blank())
piegg <- piegg + ggtitle("Total wordcount per genre")
piegg
#piegg <- piegg + coord_polar(theta = "y")
#piegg

# a wordcloud ----------------------
wordcloud(words = t_dim1_rap_cos2$nouns,
          freq = t_dim1_rap_cos2$cos2,
          max.words = 20,
          scale = c(0.8,1))

## examine the effect of uneven rows------------
# add a row with the mean profile in different scales
testa_df_genre_nouns_s <- df_genre_nouns_s
testa_df_genre_nouns_s <- rbind(testa_df_genre_nouns_s,
                                apply(df_genre_nouns_s,2,mean))
testa_df_genre_nouns_s <- rbind(testa_df_genre_nouns_s,
                                apply(df_genre_nouns_s,2,mean)*1000)
testa_df_genre_nouns_s <- rbind(testa_df_genre_nouns_s,
                                apply(df_genre_nouns_s,2,mean))
testa_df_genre_nouns_s <- rbind(testa_df_genre_nouns_s,
                                apply(df_genre_nouns_s,2,mean)*1000)

dim(testa_df_genre_nouns_s)
rownames(testa_df_genre_nouns_s)[20:23] <- 
  c('meanProf','meanProfX1000','meanProfHoe','meanProfHoeX1000')
testa_df_genre_nouns_s[meanProfHoe,'hoe'] = 10000000
testa_df_genre_nouns_s[meanProfHoeX1000,'hoe'] = 10000000000
rownames(testa_df_genre_nouns_s)
testb_CA_genre_nouns <- CA(testa_df_genre_nouns_s,
                     ncp=19)
testb_CA_genre_nouns$row$inertia


plot.CA(testb_CA_genre_nouns,shadow = TRUE, 
        axes= c(1,2),
        title="CA genre vs nouns",
        selectCol = "cos2 30",
        selectRow = "cos2 15",
        cex=0.5)
#interessant : verandert enkel de scaling van de woordenwolk (niet inertia explained), de positie op de map is identiek, maar het is alsof de rode puntenwolk gekrompen is
#de meanprofile , scaled of niet zal dus altijd in het midden van de wolk zitten
#illustreert algemeen principe : identieke profiles (buiten scaling) mag je samennemen, landen op hetzelfde punt op de grafiek



##scaling the rowprofiles (update : NIET CORRECT OM DIT TE DOEN !!)---------------------
##we don't want genres that are overrepresented to have more weight than others !
## so for our purpose and questions , we scale the row profiles first
df_genre_nouns_s_norm <- t(apply(df_genre_nouns_s,1,function(i) i/sum(i)))
## doing CA : for genre vs words------
CA_genre_nouns <- CA(df_genre_nouns_s_norm,
                     ncp=19)


CA_genre_nouns$row$contrib

###explore the CA analysis data--------
  ### cos2 : quality of rep -----------
##quality of representation = cos2 = angle of projection of the profile
  ## genres
sort(CA_genre_nouns$row$cos2[,"Dim 1"],decreasing = TRUE)
# 1)rap : 0.98 so almost on the line
# 2)pop rock  0.6 : dus volgens die as, maar kleine vector

sort(CA_genre_nouns$row$cos2[,"Dim 2"],decreasing = TRUE)
# 1)r&B  : 84 % : dus de defining as voor r&b.  r&b zit dus dicht bij 
# de mean profile, maar in de kleine afwijking die het bezit is dit vnl langs as 2

#focus op R&B : duidelijk dat 2e as het merendeel van de afwijking verklaart
sort(CA_genre_nouns$row$cos2["R&B",],decreasing = TRUE)
#dit somt op tot 1 (bijna omdat enkel 5 dim worden bewaard)
sum(CA_genre_nouns$row$cos2["R&B",])
#daarom is quality of representation gebruikt om te selecteren wat er op de graph komt !

sort(CA_genre_nouns$row$cos2["Religious",],decreasing = TRUE)


   #contributions ------
# beware!! : this is also influenced by the weight ! and rap en pop have high weights
# i guess  i have to scale !! yEP!!!
sort(apply(df_genre_nouns_s,1,sum),decreasing = TRUE)
sort(CA_genre_nouns$row$contrib[,"Dim 1"],decreasing = TRUE)
           #rap 77% contributie bij as1, 17 voor pop rock en 13 voor rB
sort(CA_genre_nouns$row$contrib[,"Dim 2"],decreasing = TRUE)
          #56% rb, 18%pop, 14%country, 2jazz


  ## inertia------
CA_genre_nouns$svd
#18 dim for all inertia (= 19- 1: klopt)
dim(df_genre_moods)
summary(CA_genre_nouns)
#welke moods per genre ?--------


sort(df_genre_moods["International",],decreasing = T)[1:5]
sort(df_genre_moods["Rap",],decreasing = T)[1:5]
sort(df_genre_moods["Jazz",],decreasing = T)[1:10]
sort(df_genre_moods["Blues",],decreasing = T)[1:5]
sort(df_genre_moods["R&B",],decreasing = T)[1:20]
sort(df_genre_moods["Religious",],decreasing = T)[1:10]

## joining the 2 contingency tables on genre, to use moods as supplementary variables
a <- rownames_to_column(df_genre_nouns_s, var= "genre")
b <- rownames_to_column(df_genre_moods, var= "genre")
df_genre_cont<-full_join(a, b, by = c("genre"),
                         copy=FALSE)
df_genre_cont = column_to_rownames(df_genre_cont,'genre')

df_genre_cont[,467] #start van moods
df_genre_cont[,1] 




install.packages("tidyverse")


df_t1 = df_artist %>% 
  group_by(genre1) %>% 
  summarize_at(.vars=seq(19,2806),.funs=funs("sum"))

df_t1 = df_artist %>% 
  group_by(genre1) %>% 
  summarize_at(.vars=c("elbow"),.funs=funs("sum"))

summary(df_artist[,2806])
colnames(df_artist[2806])

df_test = df_artist[,c("genre1","you","love")]

df_genre_nouns = df_test %>% 
  group_by(genre1) %>% 
  summarize_all(.funs=funs("sum"))

#select a column by columnname + using 2 function
#  the columnlabels will remain the original name
df_genre_nouns1 = df_test %>% 
  group_by(genre1) %>% 
  summarize_at(.vars=c("love"),.funs=funs("sum"))

#select a column by columnnumber + using 2 function
#  the columnlabels will be the functionnames
df_genre_nouns2 = df_test %>% 
  group_by(genre1) %>% 
  summarize_at(.vars=2,.funs=funs("sum","mean"))

#select 2 columns by columnnumber + using 2 function
#  the columnlabels will be the functionnames + original eg love_sum
df_genre_nouns3 = df_test %>% 
  group_by(genre1) %>% 
  summarize_at(.vars=c(1,2),.funs=funs("sum","mean"))

df_genre_nouns4 = df_test %>% 
  group_by(genre1) %>% 
  summarize_at(.vars=seq(1,2),.funs=funs("sum","mean"))


sum(is.na(df_artist))

startCol = which(colnames(df_artist)=='mood10') + 1
endCol = length(df_artist)

df_test = df_artist %>% 
  group_by(genre1,mood1) %>% 
  count()

df_test

## building the genre-mood df
## step1 : find out the different moods
which(colnames(df_artist)=='mood10')

moodList <-paste(c("mood"), 1:10, sep = "")

for (idx in seq(1:10) ) {
  print(moodList[idx])
  d1<-as.character(distinct_(df_artist,moodList[idx])$)
  print(d1)
}
d1


d1<-as.character(distinct_(df_artist,"mood1")$mood1)
head(d1)
str(d1)
d2<-as.character(distinct_(df_artist,"mood2")$mood2)
head(d2)
str(d2)
d3 <- c(d1,d2)
str(d3)
unique(d3)

d1<-distinct_(df_artist,.dots =moodList)
head(d1)
d3<-d1
d2<-distinct_(df_artist,colnames(df_artist)[9])
str(moodList)
d2<-distinct(d1)
str(d1)


## step2 : make a df with index = genres, and labels = moods and all values = 0

## step3 : make a for loop that goes over every artist, and every mood and
##  updates the moodvalue (weighted = mood1 has 10X weight then mood10)

## step4 : normalise the values per genre

## step5 : join with the df_artist

## step6 : use the moods as supplementary variables

## step7 : do a separate CA analysis on genre vs mood

## doing CA------
res <- CA(df_genre_nouns_s)
summary(res)

plot(res,shadow = TRUE, title="CA factor mine")

plot(res,shadow = TRUE, title="CA factor mine2",
     selectCol = "cos2 30",
     selectRow = "cos2 15",
     cex=0.5)




t1 <- sort(apply(df_genre_nouns_s,2,sum),decreasing = TRUE)
head(t1,20)
t2<- sort(apply(df_genre_nouns_s,1,sum),decreasing = TRUE)
t2


#shiny-------------

CAshiny(CA_genre_nouns)


setwd('C:/Users/Administrator/Documents/OneDrive/R_MyFiles')
df_nouns<-read.csv('artistNounFingerprint.csv',header=TRUE,row.names = 1)
df_artist_scrape <-read.csv('artistScrape.csv',header=TRUE,row.names = 1)

df_nouns <- rownames_to_column(df_nouns,'artist')
df_artist_scrape <- rownames_to_column(df_artist_scrape,'artist')

class(df_artist_scrape)


df_artist <- inner_join(df_artist_scrape, df_nouns, by = 'artist')

rang1 = seq.int(19:20)
temp1 = df_artist %>% 
  group_by(genre1) %>% 
  summarise_at(c(seq(19,length(df_artist))),funs(sum(.,na.rm=TRUE)))

temp2 = column_to_rownames(temp1,'genre1')

rownames(temp1)

temp1[40:50]
length(df_artist)

which(colnames(df_artist)=='style1')
colnames(df_artist)[19]


str(seq(1,3))
str(c(2,3))
str(temp1)
?summarise_if


df_artist_skip <- anti_join(df_nouns, df_artist_scrape, by = 'artist')
df_artist_skip2 <- anti_join(df_artist_scrape,df_nouns,  by = 'artist')
df_artist_skip['artist']  #some values are missing : reason : artist not found (only 10)
df_artist_skip2['artist'] #some values are are not matched : reason : blank lyrics !
write.csv(df_artist,file="artist_allmusic_nouns.csv")
  
#some exploratory analysis-----------
#how sparse ?
sum(nouns[]!=0)/sum(nouns[])
sum(nouns)
noun_columns_nz <- apply(nouns,2,function(x)sum(x!=0))
sort(noun_columns_nz, decreasing=TRUE)[1:40]
sum(noun_columns_nz==1) ##503 columns with unique wordd
boxplot(noun_columns_nz) ##how to show density ?
ggplot(data.frame(x=noun_columns_nz), aes(x)) +  geom_dotplot()

nouns_cor <- cor(nouns) #60MB , large matrix
##sum(abs(nouns_cor) > 0.8
rndCols <- sample(seq(1:ncol(nouns)),5,replace=FALSE)
rndTestData <- nouns[,rndCols]
ggpairs(rndTestData)


#show fingerprint of 1 artist
prince_fingerprint = sort(nouns['prince',],decreasing = TRUE)
prince_fingerprint[1:10]

##find the most middle of the road lyrics----I love you baby------------
total_sum <- sum(df_nouns,na.rm = TRUE)
mdf_overall <- apply(X = df_nouns,MARGIN = 2,FUN = function(x) sum(x,na.rm=TRUE)/total_sum)
mdf_overall <- sort(mdf_overall,decreasing = TRUE)
plot(mdf_overall[1:11])
sum(mdf_overall[1:100]) ##70% of the lyrics is composed of 100 words

##find the first 5 principal components : common themes ?------
pc_nouns <-prcomp(df_nouns)
plot(pc_nouns,scale=FALSE,retx=TRUE)
help("prcomp")


pc_nouns$sdev[1:10]^2
pc_nouns$rotation[1:10,1]
summary(pc_nouns)
pc_nouns$
df_nouns[1:1]

screeplot(pc_nouns,type='lines')
sum(pc_nouns$rotation[,1]^2) ##pc's all have unit length

PC1 <- pc_nouns$rotation[,1]
PC2 <- pc_nouns$rotation[,2]
sort((PC1),decreasing = TRUE)[1:10]
sort((PC1),decreasing = FALSE)[1:10]
sort((PC2),decreasing = TRUE)[1:10]
sort((PC2),decreasing = FALSE)[1:10]
plot(PC1,PC2)
points(c(10,20,39,4,53))

identify(PC1,PC2,n=5)
PC1[c(10,20,39,4,53)]

which(PC1< -0.6,arr.ind = TRUE)
which(PC2> 0.6,arr.ind = TRUE)

adele_fingerprint = sort(nouns['adele',],decreasing = TRUE)
adele_fingerprint[1:10]
mj_fingerprint = sort(nouns['michael jackson',],decreasing = TRUE)
mj_fingerprint[1:10]

plot(adele_fingerprint[1:10])
which.max(adele_fingerprint)
head(sort(adele_fingerprint,decreasing = TRUE),1)


X_cent = scale(df_nouns,center = TRUE, scale=FALSE)

X_2PC = X_cent%*%pc_nouns$rotation[,1:2]
plot(X_2PC)
which(X_2PC[,1] < -0.3)

colnames(df_nouns[1:10])

class(X_2PC)
X_2PC<-rownames_to_column(data.frame(X_2PC),'artist')

df_artist_2PC <- inner_join(df_artist_scrape, 
                            X_2PC,
                            by = 'artist')

unique(df_artist_2PC['genre1'])

df_artist_2PC_Sel<- subset(df_artist_2PC,subset = genre1==c('International','Rap'))


ggplot(data.frame(x=df_artist_2PC_Sel[,"PC1"],
                  y=df_artist_2PC_Sel[,"PC2"]), 
       aes(x,y,colour = factor(df_artist_2PC_Sel$genre1))) +  geom_point()



head(X_2PC[,1])
dim(X_2PC)
X_2PC['adele',]



####Factorminer correspondence analysis
install.packages("FactoMineR")
install.packages(c("Factoshiny","FactoInvestigate"))
library(FactoMineR)
library(Factoshiny)
##library(missMDA)
library(FactoInvestigate)

tail(colnames(df_artist),20)
column_to_rownames(df_artist,var = 1)
res <- CA(temp2,col.sup = 1:3)
plot(res,shadow = TRUE, title="CA factor mine")

plot(res,shadow = TRUE, title="CA factor mine",selectCol = "cos2 4",selectRow = "cos2 3")

dimdesc(res)
summary(res)
df_artist %>% select(genre1,matches('^genre'))

df_artist %>% select(genre1,matches('^genre|^style|^mood'))
bla1 <-df_artist %>% group_by(genre1) %>% summarize_at(.predi)

# installing/loading the package:
if(!require(installr)) {
  install.packages("installr"); require(installr)} #load / install+load installr

# using the package:
updateR() # this will start the updating process of your R installation.  It will check for newer versions, and if one is available, will guide you through the decisions you'd need to make.



