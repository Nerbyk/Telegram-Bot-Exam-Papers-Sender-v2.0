# Pozor Bot v 2.0
After one month of [previous version of bot](https://github.com/Nerbyk/Telegram-Bot-Exam-Papers-Sender) exploitation I decided to create completly new bot with an updated structure, database system and client's interface.

## Description 
Every foreigner arriving from the CIS to the Czech Republic must pass nostrification exams. 3 to 6 exams are assigned.
[Russian-speaking community in Brno(Pozor! Brno)](https://vk.com/pozor.brno) organizes free assistance for new arrivals by providing them with examination papers(from 20 to 30 themes)
based on subjects that were assigned to new arrivals. But some people started selling this papers, so the access to this papers must be restricted.
So this bot sends the necessary documents with examinations papers based on the information provided by the user after after the administrator approves the application.

## Features 
- Data storing/automatic logging in SQL via ORM
    - Several tables for storing config data which could be alter/extend during exploitation
- Separated access levels (developer/admins/users)
- Already created class for: 
    - creating [custom keyboards](https://core.telegram.org/bots#keyboards)
    - user communication (Command desing pattern implememntation)
    - invoking response messages stored in YAML file
- Files with documents are sent through forwarding messages, no need to send every user new files uploaded from server
- Completely developer independent application after deployment(no need to maintain)
- Separate classes for all the functional, implemented features:
    - SOLID
    - KISS
    - DRY
    - GoF Design Patterns 
## Services 
- Notification for admin/moderator who inspects the request if user data (link/name+surname) matches with already accepted request. Generating telegra.ph article with matched request. 
- Observer for number of uninspected requests 
- Notification after bot restart
- Sidekiq implementation to clean each week DB from empty rows
## User Panel 
- Fill out a kind of a form/request to get specific documents. Form items:
    - Name Surname 
    - VK link(Russian Facebook)
        - User must be a members of VK community and telegram chanel 
    - Examination subjects via inline keyboard 
    - Photo of a document from the ministry mentioning a list of items
    - Send/Re-fill form 
- Commands
    - /start - to start bot (can be used once)
    - /status - check status of a request

## Moderator Panel
- Managing users requests
    - Accept
    - Deny + message with reason
    - Ban
- Commands 
    - /start - call main menu 
    - /inspect - start checking users requests
    - /status - get a number of uninspected requests 
## Admin Panel
- Commands(the same, as moderators have +)
     - /manage_admins - manage a list of admins
        - add new admin 
        - delete admin 
    - /update_documents - set new documents which would be send to users 
    - /set_notification number - set a minimum number of uninspected requests  to get a notification message 
    - /manage_links - change VK link and telegram channel link to check users membership
    
## Interface 
<img src="https://i.imgur.com/nR0l5cA.png?1"
     alt="Menu Demonstration"
     style="float: left; width: 50%; height: auto;" />
<img src="https://i.imgur.com/tsCadeu.png?1"
     alt="Menu Demonstration"
     style="float: left; margin-right: 10px;" />
