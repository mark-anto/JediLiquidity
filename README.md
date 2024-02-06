# Problem Statement
Given an amount in any market and an AMM pool, split the amount into the pool markets and add it as liquidity to the given pool.
Vice-versa for removal of liquidity.

# High Level Logic
The given amount market can be one of the pool markets or neither. Depending on these 3 routes we can set an intermediate token which is then partially swapped to get the corresponding pair address of the pool.

On a high level assume we have a given amount 1000 and 1000 is to be distributed as liquidity to pool AB.
The equation intuitively resolves to the following:
=> get_amounts_out(x) = quote(1000 - x) [1]

Here x is the amount added as market A and (1000 - x) is the amount added as market B. The value of the split should be roughly same as ratio of
A:B so as to not cause any swings.
Equation [1] can be expanded using AMM formulae to further simplify this equation to a quadratic to be solved for x by solving quadratic roots
using the determinant.

# Example Use Case
The following codebase is written in Cairo1 and adds liquidity to a specified JediSwap pool for a specified amount. As the principles across AMM's remains the same it can be repurposed and used for any given AMM.

# Observations
To note here - The original problem statement was to have none of the original amount remaining after it being split for adding liquidity.
But this particular sub-problem could not be solved - 1) because of slippage - 2) external factors influencing return values of the above functions like block inclusion time, sequence of transactions etc. So there is always a possibility of some residual amount remaining which
needs to be accounted for.

# Note
The equation is structured assuming 3% fees [standard for most AMM's]. To note here is -: if the fees is not 3% then the equation simplifaction changes and the code cannot be used as is. As it stands the code has not been audited so you may use it at your own risk.

# Inspiration
Check out mesh finances Zapper contracts for the inspiration/reference of this project
https://github.com/mesh-finance/zapper-starknet/tree/initial_poc

# Outdated as of 2024 as Cairo versions have had major changes. The core logic is sound and tested but code cannot and should not be used as is.
