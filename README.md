# CoinDuel
### Kooshul Jhaveri, Anish Chadalavada, Mitchell Revers, Rajiv Ramaiah, Henry Wilson, Josh Kerber | CS98 18W

![alt text](http://cs.dartmouth.edu/~jkerber14/images/teampic.png "Team Picture")

## Problem Statement

The rapid growth of cryptocurrencies has shocked the financial world. While bitcoin has gone up thousands of times in value, alternative coins (altcoins) have also become popular. Despite cryptocurrencies' popularity, it is quite difficult and risky to invest one's own money in altcoins. We are attempting to create a fun, free game that will allow users to gain more exposure and learn more about investing in altcoins, without worry of hacked exchanges or high transaction fees.

## Impact

This project simultaneously draws users in to follow the exciting altcoin market, while also incentivizing participation by allowing users to compete against friends in an engaging format. With U.S. stocks, Robinhood, which implemented a feeless and free stock trading platform, made it possible for people to invest without having a traditional brokerage account. We plan on teaching users how to invest in cryptocurrencies by allowing them to play without paying money. We hope to combine FanDuel with cryptocurrency investing with an HQ-style interface.  

## Prior Work

* FanDuel
* DraftKings
* iPoll
* SwagBucks
* Stash
* Robinhood
* Motif
* HQ
* Coinbase

Our product is different from sites like FanDuel and DraftKings in that it is free to play. It is different from iPoll, SwagBucks and HQ, sites that let users earn money for free, in that our app is a cryptocurrency literacy-focused game where users can learn to follow the cryptocurrency markets instead of having to view product advertisements or answer trivia questions. Lastly, though Motif, Robinhood, and Coinbase are also apps centered on stock market investing, with those applications it is necessary to commit real money. 

## Proposed Solution

Our proposed solution involves developing a platform that allows for novice crypto investors to learn about investing by participating in coin-picking competitions of variable round length (potentially one week) and then seeing how their portfolio performed over that period of time. At the beginning of each round, each user will pick 5 cryptocurrencies they wish to trade. 3 of these cryptos will be locked in for the round, whilst 2 will be “flex” picks which you can decide to disable / enable at your leisure, giving you freedom to back out if that crypto starts to crash. We would reward users with points (calling them "CapCoin", short for Capitalize) based on their performance over the round (for example, 100% return could be 1 CapCoin, and 200% return 2 CapCoin, etc.). 

We aim to develop both a free version where users can be a part of a community-wide leaderboard, and also a betting against friends style version where groups of friends each buy-in like in FanDuel, and the person with the most CapCoin at the end of 10 rounds receives 60% of the pot, 30% for second place, and 10% for third place (all of these percentages are subject to change). We hope to integrate the better aspects of several popular investing and game apps so that investing in cryptocurrencies does not seem as intimidating to younger people. Apps that directly allow you to exchange US dollars for cryptocurrencies neglect to consider the audience of investors who might wish to learn about cryptocurrencies but may not have the capital or the appetite for risk necessary to invest their own savings. Additionally, these exchanges tend to get hacked, or charge large fees. 

We hope that our game will enable crypto-hobbiests to not only learn more about the crypto market, but gain confidence in investing by facilitating a friendly competition that results in cash prizes for participants who do well (and who wish to compete against friends). We also hope to implement features to provide technical analysis so that budding enthusiasts can learn about technical factors such as momentum, market tops and bottoms, moving averages, etc.

## Team

* Kooshul Jhaveri - product management & design, can do both front and back end; can create/assign modules; prefer to be working on distinct features/modules to code alone
* Josh Kerber - lead developer, can crank out large features quickly and learn new technologies easily
* Rajiv Ramaiah - code solo or pair program, iOS experience, design, UI/UX
* Henry Wilson - knowledgeable about backend development and working with various APIs
* Mitch Revers - experience with mobile apps, work alone towards specific goals
* Anish Chadalavada - product management and front-end design, strategy/feature idea generation, code together

## Strategy

Development Strategy for MVP:
* Build out onboarding and sign-in features
* Develop one tab/page for entering game and submitting ‘lineups’ of cryptocurrencies 
* Create a display tab for users to monitor their portfolio throughout the round, as well as their standing and the leaderboard
* Link in news, financial data/charts, and other analysis about the particular cryptos for a given round from a variety of sources

Possible extension features:
* Integration of buy-ins / payouts, to award top placers (either PayPal or Venmo)
* Ability for a user to create private leagues with other users, with customizable rules and time periods
* Community forums for people to discuss strategy and the best lineup for the week

Testing:
	After testing the MVP app in our six-person group, we plan to further test our product by inviting a number of our friends to download the beta version and play the game, and to let us know of any bugs or confusions in UI/usage that arise. We also plan to ask them to fill out a form for suggestions for improvements and new features.

## Implementation Challenges

MVP:
* We will have to find a reliable cryptocurrency data API and update each player’s returns in real time, which could become costly if we use an API that charges for each call. In addition, none of us are experienced iOS programmers, so there will be some initial learning curve as we learn this new technology.

Post MVP:
* We need to pay winners of each round using some means of P2P transaction, possibly Apple Pay which provides several different methods using fingerprints, face recognition, etc. In order to make the app sustainable, we may need to take a transaction fee from users.

## Meeting Schedule


Three times a week, Wednesday, Thursday class, and Saturday
