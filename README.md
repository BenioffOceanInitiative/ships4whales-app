# ships4whales-app
Shiny app to connect to database and show dashboard a la ship-cards

1. 
1. Install [shiny.users & shiny.admin](https://appsilon.com/user-authentication-in-r-shiny-sneak-peek-of-shiny-users-and-shiny-admin-packages/)

1. Setup auto-emails using R package `blastula`
  - [Emails from R: Blastula 0.3 | RStudio Blog](https://blog.rstudio.com/2019/12/05/emails-from-r-blastula-0-3/)
  - [Easily Send HTML Email Messages • blastula](https://rich-iannone.github.io/blastula/)
  - [How to Send Custom E-mails with R | R-bloggers](https://www.r-bloggers.com/how-to-send-custom-e-mails-with-r/)
1. Outline mansucript to change ship behavior
  - TED talk: references + 3 pieces
  - campaigns:
    - launch website + press
    - email ship owners
    - call ship operators

## DONE

1. Add email support to WordPress site
  - [How to Send Email in WordPress using the Gmail SMTP Server](https://www.wpbeginner.com/plugins/how-to-send-email-in-wordpress-using-the-gmail-smtp-server/)



## tbl

Initial table display app for testing connection to a Postgres database.

### online

TODO: later, after figuring out how to have secure password info.

### local

Assuming you have needed packages installed, you can run locally with:

```r
shiny::runGitHub("BenioffOceanInitiative/ships4whales-app", subdir="tbl")
```
