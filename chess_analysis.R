# ============================================================
# Chess Game Dataset (Lichess) - Exploratory Data Analysis
# Author: Shubh Mishra
# Dataset: Chess Game Dataset (Lichess) - ~20,000 games
# ============================================================

# ---- 1. Load Required Libraries ----
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)

# ---- 2. Load Dataset ----
# Download from: https://www.kaggle.com/datasets/datasnaek/chess
# Save as 'games.csv' in your working directory
chess <- read.csv("games.csv", stringsAsFactors = FALSE)

# ---- 3. Data Exploration ----
cat("=== Dataset Overview ===\n")
dim(chess)
head(chess)
str(chess)
summary(chess)

# ---- 4. Data Cleaning ----

# 4a. Keep only decisive games (white/black wins; remove draws for some analyses)
chess_clean <- chess %>%
  filter(winner %in% c("white", "black")) %>%
  mutate(
    winner = as.factor(winner),
    rated  = as.logical(rated)
  )

# 4b. Compute rating difference (white minus black)
chess_clean <- chess_clean %>%
  mutate(rating_diff = white_rating - black_rating)

# 4c. Classify time control into categories
chess_clean <- chess_clean %>%
  mutate(
    base_time = as.numeric(str_extract(increment_code, "^[0-9]+")),
    time_category = case_when(
      base_time < 3               ~ "Bullet",
      base_time >= 3 & base_time < 10 ~ "Blitz",
      base_time >= 10             ~ "Rapid",
      TRUE                        ~ "Other"
    ),
    time_category = factor(time_category, levels = c("Bullet", "Blitz", "Rapid"))
  )

# 4d. Extract short opening name (first two words)
chess_clean <- chess_clean %>%
  mutate(opening_short = word(opening_name, 1, 2))

cat("\n=== Cleaned Dataset Dimensions ===\n")
dim(chess_clean)
cat("\nMissing values per column:\n")
colSums(is.na(chess_clean))

# ---- 5. Visualisations ----

# --- Plot 1: Distribution of Player Ratings ---
rating_long <- chess_clean %>%
  select(white_rating, black_rating) %>%
  pivot_longer(cols = everything(),
               names_to  = "player",
               values_to = "rating") %>%
  mutate(player = recode(player,
                         "white_rating" = "White",
                         "black_rating" = "Black"))

p1 <- ggplot(rating_long, aes(x = rating, fill = player)) +
  geom_histogram(binwidth = 50, alpha = 0.7, position = "identity", color = "white") +
  scale_fill_manual(values = c("White" = "#4E79A7", "Black" = "#E15759")) +
  labs(
    title    = "Distribution of Player Ratings",
    subtitle = "White vs Black players across ~20,000 Lichess games",
    x        = "Rating (Elo)",
    y        = "Number of Games",
    fill     = "Player"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "top")

print(p1)
ggsave("plot1_rating_distribution.png", p1, width = 8, height = 5, dpi = 150)

