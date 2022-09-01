package com.blognet.craftedspecially

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.ui.Modifier
import com.blognet.craftedspecially.ui.catalog.Catalog
import com.blognet.craftedspecially.ui.catalog.CatalogViewModel
import com.blognet.craftedspecially.ui.theme.CraftedSpeciallyTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            CraftedSpeciallyTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colors.background
                ) {
                    Catalog(CatalogViewModel())
                }
            }
        }
    }
}