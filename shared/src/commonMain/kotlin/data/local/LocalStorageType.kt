package data.local

import domain.models.AppState

interface LocalStorageType {
    var appState: AppState
}