### [M-1] Precision Loss when calculating Health Factor in `DSCEngine::_calculateHealthFactor` function

**Description:** 

The `DSCEngine::_calculateHealthFactor` function which does wrong calculations for Healtfactor by performing divide operations before multiplication exposing the function and contract to a precision loss vulnerability,which could result to incorrect payouts when users mint DSC leading to loss of funds or insolvency.

```javascript

function _calculateHealthFactor(uint256 totalDscMinted, uint256 collateralValueInUsd)
        internal
        pure
        returns (uint256)
    {
        if (totalDscMinted == 0) return type(uint256).max;
@>>       uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
@>>       return (collateralAdjustedForThreshold * 1e18) / totalDscMinted;
    }

```

**Impact:** 

- If the Health Factor is calculated lower than it should be, users might be unable to mint DSC despite having adequate collateral. This restricts their ability to utilize their assets efficiently.

- If the Health Factor is calculated higher than it should be due to precision loss, the system might assume that the user's collateral is sufficient to cover their minted DSC. This can lead to a situation where users are able to mint more DSC than they should, creating a risk of under-collateralization.
  
- Miscalculations can lead to premature liquidations, where users lose their assets unnecessarily, or delayed liquidations, where the system takes on additional risk because positions are not closed in time


**Recommended Mitigation:** 

To prevent this we should perform multiplication before division.

```diff
function _calculateHealthFactor(uint256 totalDscMinted, uint256 collateralValueInUsd)
        internal
        pure
        returns (uint256)
    {
        if (totalDscMinted == 0) return type(uint256).max;
-      uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
-      return (collateralAdjustedForThreshold * 1e18) / totalDscMinted;

+        return uint256 collateralAdjustedForThreshold = ((collateralValueInUsd * LIQUIDATION_THRESHOLD)* 1e18) / (LIQUIDATION_PRECISION * totalDscMinted)
    }

```


