library(tidyverse)
library(sparkline)
library(htmltools)



# statistics for each team ------------------------------------------------

get_team_statistics <- function(epl_data, team){
  
  # home results
  home_results <- epl_data %>% filter(HomeTeam == team)
  home_wins <- home_results %>% filter(FTR == 'H') %>% select(Date) %>% 
    add_column(Result = 'W', Points = 3)
  home_draws <- home_results %>% filter(FTR == 'D') %>% select(Date) %>%
    add_column(Result = 'D', Points = 1)
  home_losses <- home_results %>% filter(FTR == 'A') %>% select(Date) %>% 
    add_column(Result = 'L', Points = 0)
  
  num_home_wins <- nrow(home_wins) 
  num_home_draws <- nrow(home_draws)
  num_home_losses <- nrow(home_losses)
  
  home_points <- num_home_wins*3 + num_home_draws
  
  # away results
  away_results <- epl_data %>% filter(AwayTeam == team)
  away_wins <-  away_results %>% filter(FTR == 'A') %>% select(Date) %>% 
    add_column(Result = 'W', Points = 3)
  away_draws <- away_results %>% filter(FTR == 'D') %>% select(Date) %>% 
    add_column(Result = 'D', Points = 1)
  away_losses <- away_results %>% filter(FTR == 'H') %>% select(Date) %>% 
    add_column(Result = 'L', Points = 0)
  
  num_away_wins <- nrow(away_wins) 
  num_away_draws <- nrow(away_draws)
  num_away_losses <- nrow(away_losses)
  
  away_points <- num_away_wins*3 + num_away_draws

  all_results <- bind_rows(home_wins,home_draws,home_losses,away_wins,away_draws,away_losses)

  # Last 10 game form
  all_results <- all_results %>% arrange(desc(Date)) %>% slice(1:10)
  form <- as.vector(all_results$Points) 
  
  games_played <- nrow(home_results) + nrow(away_results)
  total_points <- home_points + away_points
  
  team_stat <- tibble(team = team, played = games_played,
                   total_points = total_points, home_points =home_points, 
                   away_points = away_points,home_wins = num_home_wins,
                   home_losses=num_home_losses,away_wins = num_away_wins,
                   away_losses = num_away_losses,
                   home_draws = num_home_draws, away_draws=num_away_draws)

  # Statistics
  home_metrics <- c('FTHG', 'HS', 'HST','HC', 'HF')
  away_metrics <- c('FTAG', 'AS', 'AST','AC', 'AF')
  # Goals For, Shots For, Shots on Target, Corners For, Fouls Committed
  for_metrics <- c('GF','SF','STF', 'CF', 'FA') 
  # Goals Against, Shots Against, Shots on Target Against, Corners Against, Fouls Awarded
  against_metrics <- c('GA','SA', 'STA', 'CA', 'FF')
  
  for (i in seq_along(home_metrics)){
    home_metric <- home_metrics[i]
    away_metric <- away_metrics[i]
    for_metric <- for_metrics[i]
    against_metric <- against_metrics[i]
    stats_for <- epl_data %>% filter(HomeTeam == team ) %>%
      select(home_metric) %>% sum() + epl_data %>% filter(AwayTeam == team ) %>%
      select(away_metric) %>% sum()
    stats_against <-  epl_data %>% filter(HomeTeam == team ) %>%
      select(away_metric) %>% sum() + epl_data %>% filter(AwayTeam == team ) %>%
      select(home_metric) %>% sum()
    team_stat <- team_stat %>% add_column((!!for_metric) := stats_for)
    team_stat <- team_stat %>% add_column((!!against_metric) := stats_against)
  }
  
  team_stat <- team_stat %>% add_column(form_points = as.character(htmltools::as.tags(sparkline(form, 
                                                      type = "line",chartRangeMin=0))))
  return(team_stat)
}



# Get the points equivalent for each result -------------------------------

get_match_points <- function(ht, at, ftr, team) {
  if ((ht == team & ftr == 'H') | (at == team & ftr == 'A') ){
    return(3)
  }
  else if (ftr == 'D'){
    return(1)
  }
  else return(0)
}



# Required points for championship based on current table standings -------

reqd_points_for_chmpship <- function(game_week,top_team_points,rival_team_points,num_teams = 20){
  win_points <- 3
  games_per_season <- (num_teams -1)*2
  reqd_points_season_start <- (games_per_season -1)*win_points+1
  games_left <- (games_per_season - game_week)
  reqd_points <- min(rival_team_points + (games_left*win_points) + 1,reqd_points_season_start)
  return(reqd_points)
}


# Weekly results for a team -----------------------------------------

#' Get the result for a team each week from the epl dataset
#' @return a dataframe with each game type, results for the team
get_team_points_by_matchweek <- function(epl_data,team){
  team_record <- epl_data[which(epl_data$HomeTeam == team | epl_data$AwayTeam == team),]
  team_record['team'] <- team
  team_record['points'] <- apply(team_record[,c('HomeTeam', 'AwayTeam', 'FTR', 'team')],1,
                                 function(y) get_match_points(y['HomeTeam'],y['AwayTeam'],y['FTR'], y['team']))
  team_record['game_type'] <- unlist(lapply(team_record$HomeTeam,function(x) {if (x== team) {'H'} else {'A'}}))
  team_record['opponent'] <- apply(team_record[,c('HomeTeam', 'AwayTeam')],1,
                                   function(y) {if (y['HomeTeam']== team) {y['AwayTeam']} else {y['HomeTeam']}} )
  return(team_record[,c('team','opponent','game_type','points')])
}



# Scrape championship data from wiki --------------------------------------

extractTable <- function(wiki_html, xpath) {
  cship_record <- wiki_html %>% html_nodes(xpath = xpath) %>%
    html_table()
  cship_record <- cship_record[[1]]
  cship_record <- cship_record %>% rename(Champions=`Champions(number of titles)`) %>% rowwise() %>% 
    mutate(cshipTillDate=str_extract(Champions, "(?<=\\()(.+)(?=\\))"), Champions=str_split(Champions," \\(")[[1]][1])
  
  cship_record$cshipTillDate <- cship_record %>% select(cshipTillDate) %>% unlist() %>% as.numeric() %>% replace_na(1)
  return(cship_record)
}