package util

import java.text.NumberFormat
import java.util.Currency

actual fun Double.getCurrency(currencyCode: String): String? {
    return try {
        val formatter = NumberFormat.getCurrencyInstance();
        formatter.setMaximumFractionDigits(2);
        val currency= Currency.getInstance(currencyCode)
        formatter.currency = currency
        
        return formatter.format(this);
    } catch (e: Exception) {
        null
    }
}