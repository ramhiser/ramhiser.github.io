---
categories: R
comments: true
date: 2011-06-05T00:00:00Z
title: Conway's Game of Life in R with ggplot2 and animation
url: /2011/06/05/conways-game-of-life-in-r-with-ggplot2-and-animation/
---

In undergrad I had a computer science professor that piqued my interest in applied mathematics, beginning with [Conway's Game of Life](http://en.wikipedia.org/wiki/Conway%27s_Game_of_Life). At first, the Game of Life (not the board game) appears to be quite simple — perhaps, too simple — but it has been widely explored and is useful for modeling systems over time. It has been forever since I wrote my first version of this in C++, and I happily report that there will be no nonsense here.

The basic idea is to start with a grid of cells, where each cell is either a zero (dead) or a one (alive). We are interested in watching the population behavior over time to see if the population dies off, has some sort of equilibrium, etc. [John Conway](http://en.wikipedia.org/wiki/John_Horton_Conway) studied many possible ways to examine population behaviors and ultimately decided on the following rules, which we apply to each cell for the current tick (or generation).

1. Any live cell with fewer than two live neighbours dies, as if caused by under-population.
2. Any live cell with two or three live neighbours lives on to the next generation.
3. Any live cell with more than three live neighbours dies, as if by overcrowding.
4. Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction

Although there are [other versions](http://www.statisticsblog.com/2010/05/game-of-life-in-r/) of this in R, I decided to give it a shot myself. I am not going to provide a walkthrough of the code as I may normally do, but the code should be simple enough to understand for one proficient in R. It may have been unnecessary to implement this with the foreach package, but I wanted to get some more familiarity with foreach, so I did.

The set of grids is stored as a list, where each element is a matrix of zeros and ones. Each matrix is then converted to an image with ggplot2, and the sequence of images is exported as a MP4 video with the [animation package](http://cran.r-project.org/web/packages/animation/index.html).

Let me know if you improve on my code any. I'm always interested in learning how to do things better.


{{< highlight r >}}
library('foreach')
library('ggplot2')
library('animation')
library('reshape2')
 
# Determines how many neighboring cells around the (j,k)th cell have living organisms.
# The conditionals are used to check if we are at a boundary of the grid.
how_many_neighbors <- function(grid, j, k) {
  size <- nrow(grid)
  count <- 0
  if(j > 1) {
    count <- count + grid[j-1, k]
    if (k > 1) count <- count + grid[j-1, k-1]
    if (k < size) count <- count + grid[j-1, k+1]
  }
  if(j < size) {
    count <- count + grid[j+1,k]
    if (k > 1) count <- count + grid[j+1, k-1]
    if (k < size) count <- count + grid[j+1, k+1]
  }
  if(k > 1) count <- count + grid[j, k-1]
  if(k < size) count <- count + grid[j, k+1]
  count
}
 
# Creates a list of matrices, each of which is an iteration of the Game of Life.
# Arguments
# size: the edge length of the square
# prob: a vector (of length 2) that generates cells with probability of death and life, respectively
# returns a list of grids (matrices)
game_of_life <- function(size = 10, num_reps = 50, prob = c(0.5, 0.5)) {
  grid <- list()
  grid[[1]] <- replicate(size, sample(c(0,1), size, replace = TRUE, prob = prob))
  dev_null <- foreach(i = seq_len(num_reps) + 1) %do% {
    grid[[i]] <- grid[[i-1]]
    foreach(j = seq_len(size)) %:%
      foreach(k = seq_len(size)) %do% {
 
        # Apply game rules.
        num_neighbors <- how_many_neighbors(grid[[i]], j, k)
        alive <- grid[[i]][j,k] == 1
        if(alive && num_neighbors <= 1) grid[[i]][j,k] <- 0
        if(alive && num_neighbors >= 4) grid[[i]][j,k] <- 0
        if(!alive && num_neighbors == 3) grid[[i]][j,k] <- 1
      }
  }
  grid
}
 
# Converts the current grid (matrix) to a ggplot2 image
grid_to_ggplot <- function(grid) {
  # Permutes the matrix so that melt labels this correctly.
  grid <- grid[seq.int(nrow(grid), 1), ]
  grid <- melt(grid)
  grid$value <- factor(ifelse(grid$value, "Alive", "Dead"))
  p <- ggplot(grid, aes(x=Var1, y=Var2, z = value, color = value))
  p <- p + geom_tile(aes(fill = value))
  p  + scale_fill_manual(values = c("Dead" = "white", "Alive" = "black"))
}
{{< / highlight >}}

As an example, I have created a 50-by-50 grid with a 10% chance that its initial values will be alive. The simulation has 500 iterations. You may add more, but this takes long enough already. Note
that the default frame rate, which is controlled by __interval__, is 1 second. I set it to 0.05
based to give a decent video.

{{< highlight r >}}
set.seed(42)
game_grids <- game_of_life(size = 50, num_reps = 500, prob = c(0.1, 0.9))
grid_ggplot <- lapply(game_grids, grid_to_ggplot)
saveVideo(lapply(grid_ggplot, print), video.name = "animation.mp4", clean = TRUE, interval = 0.05)
{{< / highlight >}}

I uploaded the resulting video to YouTube for your viewing pleasure.

**Update**: After migrating to Jekyll 2.0 on GitHub pages, Jekyll is run in **safe** mode, so 3rd-party plugins are disabled. This includes the **youtube** plugin I was using previously. Maybe one day I'll be able to add the video here via: `%youtube TkH9qwHLwxk%`

