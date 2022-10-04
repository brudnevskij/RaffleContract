# Raffle Solidity Contract

Raffle contract allows deployer to arrange a giveaway and let participants to buy right to win.
To win and get reward participant supposed to pay a minimal amount of weis and be last participant for required amount of time, 
while all participation fees transfered to owner.

There are two types of Raffle contracts, growing and not growing. Growing raffle's participation price is increasing,
if participant pays amount that is more than minimal participation price, it will become new minimal participation price.

Upon deployement owner requested to set reward as a value of transaction, participation price, time to hold contract in seconds,
true/false if contract is growing or not.

You can also sell your raffle to someone else and perform a bit of risk management, which adds to a raffle a bit of
"derrivative finance" functionality.
