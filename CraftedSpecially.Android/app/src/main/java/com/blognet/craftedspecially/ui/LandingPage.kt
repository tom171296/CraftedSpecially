package com.blognet.craftedspecially.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.blognet.craftedspecially.ui.landingpage.LandingPageViewModel
import com.blognet.craftedspecially.ui.landingpage.NewBeerAdded
import com.blognet.craftedspecially.ui.landingpage.RecommendedForYou
import java.util.*

@Preview
@Composable
fun LandingPagePreview(){
    LandingPage(viewModel = LandingPageViewModel())
}

@Composable
internal fun LandingPage(viewModel: LandingPageViewModel) {
    Column (modifier = Modifier
        .background(Color.Black)
    ) {
        Header()
        RecommendedForYou(uiState = viewModel.recommendedForYouUiState)
        NewBeerAdded(uiState = viewModel.newBeerAddedUiState)
    }
}

@Preview
@Composable
internal fun Header(){
    Row(modifier = Modifier
        .fillMaxWidth()
    ) {
        Text(
            modifier = Modifier
                .padding(10.dp),
            color = Color.White,
            text = "Good afternoon")
    }
}