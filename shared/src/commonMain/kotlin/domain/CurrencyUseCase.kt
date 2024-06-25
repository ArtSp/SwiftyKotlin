package domain

import data.remoteClientType.RemoteClientType
import util.getCurrency

class CurrencyUseCase(
   private val client: RemoteClientType
) {
    fun getLocalToUSDCurrency(
        localVal: Double
    ): String? {
        // TODO: Find & implement some public API for conversion
        return (localVal * 1.23).getCurrency(currencyCode = "USD")
    }
}
