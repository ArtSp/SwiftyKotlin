package util

import platform.Foundation.*

actual fun Double.getCurrency(currencyCode: String): String? {
    return try {
        val number = NSNumber.numberWithDouble(this)
        val formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterCurrencyStyle
        formatter.currencyDecimalSeparator = "."
        formatter.currencyGroupingSeparator = " "
        formatter.currencyCode = currencyCode
        formatter.stringFromNumber(number)
    } catch (e: Exception) {
        null
    }
}