# --- Plot 2: Rating Difference vs Game Outcome ---
p2 <- ggplot(chess_clean, aes(x = winner, y = rating_diff, fill = winner)) +
  geom_boxplot(alpha = 0.8, outlier.alpha = 0.3) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey40") +
  scale_fill_manual(values = c("white" = "#4E79A7", "black" = "#E15759")) +
  labs(
    title    = "Rating Difference by Game Winner",
    subtitle = "Positive values = White rated higher; negative = Black rated higher",
    x        = "Winner",
    y        = "Rating Difference (White - Black)",
    fill     = "Winner"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none")

print(p2)
ggsave("plot2_rating_diff_outcome.png", p2, width = 7, height = 5, dpi = 150)

# --- Plot 3: Win Rate by Time Control ---
win_rate_tc <- chess_clean %>%
  group_by(time_category, winner) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(time_category) %>%
  mutate(pct = n / sum(n) * 100)

p3 <- ggplot(win_rate_tc, aes(x = time_category, y = pct, fill = winner)) +
  geom_col(position = "stack", color = "white", width = 0.6) +
  scale_fill_manual(values = c("white" = "#4E79A7", "black" = "#E15759")) +
  labs(
    title    = "Win Rates by Time Control",
    subtitle = "Proportion of White vs Black wins across Bullet, Blitz, and Rapid",
    x        = "Time Control",
    y        = "Percentage of Games (%)",
    fill     = "Winner"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "top")

print(p3)
ggsave("plot3_win_rate_time_control.png", p3, width = 7, height = 5, dpi = 150)

# --- Plot 4: Number of Moves by Winner and Time Control ---
p4 <- ggplot(chess_clean, aes(x = time_category, y = turns, fill = winner)) +
  geom_boxplot(alpha = 0.7, outlier.alpha = 0.2) +
  scale_fill_manual(values = c("white" = "#4E79A7", "black" = "#E15759")) +
  labs(
    title    = "Number of Moves by Time Control and Winner",
    x        = "Time Control",
    y        = "Number of Moves",
    fill     = "Winner"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "top")

print(p4)
ggsave("plot4_moves_time_control.png", p4, width = 8, height = 5, dpi = 150)

# --- Plot 5: Top 10 Most Popular Openings for White Wins ---
top_openings_white <- chess_clean %>%
  filter(winner == "white") %>%
  count(opening_short, sort = TRUE) %>%
  slice_head(n = 10)

p5 <- ggplot(top_openings_white,
             aes(x = reorder(opening_short, n), y = n)) +
  geom_col(fill = "#4E79A7", color = "white") +
  coord_flip() +
  labs(
    title = "Top 10 Openings Leading to White Wins",
    x     = "Opening",
    y     = "Number of White Wins"
  ) +
  theme_minimal(base_size = 13)

print(p5)
ggsave("plot5_top_openings_white.png", p5, width = 8, height = 5, dpi = 150)

# --- Plot 6: Top 10 Most Popular Openings for Black Wins ---
top_openings_black <- chess_clean %>%
  filter(winner == "black") %>%
  count(opening_short, sort = TRUE) %>%
  slice_head(n = 10)

p6 <- ggplot(top_openings_black,
             aes(x = reorder(opening_short, n), y = n)) +
  geom_col(fill = "#E15759", color = "white") +
  coord_flip() +
  labs(
    title = "Top 10 Openings Leading to Black Wins",
    x     = "Opening",
    y     = "Number of Black Wins"
  ) +
  theme_minimal(base_size = 13)

print(p6)
ggsave("plot6_top_openings_black.png", p6, width = 8, height = 5, dpi = 150)

# --- Plot 7: Scatter – Rating vs Number of Moves (by Winner) ---
set.seed(42)
chess_sample <- chess_clean %>% slice_sample(n = 3000)

p7 <- ggplot(chess_sample,
             aes(x = white_rating, y = turns, color = winner)) +
  geom_point(alpha = 0.3, size = 1.2) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1) +
  scale_color_manual(values = c("white" = "#4E79A7", "black" = "#E15759")) +
  labs(
    title    = "Player Rating vs Number of Moves",
    subtitle = "Sample of 3,000 games; trend lines by winner",
    x        = "White Player Rating",
    y        = "Number of Moves",
    color    = "Winner"
  ) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "top")

print(p7)
ggsave("plot7_rating_vs_moves.png", p7, width = 8, height = 5, dpi = 150)

# --- Plot 8: First-Move Advantage – White Win Rate by Rating Range ---
chess_clean <- chess_clean %>%
  mutate(rating_bin = cut(white_rating,
                          breaks = c(0, 1000, 1200, 1400, 1600, 1800, 2000, 3000),
                          labels = c("<1000","1000-1200","1200-1400",
                                     "1400-1600","1600-1800","1800-2000",">2000")))

white_wr <- chess_clean %>%
  group_by(rating_bin) %>%
  summarise(
    total      = n(),
    white_wins = sum(winner == "white"),
    win_rate   = white_wins / total * 100,
    .groups    = "drop"
  ) %>%
  filter(!is.na(rating_bin))

p8 <- ggplot(white_wr, aes(x = rating_bin, y = win_rate)) +
  geom_col(fill = "#59A14F", color = "white") +
  geom_hline(yintercept = 50, linetype = "dashed", color = "grey40") +
  labs(
    title    = "White Win Rate Across Rating Ranges",
    subtitle = "Dashed line = 50% (no advantage); bars above = first-move advantage",
    x        = "White Player Rating Range",
    y        = "White Win Rate (%)"
  ) +
  theme_minimal(base_size = 13)

print(p8)
ggsave("plot8_white_winrate_by_rating.png", p8, width = 8, height = 5, dpi = 150)

# ---- 6. Summary Statistics ----
cat("\n=== Overall Win Rates ===\n")
chess_clean %>%
  count(winner) %>%
  mutate(pct = round(n / sum(n) * 100, 2)) %>%
  print()

cat("\n=== Average Moves by Time Control ===\n")
chess_clean %>%
  group_by(time_category) %>%
  summarise(avg_moves = round(mean(turns), 1),
            median_moves = median(turns),
            .groups = "drop") %>%
  print()

cat("\n=== Average Rating Difference When White Wins vs Black Wins ===\n")
chess_clean %>%
  group_by(winner) %>%
  summarise(mean_rating_diff = round(mean(rating_diff), 1),
            .groups = "drop") %>%
  print()

cat("\n=== Analysis Complete. Plots saved to working directory. ===\n")
