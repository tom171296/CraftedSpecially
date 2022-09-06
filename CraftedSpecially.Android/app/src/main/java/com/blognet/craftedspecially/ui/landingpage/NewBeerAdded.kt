package com.blognet.craftedspecially.ui.landingpage

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.blognet.craftedspecially.R
import com.blognet.craftedspecially.ui.elements.LoadingIcon

@Preview
@Composable
internal fun NewBeerAddedFetchingPreview(){
    NewBeerAdded(uiState = NewBeerAddedUiState.Fetching())
}

@Composable
internal fun NewBeerAdded(uiState: NewBeerAddedUiState){
    when(uiState) {
        is NewBeerAddedUiState.Fetching -> {
            LoadingNewBeer()
        }
    }
}

@Composable
internal fun LoadingNewBeer(){
    // new release from + icon
    Column (modifier = Modifier.padding(10.dp)){
        Row (modifier = Modifier
            .height(50.dp)
            .size(200.dp)
        ) {
            LoadingIcon(modifier =
            Modifier
                .size(40.dp)
                .clip(CircleShape),
                painter = painterResource(id = R.drawable.ic_loading_beer)
            )
            Canvas(modifier = Modifier
                .fillMaxHeight()
                .fillMaxWidth()
                .padding(5.dp)
            ) {
                val canvasWidth = size.width
                val canvasHeight = size.height

                drawLine(
                    start = Offset(x = 0f, y = canvasHeight * 0.25f),
                    end = Offset(x = canvasWidth, y = canvasHeight * 0.25f),
                    color = Color.LightGray,
                    strokeWidth = 5f
                )

                drawLine(
                    start = Offset(x = 0f, y = canvasHeight * 0.5f),
                    end = Offset(x = canvasWidth, y = canvasHeight * 0.5f),
                    color = Color.LightGray,
                    strokeWidth = 5f
                )
            }
        }
    }
}