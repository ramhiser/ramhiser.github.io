---
categories:
- R
- Python
- Baseball
- Rankings
- Bradley-Terry
- Statistics
comments: true
date: 2013-08-25T00:00:00Z
title: MLB Rankings Using the Bradley-Terry Model
url: /2013/08/25/mlb-rankings-using-the-bradley-terry-model/
---

Today, I take my first shots at ranking Major League Baseball (MLB) teams. I see
my efforts at prediction and ranking an ongoing process so that my models
improve, the data I incorporate are more meaningful, and ultimately my
predictions are largely accurate. For the first attempt, let's rank MLB teams
using the [Bradley-Terry (BT) model](http://en.wikipedia.org/wiki/Pairwise_comparison#Probabilistic_models).

Before we discuss the rankings, we need some data. Let's scrape [ESPN's MLB Standings Grid](http://espn.go.com/mlb/standings/grid/_/year/2013) for a
win-loss matchups of any two MLB teams for the current season. Perhaps to
simplify the tables and to reduce the sparsity resulting from [interleague play](http://en.wikipedia.org/wiki/Interleague_play), ESPN provides only the
matchup records within a single league -- American or National. Accompanying the
matchups, the data include a team's overall record versus the other league, but
we will ignore this for now. The implication is that we can rank teams only
within the same league.

## Scraping ESPN with a Python Script

In the following Python script, the [BeautifulSoup library](http://www.crummy.com/software/BeautifulSoup/) is used to scrape ESPN's
site for a given year. The script identifies each team in the American League
table, their opponents, and their records against each opponent. The results are
outputted in a CSV file to analyze in R. The code is for the American League
only, but it is straightforward to modify the code to gather the National League
data. Below, I use only the data for 2013 and ignore the previous seasons. In a
future post though, I will incorporate these data.

Here's the Python code.

{{< highlight python >}}

# The following script scrapes ESPN's MLB Standings Grid and writes the
# standings for each American League (AL) team to a CSV file, which has the following
# format:
# Team, Opponent, Wins, Losses

from bs4 import BeautifulSoup
import urllib2
import re
import csv

csv_filename = 'AL-standings.csv'

year = '2013'
url = 'http://espn.go.com/mlb/standings/grid/_/year/' + year

page = urllib2.urlopen(url)
soup = BeautifulSoup(page.read())

# Extracts the table for the American League (AL) and the rows for each team
AL_table = soup.find(text = re.compile("American")).find_parent("table")
AL_rows = AL_table.findAll('tr', class_ = re.compile("team"))

# Creates a list of the AL teams and then appends NL for National League
AL_teams = [team_row.find('b').text for team_row in AL_rows]
AL_teams.append("NL")

# Opens a CSV file for the AL standings
with open(csv_filename, 'wb') as f:
    csv_out = csv.writer(f)
    csv_out.writerow(['Team', 'Opponent', 'Wins', 'Losses'])

    # For each team in the AL table, identifies the team's name, the opponent,
    # and their wins and losses (WL) against that opponent. Then outputs the
    # results to the open CSV file
    for team_row in AL_rows:
        team = team_row.find('b').text

        # A cell has the following form:
        # <td align="right">
        # 7-9</td>
        WL_cells = team_row.findAll('td', align = "right")

        # Extracts the values for both wins and losses from each WL table cell
        wins_losses = [td_cell.text.strip('\n').split('-') for td_cell in WL_cells]

        # Writes the current team's standings to the CSV file
        for i, opponent in enumerate(AL_teams):
            if team != opponent:
                csv_out.writerow([team, opponent, wins_losses[i][0], wins_losses[i][1]])
{{< / highlight >}}

## Bradley-Terry Model

The [BT model](http://en.wikipedia.org/wiki/Pairwise_comparison#Probabilistic_models) is
a simple approach to modeling pairwise competitions, such as sporting events,
that do not result in ties and is well-suited to the ESPN data above where we
know only the win-loss records between any two teams. (If curious, [ties can be handled with modifications](http://www.jstor.org/discover/10.2307/2283595).)

Suppose that teams $$i$$ and $$j$$ play each other, and we wish to know the
probability $$p_{ij}$$ that team $$i$$ will beat team $$j$$. Then, with the BT
model we define

$$
\text{logit}(p_{ij}) = \lambda_i - \lambda_j,
$$

where $$\lambda_i$$ and $$\lambda_j$$ denote the abilities of teams $$i$$ and
$$j$$, respectively. Besides calculating the probability of one team beating
another, the team abilities provide a natural mechanism for ranking teams. That
is, if $$\lambda_i > \lambda_j$$, we say that team $$i$$ is ranked superior to
team $$j$$, providing an ordering on the teams within a league.

Perhaps naively, we assume that all games are independent. This assumption makes
it straightforward to write the likelihood, which is essentially the product of
Bernoulli likelihoods representing each team matchup. To estimate the team
abilities, we use the [BradleyTerry2 R package](http://cran.r-project.org/web/packages/BradleyTerry2/index.html). The
[package vignette](http://cran.r-project.org/web/packages/BradleyTerry2/vignettes/BradleyTerry.pdf)
provides an excellent overview of the Bradley-Terry model as well as various
approaches to incorporating covariates (e.g., home-field advantage) and random
effects, some of which I will consider in the future. One thing to note is that
the ability of the first team appearing in the results data frame is used as a
reference and is set to 0.

I have placed all of the R code used for the analysis below within
**bradley-terry.r** in [this GitHub repository](https://github.com/ramey/baseball-rankings). Note that I use the
[ProjectTemplate](http://projecttemplate.net/) [package](http://cran.r-project.org/web/packages/ProjectTemplate/index.html) to
organize the analysis and to minimize boiler-plate code.

After scraping the matchup records from ESPN, the following R code prettifies
the data and then fits the BT model to both data sets.

{{< highlight r >}}
# Cleans the American League (AL) and National League (NL) data scraped from
# ESPN's MLB Grid
AL_cleaned <- clean_ESPN_grid_data(AL.standings, league = "AL")
NL_cleaned <- clean_ESPN_grid_data(NL.standings, league = "NL")

# Fits the Bradley-Terry models for both leagues
set.seed(42)
AL_model <- BTm(cbind(Wins, Losses), Team, Opponent, ~team_, id = "team_", data = AL_cleaned$standings)
NL_model <- BTm(cbind(Wins, Losses), Team, Opponent, ~team_, id = "team_", data = NL_cleaned$standings)

# Extracts team abilities for each league
AL_abilities <- data.frame(BTabilities(AL_model))$ability
names(AL_abilities) <- AL_cleaned$teams

NL_abilities <- data.frame(BTabilities(NL_model))$ability
names(NL_abilities) <- NL_cleaned$teams
{{< / highlight >}}


Next, we create a heatmap of probabilities winning for each matchup by first
creating a grid of the probabilities. Given that the inverse logit of 0 is 0.5,
the probability that team beats itself is estimated as 0.5. To avoid this
confusing situation, we set these probabilities to 0. The point is that these
events can never happen unless you play for Houston or have A-Rod on your team.


{{< highlight r >}}
AL_probs <- outer(AL_abilities, AL_abilities, prob_BT)
diag(AL_probs) <- 0
AL_probs <- melt(AL_probs)

NL_probs <- outer(NL_abilities, NL_abilities, prob_BT)
diag(NL_probs) <- 0
NL_probs <- melt(NL_probs)

colnames(AL_probs) <- colnames(NL_probs) <- c("Team", "Opponent", "Probability")
{{< / highlight >}}


Now that the rankings and matchup probabilities have been computed, let's take a
look at the results for each league.

## American League Results

The BT model provides a natural way of ranking teams based on the team-ability
estimates. Let's first look at the estimates.

![plot of chunk AL_team_abilities_barplot](http://i.imgur.com/XgwLvtS.png)



{{< highlight r >}}
## |     | ability | s.e.  |
## |-----+---------+-------|
## | ARI | 0.000   | 0.000 |
## | ATL | 0.461   | 0.267 |
## | CHC | -0.419  | 0.264 |
## | CIN | 0.267   | 0.261 |
## | COL | 0.015   | 0.250 |
## | LAD | 0.324   | 0.255 |
## | MIA | -0.495  | 0.265 |
## | MIL | -0.126  | 0.260 |
## | NYM | -0.236  | 0.262 |
## | PHI | -0.089  | 0.261 |
## | PIT | 0.268   | 0.262 |
## | SD  | -0.176  | 0.251 |
## | SF  | -0.100  | 0.251 |
## | STL | 0.389   | 0.262 |
## | WSH | -0.013  | 0.265 |
{{< / highlight >}}

(Please excuse the crude tabular output. I'm not a fan of how [Octopress](http://octopress.org/) renders tables. Suggestions?)

The plot and the table give two representations of the same information.  In
both cases we can see that the team abilities are standardized so that Baltimore
has an ability of 0. We also see that Tampa Bay is considered the top AL team
with Boston being a **close** second. Notice though that the standard errors
here are large enough that we might question the rankings by team ability. For
now, we will ignore the standard errors, but this uncertainty should be taken
into account for predicting future games.

The Astros stand out as the worse team in the AL. Although the graph seems to
indicate that Houston is by far worse than any other AL team, the ability is not
straightforward to interpret. Rather, using the inverse logit function, we can
compare more directly any two teams by calculating the probability that one team
will beat another.

A quick way to compare any two teams is with a heatmap. Notice how Houston's
probability of beating another AL team is less than 50%. The best team, Tampa
Bay, has more than a 50% chance of beating any other AL team.

![plot of chunk AL_matchup_heatmaps](http://i.imgur.com/9IfSUag.png)


While the heatmap is useful for comparing any two teams at a glance, bar graphs
provide a more precise representation of who will win. Here are the
probabilities that the best and worst teams in the AL will beat any other AL
team. A horizontal red threshold is drawn at 50%.

![plot of chunk AL_probs_top_team](http://i.imgur.com/WAD1Cc3.png)


![plot of chunk AL_probs_bottom_team](http://i.imgur.com/JRUd5Bj.png)


An important thing to notice here is that Tampa Bay is not unbeatable, according
to the BT model, the Astros have a shot at winning against any other AL team.

![plot of chunk AL_probs_middle_team](http://i.imgur.com/q3CB6tp.png)


I have also found that a useful gauge is to look at the probability that an
average team will beat any other team. For instance, Cleveland is ranked in the
middle according to the BT model. Notice that half of the teams have greater
than 50% chance to beat them, while the Indians have more than 50% chance of
beating the remaining teams. The Indians have a very good chance of beating the
Astros.

## National League Results

Here, we repeat the same analysis for the National League.

![plot of chunk NL_team_abilities_barplot](http://i.imgur.com/5BQt4xM.png)



{{< highlight r >}}
## |     | ability | s.e.  |
## |-----+---------+-------|
## | ARI | 0.000   | 0.000 |
## | ATL | 0.461   | 0.267 |
## | CHC | -0.419  | 0.264 |
## | CIN | 0.267   | 0.261 |
## | COL | 0.015   | 0.250 |
## | LAD | 0.324   | 0.255 |
## | MIA | -0.495  | 0.265 |
## | MIL | -0.126  | 0.260 |
## | NYM | -0.236  | 0.262 |
## | PHI | -0.089  | 0.261 |
## | PIT | 0.268   | 0.262 |
## | SD  | -0.176  | 0.251 |
## | SF  | -0.100  | 0.251 |
## | STL | 0.389   | 0.262 |
## | WSH | -0.013  | 0.265 |
{{< / highlight >}}


For the National League, Arizona is the reference team having an ability of
0. The Braves are ranked as the top team, and the Marlins are the worst team.
At first glance, the differences in National League team abilities between two
consecutively ranked teams are less extreme than the American League. However,
it is unwise to interpret the abilities in this way. As with the American
League, we largely ignore the standard errors, although it is interesting to
note that the top and bottom NL team abilities have more separation between them
when the standard error is taken into account.

As before, let's look at the matchup probabilities.

![plot of chunk NL_matchup_heatmaps](http://i.imgur.com/aVpVIDK.png)


From the heatmap we can see that the Braves have at least a 72% chance of
beating the Marlins, according to the BT model. All other winning probabilities
are less than 72%, giving teams like the Marlins, Cubs, and Mets a shot at
winning.

Again, we plot the probabilities for the best and the worst teams along with an
average team.

![plot of chunk NL_probs_top_team](http://i.imgur.com/sZXVmFL.png)



{{< highlight r >}}
ATL_probs <- subset(NL_probs, Team == "ATL" & Opponent != "ATL")
prob_ATL_SF <- subset(ATL_probs, Opponent == "SF")$Probability
series_probs <- data.frame(Wins = 0:3, Probability = dbinom(0:3, 3, prob_ATL_SF))
print(ascii(series_probs, include.rownames = FALSE, digits = 3), type = "org")
{{< / highlight >}}


{{< highlight r >}}
## | Wins  | Probability |
## |-------+-------------|
## | 0.000 | 0.048       |
## | 1.000 | 0.252       |
## | 2.000 | 0.442       |
## | 3.000 | 0.258       |
{{< / highlight >}}


I find it very interesting that the probability Atlanta beats any other NL team
is usually around 2/3. This makes sense in a lot of ways. For instance, if
Atlanta has a three-game series with the Giants, odds are good that Atlanta will
win 2 of the 3 games. Moreover, as we can see in the table above, there is less
than a 5% chance that the Giants will sweep Atlanta.

![plot of chunk NL_probs_bottom_team](http://i.imgur.com/E24KZ1Z.png)


The BT model indicates that the Miami Marlins are the worst team in the National
League. Despite their poor performance this season, except for the Braves and
the Cardinals, the Marlins have a legitimate chance to beat other NL teams. This
is especially the case against the other bottom NL teams, such as the Cubs and
the Mets.

![plot of chunk NL_probs_middle_team](http://i.imgur.com/ikAMFQS.png)


## What's Next?

The above post ranked the teams within the American and National leagues
separately for the current season, but similar data are also available on ESPN
going back to 2002. With this in mind, obvious extensions are:

* Rank the leagues together after scraping the [interleague play](http://en.wikipedia.org/wiki/Interleague_play) matchups.

* Examine how ranks change over time.

* Include previous matchup records as prior information for later seasons.

* Predict future games. Standard errors should not be ignored here.

* Add covariates (e.g., home-field advantage) to the BT model.
