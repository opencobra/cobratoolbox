# Data model: lrsRun without the separate redund program

No data structures change. The files involved, for a model name `<m>` as lrsRun forms it:

| File | Written by | Content | Changed by this feature |
|---|---|---|---|
| `<m>.ext` | user | V-representation | no |
| `<m>.ine` | lrs (facet enumeration), count fixed by lrsSpecifyRows | H-representation with the trivial row | no (still written, never edited afterwards) |
| temporary `*.ine` in the system temporary folder | lrsRun | copy of `<m>.ine` followed by `redund 0 0` | new; removed before lrsRun returns or raises |
| `<m>_noR.ine` (returned) | lrs with the option (before: redund) | irredundant H-representation | same rows; lrs 7.1 adds an echo line before `H-representation` |

Option line: `redund 0 0` after `end` = test rows 0..0, which lrs reads as all rows.
