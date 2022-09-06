package com.blognet.craftedspecially.ui.landingpage

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel

internal class LandingPageViewModel : ViewModel() {
    var recommendedForYouUiState by mutableStateOf<RecommendedForYouUiState>(RecommendedForYouUiState.Fetching())
    var newBeerAddedUiState by mutableStateOf<NewBeerAddedUiState>(NewBeerAddedUiState.Fetching())


}

internal sealed class RecommendedForYouUiState {
    class Fetching() : RecommendedForYouUiState()
}

internal sealed class NewBeerAddedUiState {
    class Fetching() : NewBeerAddedUiState()
}