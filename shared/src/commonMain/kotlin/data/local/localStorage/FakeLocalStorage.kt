package data.local.localStorage

import data.local.LocalStorageType
import domain.models.AppState
import domain.models.Auth

class FakeLocalStorage: LocalStorageType {
    
    override var appState: AppState = AppState().also {
//        it.auth = 
    }
       
}