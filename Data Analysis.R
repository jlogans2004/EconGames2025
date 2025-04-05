library(tidyverse)
library(readxl)
library(stargazer) # probably don't need lol
library(ggplot2)
library(data.table)
library(lubridate)
library(zoo)
library(patchwork)
library(rddtools)
library(haven)
library(gridExtra)
library(cowplot)
library(scales)

setwd("C:/Users/johnl/Documents/Spring 2025/EconGames2025")

data <- read_csv("entry_exit_combined.csv")

concession_data <- read_excel("./Data Sets/2. Concession Data.xlsx") %>% mutate(Time=as.ITime(strftime(Time, format="%H:%M:%S", tz="UTC"), format="%H:%M:%S", tz="UTC"))

new_data <- data %>% mutate(intraday=as.ITime(strftime(Time, format="%H:%M:%S", tz="UTC"), format="%H:%M:%S", tz="UTC")) %>% filter(parking_type=="Transient", Entry_dummy==TRUE)

ggplot(new_data) + geom_density(aes(x=intraday, fill="#FF6666"), alpha=.4) + scale_x_time() + geom_density(data=concession_data, mapping=aes(x = Time, fill="#6655FF"), alpha=.4) + labs(x="Time of day", y="Density of purchases", title="Concession Sales and Parking Entries") + scale_fill_manual(name="Color",labels=c("Concession sales", "Transitive parking entries"), values=c("#FF6666", "#6655FF"))

dataforpie <- data %>% filter(Entry_dummy==TRUE, location %in% c("Mercer", "Washington Park", "Ziegler", "Fountain Square"))
counts <- dataforpie %>% group_by(parking_type) %>% summarize(n=n())
p1 <- ggplot(counts) + geom_bar(aes(x="", y=n, fill=parking_type), stat="identity", width=1) + coord_polar("y", start=0) + theme_void() + labs(title="Over-The-Rhine Parking Distribution", fill="Parking Type") + theme(plot.title = element_text(hjust = 0.5), legend.position="none") + scale_fill_manual(values=hue_pal()(4))
cbddata <- data %>% filter(Entry_dummy=TRUE, !location %in% c("Mercer", "Washington Park", "Ziegler", "Fountain Square"), !parking_type=="Pay On Entry")
cbdcounts <- cbddata %>% group_by(parking_type) %>% summarize(n=n())
p2 <- ggplot(cbdcounts) + geom_bar(aes(x="", y=n, fill=parking_type), stat="identity", width=1) + coord_polar("y", start=0) + theme_void() + labs(title="Central Business District Parking Distribution", fill="Parking Type") + theme(plot.title = element_text(hjust = 0.5)) + scale_fill_manual(values=hue_pal()(4))

plot_grid(p1, p2, align='v')

# Aggregate on day, location

grouped_regular_data <- new_data %>% filter(as.Date(Time) >= as.Date("2022-01-01"), as.Date(Time) < as.Date("2024-05-01"))
grouped_regular_data <- grouped_regular_data %>% mutate(Date = as.Date(Time), Month = as.Date(strftime(Date, format="%Y-%m-01")))
grouped_regular_data <- grouped_regular_data %>% group_by(location, Month) %>% summarize(n=n())

otr <- grouped_regular_data %>% filter(location %in% c("Mercer", "Washington Park", "Ziegler", "Fountain Square"))
ggplot(grouped_regular_data, aes(x=Month, y=n)) + geom_col() + labs(y="Total Parking Sales") + ggtitle("Total Parking Sales by Month in Over-The-Rhine")

# Aggregate sales on day, location

grouped_sales_data <- concession_data %>% mutate(Year = as.Date(strftime(Date, format="%Y-01-01")),Month = as.Date(strftime(Date, format="%Y-%m-01")), quarter = as.yearqtr(Date), quarternoyear=as.factor(quarter(Date))) %>% filter(Date < as.Date("2025-01-01"))
grouped_sales_data2 <- grouped_sales_data %>% group_by(Month, quarternoyear, Year) %>% summarize(sales=sum(`Net Sales`))
                                                                 
ggplot(grouped_sales_data2, aes(x=Month, y=sales)) + geom_col()
unique(grouped_sales_data$Location)
grouped_sales_data <- grouped_sales_data %>% filter(`Net Sales`>0, Location %in% c("Washington Park Management Group", "Memorial Hall Operations", "Ziegler Park  - Concessions", "Ziggy's", "Imagination Alley"))

lm1 <- lm(sales ~ Month, grouped_sales_data2)
stargazer(lm1, type='text')
ggplot(grouped_sales_data2, aes(x=Month, y=sales)) + geom_col() + geom_abline(intercept=lm1$coefficients[1], slope=lm1$coefficients[2], size=1.5, color="#FF6666") + labs(x="Month", y="Total Sales (USD)", title = "Concession Sales Over Time after Parking Renovations in Over-The-Rhine") + scale_color_manual(name="Color",labels=c("Line of best fit"), values=c("red"))

# Trying RD
grouped_sales_data2 <- grouped_sales_data2 %>% mutate(after_additions=ifelse(Month >= as.Date("2023-03-01"), 1, 0))
lm2 <- lm(sales ~ Month + after_additions + Month:after_additions, data=grouped_sales_data2)
stargazer(lm2, type='text')
predict(lm2, grouped_sales_data2)


ggplot(grouped_sales_data2, aes(x = Month, y = sales, fill = as.factor(after_additions))) +
  geom_col() +  # scatter plot of actual data
  geom_smooth(method = "lm", se = FALSE)+  # regression lines
  theme_minimal() +
  geom_vline(xintercept=as.Date("2023-03-01"), color='grey', linetype='dashed') + 
  scale_fill_manual(name="After Renovations?", values=c("0"=hue_pal()(2)[1], "1"=hue_pal()(2)[2]), labels=c("No", "Yes")) + 
  labs(title = "Concession Sales Over Time after Parking Renovations in Over-The-Rhine",
       x = "Month",
       y = "Sales")


