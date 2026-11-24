---
tags:
  - estimation
pre_ai_1: 0.5
pre_ai_2: 1.5
pre_ai_3: 2.5
pre_ai_5: 4
pre_ai_8: 7
with_ai_1: 0.17
with_ai_2: 0.5
with_ai_3: 1
with_ai_5: 2
with_ai_8: 4
bau_points_per_week: 3
bank_holidays: []
leave: []
---
How many days a ticket takes one dev, going by its story points. Epic overview Bases and epic notes read these properties, so change the numbers here and the estimates there update.

| Points       | 1                  | 2                  | 3                  | 5                  | 8                  |
| ------------ | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ |
| Days pre-AI  | `= this.pre_ai_1`  | `= this.pre_ai_2`  | `= this.pre_ai_3`  | `= this.pre_ai_5`  | `= this.pre_ai_8`  |
| Days with AI | `= this.with_ai_1` | `= this.with_ai_2` | `= this.with_ai_3` | `= this.with_ai_5` | `= this.with_ai_8` |

BAU work (bugs and other tickets that come in) is planned at `= this.bau_points_per_week` points a week, counted as one ticket of that size on the scale above.

Bank holidays (England and Wales) and leave aren't counted as working days. Add leave as one date per day off, and next year's bank holidays from [gov.uk](https://www.gov.uk/bank-holidays) when they run out.
