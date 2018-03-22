# CTF Coin

Cryptokitties for Hackers!

# Quick Start
 - Install truffle globally `npm install -g truffle`
 - Install node packages `npm install`
 - Open ganache or run `ganache-cli --port 7545`
 - Run `truffle test` for tests
 - Execute `truffle migrate` (Hanging is the best way to execute)
 - Execute `npm run dev`

# About
CTFCoin provides a way to reward ctf participants for doing well. Ctf admins can register a ctf through our dapp, and if enough reputable teams (reputation is based on ctf participation and victories) vouch for the ctf by declaring their intent to participate, the admin will be allowed do distribute a proportional number of reward badges (max: 10). Along with badges, when registering the ctf, the admin can transfer a pot of ETH to be locked until the ctf has ended, and distributed at the admin's discresion.

Registered Ctfs contain this information:
 - its id (out of all ctfs)
 - a string description
 - a string name
 - address owner  
 - a start time
 - an end time
 - amount of eth in the pot

Reward badges contain this information:
 - its id (out of all badges)
 - The id of the CTF it is from
 - 32 bytes chosen by the admin before token is rewarded

Badges may only be rewarded within a certian amount of time from the end of a ctf.
