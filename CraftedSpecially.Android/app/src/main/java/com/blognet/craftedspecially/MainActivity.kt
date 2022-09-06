package com.blognet.craftedspecially

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material.MaterialTheme
import androidx.compose.material.Surface
import androidx.compose.ui.Modifier
import com.blognet.craftedspecially.ui.LandingPage
import com.blognet.craftedspecially.ui.landingpage.LandingPageViewModel
import com.blognet.craftedspecially.ui.theme.CraftedSpeciallyTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            CraftedSpeciallyTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colors.background
                ) {
                    LandingPage(LandingPageViewModel())
                }
            }
        }
    }
}