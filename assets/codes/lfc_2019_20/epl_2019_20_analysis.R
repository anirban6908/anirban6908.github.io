library(reshape)
library(ggplot2)
library(plotly)
library(tidyverse)
library(formattable)
library(sparklines)
library(lubridate)
library(ggradar)
library(scales)
library(rvest)
library(leaflet)
library(leaflet.extras)
library(htmltab)
library(maps)
library(mapdata)
library(maptools)
library(ggmap)

source("soccer_functions.R")

# Setting working directory -----------------------------------------------

setwd("~/Codes/Personal_Blog/Football_stuff/")

# Data path ---------------------------------------------------------------

epl_19_20_datapath <- file.path('data', 'E0.csv')


# Reading data ------------------------------------------------------------

epl_19_20_data <- read.csv(epl_19_20_datapath)
epl_19_20_data$Div <- 'Premier League'
epl_19_20_data <- epl_19_20_data %>% mutate(Date=dmy(Date))

epl_teams <- unique(epl_19_20_data$HomeTeam)
num_teams <- length(epl_teams)

stadium_data <- read_csv(file.path('data/uk_stadium_data.csv'))
england_stadium_data <- stadium_data %>% 
  filter(Country == 'England')

# Create Points Table -----------------------------------------------------

teams_stat <- tibble()
for (team in epl_teams){
  team_stat <- get_team_statistics(epl_19_20_data, team)
  teams_stat <- rbind(teams_stat,team_stat)
}

teams_stat <- teams_stat %>% mutate(GD = GF-GA)
points_table <- teams_stat %>% arrange(-total_points,-GD,-GF,GA)
points_table<- points_table %>% rowwise() %>% mutate(W = sum(home_wins,away_wins))
points_table<- points_table %>% rowwise() %>% mutate(L = sum(home_losses,away_losses))
points_table<- points_table %>% rowwise() %>% mutate(D = sum(home_draws,away_draws))
points_table <- points_table %>% select(team,played, total_points, 
                                  W, L, D,GD,GF,GA,form_points)
points_table <- points_table %>% rename(Team = team,Played=played,Points=total_points,
                           'Form (Last 10)' = form_points)

# Render points table -----------------------------------------------------

customGreen = "#71CA97"
customRed = "#ff7f7f"
gd_formatter <- formatter(
  "span",
  style=x ~ style(color = ifelse(x <= 0 , "red", "green")))

pts_tbl <- formattable(points_table, align = c("l",rep("c", ncol(points_table) -1)),
                     list(Points = color_tile(customRed,customGreen),
                          GD = gd_formatter))%>%
                      formattable::as.htmlwidget()
pts_tbl$dependencies <- c(
  pts_tbl$dependencies,
  htmlwidgets:::widget_dependencies("sparkline","sparkline")
)
print(pts_tbl)
htmlwidgets::saveWidget(pts_tbl, "points_table.html", selfcontained = F, libdir = "htmlwidgets_deps")

# Race to the Championship ------------------------------------------------

teams_record_by_gameweek <- data.frame()
for (team in epl_teams){
  team_record <- get_team_points_by_matchweek(epl_19_20_data,team)
  team_record$points_by_week <- cumsum(team_record$points)
  team_record$game_week <- seq.int(nrow(team_record))
  teams_record_by_gameweek <-rbind(teams_record_by_gameweek,team_record)
}

top_teams_per_week <- teams_record_by_gameweek %>% 
                      select(team, game_week, points_by_week) %>%
                      group_by(game_week) %>% arrange(game_week,-points_by_week) %>% slice(1:2) 
reqd_cship_points_by_week <- c()

top_6_teams <- teams_stat[order(-teams_stat$total_points),'team'] %>% .$team 
top_6_teams <- top_6_teams[1:6]
top_6_record <- teams_record_by_gameweek %>% filter(team %in% top_6_teams)
gameweeks <- sort(unique(top_6_record$game_week))

upto_gameweek_record <- data.frame()
for (game_week_ in gameweeks){
  top_teams_by_week_ <- top_teams_per_week %>% filter(game_week == game_week_) %>% 
    ungroup() 
  top_teams_by_week_ <- top_teams_by_week_ %>% bind_rows(upto_gameweek_record) %>% 
    arrange(-points_by_week) %>% distinct(team,.keep_all = TRUE)
  top_team_points <- top_teams_by_week_$points_by_week[1]; rival_team_points <- top_teams_by_week_$points_by_week[2]
  rival_game_week <- top_teams_by_week_$game_week[2]
  reqd_points <- reqd_points_for_chmpship(rival_game_week,top_team_points,rival_team_points)
  reqd_cship_points_by_week <- append(reqd_cship_points_by_week,reqd_points)
  upto_gameweek_record <- top_teams_by_week_ %>% slice(1:2)
}

cship_points_df <- data.frame('week' = gameweeks, 'reqd_cship_points' = reqd_cship_points_by_week, 
                              'opponent' = '')

top_6_record <- teams_record_by_gameweek %>%
  filter(team %in% top_6_teams)

