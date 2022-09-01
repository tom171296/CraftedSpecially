package com.blognet.craftedspecially.ui.catalog

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel

internal class CatalogViewModel : ViewModel() {
    var populairBeerUiState by mutableStateOf<PopularBeerUiState>(PopularBeerUiState.FetchingCatalog())
}

internal sealed class PopularBeerUiState {
    class FetchingCatalog() : PopularBeerUiState()
}