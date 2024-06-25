import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.material.Button
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Text
import androidx.compose.material.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import data.remoteClientType.remoteClient.FakeRemoteClient
import domain.CurrencyUseCase
import org.jetbrains.compose.resources.ExperimentalResourceApi
import org.jetbrains.compose.resources.painterResource
import util.Greeting

@OptIn(ExperimentalResourceApi::class)
@Composable
fun App() {
    MaterialTheme {
        var showContent by remember { mutableStateOf(false) }
        val greeting = remember { Greeting().greet() }

        val currencyUseCase = CurrencyUseCase(FakeRemoteClient())

        var localCurrencyVal by remember { mutableStateOf("") }
        var convertedCurrencyVal by remember { mutableStateOf("") }

        Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
            Text("Currency converter")
            TextField(
                value = localCurrencyVal,
                onValueChange = { localCurrencyVal = it },
                label = { Text("Local value") }
            )
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Converted: $convertedCurrencyVal")
                Spacer(modifier = Modifier.size(30.dp))
                Button(onClick = {
                    runCatching {
                        localCurrencyVal.toDouble()
                    }.let {
                        it.getOrNull().let { it2 ->
                            it2?.let { it3 ->
                                convertedCurrencyVal = currencyUseCase.getLocalToUSDCurrency(it3).toString()
                            }
                        }
                    }
                }) {
                    Text("Convert")
                }
            }
            Button(onClick = { showContent = !showContent }) {
                Text("Click me!")
            }
            AnimatedVisibility(showContent) {
                Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
                    Image(painterResource("compose-multiplatform.xml"), null)
                    Text("Compose: $greeting")
                }
            }
        }
    }
}