# Plot points per gameweek
p <- ggplot(top_6_record,aes(x=game_week, y = points_by_week, text = paste("opponent:",opponent), group = team))+
  geom_line(aes(color=team))+geom_point(aes(color=team))
p <- p + geom_line(data=cship_points_df,aes(x=week, y=reqd_cship_points,color='Reqd. C\'ship points'))
#+geom_point(data=cship_points_df,aes(x=week, y=reqd_cship_points,color='Reqd. C\'ship points')) 
p<- p+  scale_colour_manual('', breaks= c('Liverpool','Man City','Leicester', 'Chelsea','Man United',
                                 'Tottenham','Reqd. C\'ship points'),
                      values=c('Liverpool' = 'firebrick','Leicester' = 'dodgerblue',
                               'Chelsea' = 'blue', 'Man City' = 'deepskyblue',
                               'Man United' = 'red', 'Tottenham' = 'grey',
                               'Sheffield United' = 'firebrick',
                               'Reqd. C\'ship points' = 'black'))
p <- p +  theme_minimal() + ggtitle("Race to Championship") 
p_ggplotly <- ggplotly(p, tooltip = c("x", "y", "text"))
print(p_ggplotly)
htmlwidgets::saveWidget(p_ggplotly, "epl_points_by_week.html", selfcontained = F, libdir = "htmlwidgets_deps")


# Points breakup by home and away -----------------------------------------

teams_points <- teams_stat %>% select(team,total_points,home_points,away_points) %>% 
  pivot_longer(-c(team,total_points), names_to = "points_type", 
                                            values_to = "value")


teams_points$team <- as.character(teams_points$team)
teams_points <- teams_points[order(-teams_points$total_points,teams_points$team),]
teams_points$team <- factor(teams_points$team,levels = unique(teams_points$team[order(-teams_points$total_points,
                                                                                      teams_points$team)]))
teams_points$points_type <- factor(teams_points$points_type, levels = c('away_points','home_points'))

# Plot points data
p <- ggplot(data=teams_points,aes(x=team,y=value,fill=points_type)) +
              geom_bar(stat="identity")+labs(fill = "points_type")
p <- p  + theme_minimal() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
p <- p + ggtitle("Home and Away Performance") +
  xlab("Clubs") + ylab("Points (till date)")
print(ggplotly(p))
htmlwidgets::saveWidget(ggplotly(p), "points_breakup.html", selfcontained = F, libdir = "htmlwidgets_deps")


# Radar plot for avg match statistics -------------------------------------

stats_radar <- teams_stat %>% arrange(-total_points,-GD, -GF, GA) %>%
  select(team, played, GF, SF, STF, CF, FF, GA, SA, STA, CA, FA) %>%
  mutate_at(vars(-team,-played), funs(./played)) %>%
  mutate_at(vars(-team,-played), rescale) %>%   head(4) # normalized against all 20 teams but showing only top 4


p_radar <- ggradar(stats_radar %>% select(-played),
                   values.radar = c("","","100%"),
                   group.colours = c('Liverpool' = 'firebrick','Man United' = 'red',
                                     'Chelsea' = 'blue', 'Man City' = 'deepskyblue'),
                   background.circle.transparency = 0)
print(p_radar)
ggsave("stat_radar.png", plot = p_radar, dpi=500)


# Scrape wikipedia for top flight record ----------------------------------

cship_wiki_url <- "https://en.wikipedia.org/wiki/List_of_English_football_champions"
cship_wiki <- xml2::read_html(cship_wiki_url)

cship_record <- extractTable(cship_wiki, xpath ='//*[@id="mw-content-text"]/div[1]/table[3]')
epl_record <- extractTable(cship_wiki, xpath ='//*[@id="mw-content-text"]/div[1]/table[4]')

# Taken from this answer: https://stackoverflow.com/questions/47585699/rvest-html-table-error-error-in-outj-k-subscript-out-of-bounds
all_record <- cship_wiki_url %>%
  htmltab(5, rm_nodata_cols = F) %>%
  .[,-1] %>%
  replace_na(list("Winning seasons" = "")) %>%
  `rownames<-` (seq_len(nrow(.)))

all_record <- all_record %>% left_join(england_stadium_data, by=c("Club" = "Team"))
all_record <- all_record %>% drop_na(any_of("Latitude"))
lfc_position <- all_record %>% filter(Club == 'Liverpool') %>% select(c(Latitude, Longitude))

# Heatmap of the league success -------------------------------------------

popup <- "Liverpool FC, Premier League Champion"
m <-leaflet(all_record) %>% addProviderTiles(providers$CartoDB.Positron) %>%
  addMarkers(lfc_position$Longitude, lfc_position$Latitude, popup = popup) %>%
  addHeatmap(lng = ~Longitude, lat = ~Latitude, intensity = ~Winners,
             blur = 20, max = 0.05, radius = 15)
print(m)
htmlwidgets::saveWidget(m, "cship_region.html", selfcontained = F, libdir = "htmlwidgets_deps")


