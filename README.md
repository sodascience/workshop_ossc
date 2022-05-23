# Supercomputing with R for Social Scientists

This repository contains the code and presentation of the workshop on parallel computing & cluster computing using R in collaboration with SURF. More information & sign-up can be found on the website [here](https://www.surf.nl/en/agenda/supercomputing-for-social-scientists-with-r).

![image](img/abm.png)

## Prerequisites
- Some `R` knowledge & experience :)
- `R`, minimum version `4.2.0` (download [here](https://cran.r-project.org/))
- If you are on Windows: `RTools` (download [here](https://cran.r-project.org/bin/windows/Rtools/))
- Recommended IDE: `RStudio` (download [here](https://www.rstudio.com/products/rstudio/download/#download))
- Install the following packages:
  ```r
  install.packages(c("Rcpp", "tidyverse", "pbapply", "sf", "mgcv"))
  ```
- Download this repository ([link](https://github.com/sodascience/ossc_workshop/archive/refs/heads/main.zip)) and unzip it to a nice location
- Open the project by double-clicking on `ossc_workshop.Rproj` in the folder.

## Schedule

| Time  | Title                                           | Required resource                   |
| :---- | :---------------------------------------------- | :---------------------------------- |
| 13:00 | Lecture: computational limits in social science | [`slides`](./slides/intro.pdf)      |
| 13:45 | Hands-on: a parallel agent-based model in R     | [`assignment`](./hands_on/intro.md) |
| 14:30 | Break                                           | `your own coffee :)`                |
| 14:45 | Lecture: supercomputing with R                  | [`slides`](./slides/supercomp.pdf)  |
| 15:30 | Hands-on: submitting an R array job             | [`assignment`](./hands_on/super.md) |
| 16:00 | Break                                           | `your own coffee :)`                |
| 16:15 | Lecture: combining & analysing the results      | [`slides`](./slides/results.pdf)    |
| 16:30 | Conclusion & Q&A                                | `your remaining attention!`         |

## End result: a map of the Netherlands
The below map would take around 6 months to produce using the naïve implementation on a normal computer. You will learn how to compute it in a few hours on a supercomputer.

![map](img/segr_map.png)

## Contact

This project is developed and maintained by the [ODISSEI Social Data
Science (SoDa)](https://odissei-data.nl/nl/soda/) team.

<img src="img/soda_logo.png" alt="SoDa logo" width="250px"/>

Do you have questions, suggestions, or remarks? File an issue in the
issue tracker or feel free to contact [Erik-Jan van
Kesteren](https://github.com/vankesteren)
([@ejvankesteren](https://twitter.com/ejvankesteren))
