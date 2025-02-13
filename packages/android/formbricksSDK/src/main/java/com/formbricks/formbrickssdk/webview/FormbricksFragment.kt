package com.formbricks.formbrickssdk.webview

import android.annotation.SuppressLint
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.webkit.ConsoleMessage
import android.webkit.WebChromeClient
import android.webkit.WebView
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.viewModels
import com.formbricks.formbrickssdk.Formbricks
import com.formbricks.formbrickssdk.databinding.FragmentFormbricksBinding
import com.google.android.material.bottomsheet.BottomSheetDialogFragment


class FormbricksFragment : BottomSheetDialogFragment() {

    private lateinit var binding: FragmentFormbricksBinding

    companion object {
        private val TAG: String by lazy { FormbricksFragment::class.java.simpleName }

        fun show(childFragmentManager: FragmentManager) {
            val fragment = FormbricksFragment()
            fragment.show(childFragmentManager, TAG)
        }
    }

    private val viewModel: FormbricksViewModel by viewModels()

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = FragmentFormbricksBinding.inflate(inflater).apply {
            lifecycleOwner = viewLifecycleOwner
        }
        binding.viewModel = viewModel
        return binding.root
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        binding.formbricksWebview.let {
            if (Formbricks.loggingEnabled) {
                WebView.setWebContentsDebuggingEnabled(true)
            }
            it.webChromeClient = object : WebChromeClient() {
                override fun onConsoleMessage(consoleMessage: ConsoleMessage?): Boolean {
                    consoleMessage?.let { cm ->
                        val log = "[CONSOLE:${cm.messageLevel()}] \"${cm.message()}\", source: ${cm.sourceId()} (${cm.lineNumber()})"
                        Log.d("Javascript message", log)
                    }
                    return super.onConsoleMessage(consoleMessage)
                }
            }
            it.settings.javaScriptEnabled = true
            it.settings.domStorageEnabled = true
            it.settings.loadWithOverviewMode = true
            it.settings.useWideViewPort = true
            it.addJavascriptInterface(WebAppInterface(), WebAppInterface.INTERFACE_NAME)
        }
        viewModel.loadHtml()
    }
}

