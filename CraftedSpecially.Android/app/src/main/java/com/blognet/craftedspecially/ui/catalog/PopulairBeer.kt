package com.blognet.craftedspecially.ui.catalog

import androidx.compose.animation.core.*
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.GridCells
import androidx.compose.foundation.lazy.LazyVerticalGrid
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.blognet.craftedspecially.R
import com.blognet.craftedspecially.ui.theme.ShimmerColorShades

@Preview
@Composable
fun CatalogPreview(){
    Catalog(viewModel = CatalogViewModel())
}

@Composable
internal fun Catalog(viewModel: CatalogViewModel) {
    PopulairBeerList(uiState = viewModel.populairBeerUiState)
}

@Composable
internal fun PopulairBeerList(uiState: PopularBeerUiState){
    when (uiState){
        is PopularBeerUiState.FetchingCatalog -> {
            LoadingBeerList()
        }
    }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
internal fun LoadingBeerList(){
    LazyVerticalGrid(cells = GridCells.Adaptive(150.dp)){
        items(6){
            LoadingBeerItem()
        }
    }
}

@Composable
internal fun LoadingBeerItem(){
    Row(modifier = Modifier
        .padding(10.dp)
        .size(60.dp)
    ){
        LoadingPopulairBeerIcon(shape = CircleShape)
        LoadingPopulairBeerText()
    }
}

@Composable
internal fun LoadingPopulairBeerIcon(shape: Shape){
    val transition = rememberInfiniteTransition()
    val translateAnim by transition.animateFloat(
        initialValue = 0f,
        targetValue = 1000f,
        animationSpec = infiniteRepeatable(
            tween(durationMillis = 1000, easing = FastOutSlowInEasing),
            RepeatMode.Reverse
        )
    )

    val brush = Brush.linearGradient(
        colors = ShimmerColorShades,
        start = Offset(10f, 10f),
        end = Offset(translateAnim, translateAnim)
    )

    Box(
        modifier = Modifier
            .size(60.dp)
            .clip(shape)
            .background(brush)
            .padding(5.dp)
    ){
        Icon(
            painter = painterResource(id = R.drawable.ic_loading_beer),
            contentDescription = null,
            Modifier
                .fillMaxWidth()
                .fillMaxHeight()
        )
    }
}

@Composable
internal fun LoadingPopulairBeerText(){
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

        drawLine(
            start = Offset(x = 0f, y = canvasHeight * 0.75f),
            end = Offset(x = canvasWidth * 0.75f, y = canvasHeight * 0.75f),
            color = Color.LightGray,
            strokeWidth = 5f
        )
    }
}
