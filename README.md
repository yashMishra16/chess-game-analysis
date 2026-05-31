# Exploratory Data Analysis of Chess Games Using R

Exploratory data analysis of 20,000+ Lichess chess games using R — ratings, openings, win rates & time controls visualised with ggplot2.

---

## Dataset

- **Source:** [Chess Game Dataset (Lichess) — Kaggle](https://www.kaggle.com/datasets/datasnaek/chess)
- **Size:** ~20,000 rated games
- **File:** `games.csv`

| Variable | Description |
|---|---|
| `white_rating` | Elo rating of White player |
| `black_rating` | Elo rating of Black player |
| `winner` | Outcome: white / black / draw |
| `turns` | Total number of moves |
| `opening_name` | ECO opening classification |
| `increment_code` | Time control (e.g. `10+0`) |
| `rated` | Whether the game was rated |

---

## Tools & Libraries

- **Language:** R
- **Packages:** `dplyr`, `tidyr`, `ggplot2`, `stringr`

---

## Research Questions

1. Does a higher rating difference consistently predict the winner?
2. Does a first-move advantage exist across different rating ranges?
3. Which openings are most effective for White and Black?
4. How does game length relate to player skill level?
5. How do time controls (Bullet / Blitz / Rapid) affect gameplay?

---

## Visualisations

| Plot | Description |
|---|---|
| `plot1_rating_distribution.png` | Distribution of White and Black player ratings |
| `plot2_rating_diff_outcome.png` | Rating difference vs game winner |
| `plot3_win_rate_time_control.png` | Win rates across Bullet, Blitz, Rapid |
| `plot4_moves_time_control.png` | Game length by time control and winner |
| `plot5_top_openings_white.png` | Top 10 openings in White wins |
| `plot6_top_openings_black.png` | Top 10 openings in Black wins |
| `plot7_rating_vs_moves.png` | Player rating vs number of moves |
| `plot8_white_winrate_by_rating.png` | White win rate across rating ranges |

---

## Key Findings

- **White wins more than 50%** of decisive games across all rating bands — confirming the first-move advantage
- The advantage is **strongest below 1400 Elo** and narrows at higher ratings
- **Higher-rated players produce longer games**, reflecting deeper strategic resistance
- Openings like the **Sicilian and French Defence** appear frequently in Black wins; **King's Pawn and Queen's Pawn** systems dominate White wins
- **Rapid games** are longer and more complex; **Bullet games** are decided faster

---

## How to Run

1. Download `games.csv` from [Kaggle](https://www.kaggle.com/datasets/datasnaek/chess) and place it in the same folder as the R script
2. Install required packages:
```r
install.packages(c("dplyr", "tidyr", "ggplot2", "stringr"))
```
3. Open `chess_analysis.R` in RStudio
4. Set working directory: **Session → Set Working Directory → To Source File Location**
5. Click **Source** — all 8 plots will be saved as `.png` files

---

## Files

```
├── chess_analysis.R        ← R script
├── games.csv               ← Dataset (download from Kaggle)
├── plots/
│   ├── plot1_rating_distribution.png
│   ├── plot2_rating_diff_outcome.png
│   ├── plot3_win_rate_time_control.png
│   ├── plot4_moves_time_control.png
│   ├── plot5_top_openings_white.png
│   ├── plot6_top_openings_black.png
│   ├── plot7_rating_vs_moves.png
│   └── plot8_white_winrate_by_rating.png
└── report/
    ├── main.tex
    └── Final report.pdf
```
